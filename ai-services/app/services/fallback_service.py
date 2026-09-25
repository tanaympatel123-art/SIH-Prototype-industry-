"""
Fallback Service - Deterministic & High-Speed Local AI Engine.
Guarantees sub-10ms response times for all AI features when external LLMs are offline,
timing out (>2500ms), or when running in local offline/mock mode.
"""

from typing import List, Dict, Any
from app.schemas import (
    ResumeRequest, ResumeResponse,
    QuizRequest, QuizResponse, QuestionItem,
    SkillGapRequest, SkillGapResponse, LearningItem
)

# Standard Skill Taxonomy & Learning Resources
ROLE_SKILL_REQUIREMENTS: Dict[str, List[str]] = {
    "frontend developer": ["HTML5", "CSS3", "JavaScript", "React.js", "TypeScript", "Git", "REST APIs"],
    "backend developer": ["Node.js", "Express.js", "Python", "SQL", "MySQL", "REST APIs", "Docker", "Git"],
    "full stack developer": ["HTML5", "CSS3", "JavaScript", "React.js", "Node.js", "Express.js", "SQL", "Git"],
    "data scientist": ["Python", "SQL", "Pandas", "NumPy", "Scikit-Learn", "Machine Learning", "Data Visualization"],
    "ai/ml engineer": ["Python", "PyTorch", "TensorFlow", "Deep Learning", "NLP", "Machine Learning", "Docker", "Git"],
    "devops engineer": ["Linux", "Docker", "Kubernetes", "CI/CD", "AWS", "Git", "Bash", "Terraform"]
}

DEFAULT_RESOURCES: Dict[str, str] = {
    "react.js": "NPTEL React & Frontend Web Development / React Official Docs",
    "node.js": "Node.js Developer Guide & FreeCodeCamp Masterclass",
    "python": "Python for Everybody (Coursera) / Official Tutorial",
    "sql": "SQL for Data Science (NPTEL) / Khan Academy SQL Course",
    "typescript": "TypeScript Handbook / Execute Program Interactive TS",
    "docker": "Docker Mastery on Udemy / Official Docker Docs",
    "git": "Pro Git Book / GitHub Skills Interactive Tutorials"
}

def generate_fallback_resume(payload: ResumeRequest) -> ResumeResponse:
    target = payload.target_role.strip().title()
    skills = payload.verified_skills or ["Problem Solving", "Software Engineering", "Version Control"]
    skills_str = ", ".join(skills)
    
    bio_text = f" {payload.bio.strip()}" if payload.bio and len(payload.bio.strip()) > 5 else ""
    
    summary = (
        f"Driven and results-oriented {target} with verified proficiency in {skills_str}.{bio_text} "
        f"Adept at applying best practices in modern software design and collaborative problem-solving."
    )
    
    bullet_points = [
        f"Engineered key components for web and software applications utilizing {skills[0] if skills else 'modern frameworks'}.",
        f"Demonstrated verified mastery in {skills_str}, achieving high performance and clean code standards.",
        f"Collaborated on academic and industry-aligned projects to design scalable, user-centric solutions.",
        f"Utilized industry-standard version control and agile methodologies to streamline feature delivery."
    ]
    
    role_key = payload.target_role.lower()
    expected = ROLE_SKILL_REQUIREMENTS.get(role_key, ["Git", "REST APIs", "Testing", "CI/CD"])
    suggested_keywords = [s for s in expected if s not in skills][:4]
    if not suggested_keywords:
        suggested_keywords = ["Agile Methodologies", "System Design", "Unit Testing", "CI/CD"]
        
    return ResumeResponse(
        status="success",
        professional_summary=summary,
        bullet_points=bullet_points,
        suggested_keywords=suggested_keywords
    )

def generate_fallback_quiz(payload: QuizRequest) -> QuizResponse:
    skill = payload.skill_name.strip()
    diff = payload.difficulty.lower()
    
    # Generic template generator customized per skill & difficulty
    questions = []
    
    template_bank = [
        {
            "q": f"What is a fundamental core concept of {skill}?",
            "opts": [
                f"Declarative structure and component lifecycle management in {skill}",
                f"Direct low-level memory allocation in C syntax",
                f"Operating system kernel configuration",
                f"Analog signal processing"
            ],
            "ans": 0,
            "exp": f"{skill} focuses on component architecture, state management, and high-level abstractions."
        },
        {
            "q": f"When optimizing performance in {skill}, which strategy is recommended for {diff} level tasks?",
            "opts": [
                "Ignoring memory consumption entirely",
                "Utilizing proper state immutability, caching, and efficient DOM/data structures",
                "Recompiling the kernel on every function execution",
                "Disabling static type safety checks"
            ],
            "ans": 1,
            "exp": "Performance optimization requires caching, avoiding redundant operations, and maintaining state integrity."
        },
        {
            "q": f"Which tool or feature is commonly associated with modern {skill} workflows?",
            "opts": [
                "COBOL compilers",
                "Pipes & Filter architecture",
                f"Package managers and standard tooling ecosystems for {skill}",
                "Manual punch-card input"
            ],
            "ans": 2,
            "exp": f"Modern {skill} environments rely on modular package ecosystems and build tooling."
        },
        {
            "q": f"What is the best practice for handling asynchronous operations or state in {skill}?",
            "opts": [
                "Synchronous blocking loops on the main UI execution thread",
                "Using non-blocking async primitives, promises, or reactive state subscriptions",
                "Hardcoding arbitrary sleep calls",
                "Relying on hardware interrupts"
            ],
            "ans": 1,
            "exp": "Non-blocking async handlers prevent main thread starvation and ensure responsive execution."
        },
        {
            "q": f"In a production deployment using {skill}, how should unexpected errors be managed?",
            "opts": [
                "Silent failures without logging",
                "Crashing the application process immediately",
                "Structured exception handling, logging, and graceful degradation",
                "Writing errors to global static variables"
            ],
            "ans": 2,
            "exp": "Graceful error handling ensures resilience, observability, and smooth user experience."
        }
    ]
    
    count = min(payload.num_questions, len(template_bank))
    for idx in range(count):
        item = template_bank[idx]
        questions.append(QuestionItem(
            id=idx + 1,
            question=item["q"],
            options=item["opts"],
            correct_answer=item["ans"],
            explanation=item["exp"]
        ))
        
    return QuizResponse(
        status="success",
        skill_id=payload.skill_id,
        difficulty=payload.difficulty,
        questions=questions
    )

def generate_fallback_skill_gap(payload: SkillGapRequest) -> SkillGapResponse:
    target_role_lower = payload.target_role.lower().strip()
    current_skills_normalized = [s.lower().strip() for s in payload.current_skills]
    
    # Required skills lookup
    required_skills = ROLE_SKILL_REQUIREMENTS.get(
        target_role_lower, 
        ["Problem Solving", "Version Control", "System Design", "Database Management", "API Integration"]
    )
    
    missing_skills = []
    for req in required_skills:
        if not any(req.lower() in curr for curr in current_skills_normalized):
            missing_skills.append(req)
            
    # Calculate readiness score
    total_req = len(required_skills)
    matched_count = total_req - len(missing_skills)
    readiness_score = int((matched_count / total_req) * 100) if total_req > 0 else 50
    # Bound between 10% and 95%
    readiness_score = max(15, min(95, readiness_score))
    
    learning_path = []
    for idx, skill in enumerate(missing_skills):
        skill_key = skill.lower()
        resource = DEFAULT_RESOURCES.get(skill_key, f"NPTEL / Coursera Certification Path for {skill}")
        priority = "High" if idx < 2 else ("Medium" if idx < 4 else "Low")
        learning_path.append(LearningItem(
            skill=skill,
            priority=priority,
            recommended_resource=resource
        ))
        
    return SkillGapResponse(
        status="success",
        target_role=payload.target_role.title(),
        readiness_score=readiness_score,
        missing_skills=missing_skills,
        learning_path=learning_path
    )
