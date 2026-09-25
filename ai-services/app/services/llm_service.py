import asyncio
import json
import logging
import httpx
from typing import Dict, Any
from app.config import settings
from app.schemas import (
    ResumeRequest, ResumeResponse,
    QuizRequest, QuizResponse,
    SkillGapRequest, SkillGapResponse
)
from app.services.fallback_service import (
    generate_fallback_resume,
    generate_fallback_quiz,
    generate_fallback_skill_gap
)

logger = logging.getLogger("ai_service.llm")
logging.basicConfig(level=logging.INFO)

# Internal timeout for LLM calls (in seconds)
TIMEOUT_SECONDS = (settings.AI_SERVICE_TIMEOUT_MS - 100) / 1000.0

async def generate_optimized_resume(payload: ResumeRequest) -> ResumeResponse:
    if settings.AI_PROVIDER == "mock" or not settings.OPENAI_API_KEY and not settings.GROQ_API_KEY:
        logger.info("Using mock/fallback provider for resume generation.")
        return generate_fallback_resume(payload)
    
    try:
        if settings.AI_PROVIDER == "openai" and settings.OPENAI_API_KEY:
            return await asyncio.wait_for(_call_openai_resume(payload), timeout=TIMEOUT_SECONDS)
        elif settings.AI_PROVIDER == "groq" and settings.GROQ_API_KEY:
            return await asyncio.wait_for(_call_groq_resume(payload), timeout=TIMEOUT_SECONDS)
        else:
            return generate_fallback_resume(payload)
    except (asyncio.TimeoutError, Exception) as err:
        logger.warning(f"LLM call failed or timed out ({err}). Falling back to deterministic engine.")
        return generate_fallback_resume(payload)

async def generate_skill_quiz(payload: QuizRequest) -> QuizResponse:
    if settings.AI_PROVIDER == "mock" or not settings.OPENAI_API_KEY and not settings.GROQ_API_KEY:
        logger.info("Using mock/fallback provider for quiz generation.")
        return generate_fallback_quiz(payload)
    
    try:
        if settings.AI_PROVIDER == "openai" and settings.OPENAI_API_KEY:
            return await asyncio.wait_for(_call_openai_quiz(payload), timeout=TIMEOUT_SECONDS)
        elif settings.AI_PROVIDER == "groq" and settings.GROQ_API_KEY:
            return await asyncio.wait_for(_call_groq_quiz(payload), timeout=TIMEOUT_SECONDS)
        else:
            return generate_fallback_quiz(payload)
    except (asyncio.TimeoutError, Exception) as err:
        logger.warning(f"LLM call failed or timed out ({err}). Falling back to deterministic quiz engine.")
        return generate_fallback_quiz(payload)

async def analyze_skill_gap(payload: SkillGapRequest) -> SkillGapResponse:
    if settings.AI_PROVIDER == "mock" or not settings.OPENAI_API_KEY and not settings.GROQ_API_KEY:
        logger.info("Using mock/fallback provider for skill gap analysis.")
        return generate_fallback_skill_gap(payload)
    
    try:
        if settings.AI_PROVIDER == "openai" and settings.OPENAI_API_KEY:
            return await asyncio.wait_for(_call_openai_skill_gap(payload), timeout=TIMEOUT_SECONDS)
        elif settings.AI_PROVIDER == "groq" and settings.GROQ_API_KEY:
            return await asyncio.wait_for(_call_groq_skill_gap(payload), timeout=TIMEOUT_SECONDS)
        else:
            return generate_fallback_skill_gap(payload)
    except (asyncio.TimeoutError, Exception) as err:
        logger.warning(f"LLM call failed or timed out ({err}). Falling back to deterministic skill gap engine.")
        return generate_fallback_skill_gap(payload)

# --- OpenAI Provider Implementation ---
async def _call_openai_resume(payload: ResumeRequest) -> ResumeResponse:
    prompt = f"""You are an ATS Resume Optimization AI. Generate a professional summary, 4 bullet points, and 4 suggested keywords for a student.
Target Role: {payload.target_role}
Verified Skills: {', '.join(payload.verified_skills)}
Bio: {payload.bio}

Strictly output valid JSON matching this schema:
{{
  "status": "success",
  "professional_summary": "string",
  "bullet_points": ["string", "string", "string", "string"],
  "suggested_keywords": ["string", "string", "string", "string"]
}}"""

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {settings.OPENAI_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": settings.OPENAI_MODEL,
                "messages": [{"role": "system", "content": "You are a professional ATS resume optimizer."}, {"role": "user", "content": prompt}],
                "response_format": {"type": "json_object"},
                "temperature": 0.3
            },
            timeout=TIMEOUT_SECONDS
        )
        data = resp.json()
        content = json.loads(data["choices"][0]["message"]["content"])
        return ResumeResponse(**content)

async def _call_openai_quiz(payload: QuizRequest) -> QuizResponse:
    prompt = f"""Generate {payload.num_questions} multiple-choice quiz questions for skill '{payload.skill_name}' at '{payload.difficulty}' difficulty.
Output valid JSON matching schema:
{{
  "status": "success",
  "skill_id": {payload.skill_id},
  "difficulty": "{payload.difficulty}",
  "questions": [
    {{
      "id": 1,
      "question": "string",
      "options": ["opt1", "opt2", "opt3", "opt4"],
      "correct_answer": 0,
      "explanation": "string"
    }}
  ]
}}"""

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {settings.OPENAI_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": settings.OPENAI_MODEL,
                "messages": [{"role": "system", "content": "You are a technical examiner."}, {"role": "user", "content": prompt}],
                "response_format": {"type": "json_object"},
                "temperature": 0.4
            },
            timeout=TIMEOUT_SECONDS
        )
        data = resp.json()
        content = json.loads(data["choices"][0]["message"]["content"])
        return QuizResponse(**content)

async def _call_openai_skill_gap(payload: SkillGapRequest) -> SkillGapResponse:
    prompt = f"""Analyze skill gaps for a student targeting role '{payload.target_role}'.
Current Skills: {', '.join(payload.current_skills)}

Output valid JSON matching schema:
{{
  "status": "success",
  "target_role": "{payload.target_role}",
  "readiness_score": 75,
  "missing_skills": ["Skill1", "Skill2"],
  "learning_path": [
    {{
      "skill": "Skill1",
      "priority": "High",
      "recommended_resource": "Resource link or name"
    }}
  ]
}}"""

    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {settings.OPENAI_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": settings.OPENAI_MODEL,
                "messages": [{"role": "system", "content": "You are an AI career guidance advisor."}, {"role": "user", "content": prompt}],
                "response_format": {"type": "json_object"},
                "temperature": 0.3
            },
            timeout=TIMEOUT_SECONDS
        )
        data = resp.json()
        content = json.loads(data["choices"][0]["message"]["content"])
        return SkillGapResponse(**content)

# --- Groq Provider Implementation ---
async def _call_groq_resume(payload: ResumeRequest) -> ResumeResponse:
    prompt = f"""Generate ATS Resume JSON for student. Target Role: {payload.target_role}, Skills: {', '.join(payload.verified_skills)}. Respond strictly in valid JSON object matching keys: status, professional_summary, bullet_points, suggested_keywords."""
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {settings.GROQ_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": settings.GROQ_MODEL,
                "messages": [{"role": "user", "content": prompt}],
                "response_format": {"type": "json_object"}
            },
            timeout=TIMEOUT_SECONDS
        )
        data = resp.json()
        content = json.loads(data["choices"][0]["message"]["content"])
        return ResumeResponse(**content)

async def _call_groq_quiz(payload: QuizRequest) -> QuizResponse:
    return generate_fallback_quiz(payload)

async def _call_groq_skill_gap(payload: SkillGapRequest) -> SkillGapResponse:
    return generate_fallback_skill_gap(payload)
