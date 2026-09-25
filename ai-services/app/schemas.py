from pydantic import BaseModel, Field
from typing import List, Optional

# Health Check Schemas
class HealthResponse(BaseModel):
    status: str = "healthy"
    service: str = "SIH26044 AI Engine"
    version: str = "1.0.0"
    ai_provider: str = "mock"

# Resume Optimization Schemas
class ResumeRequest(BaseModel):
    student_id: int = Field(..., description="ID of the student")
    target_role: str = Field(..., description="Target job role")
    verified_skills: List[str] = Field(default=[], description="List of teacher-verified skills")
    bio: Optional[str] = Field(default="", description="Student personal summary or bio")

class ResumeResponse(BaseModel):
    status: str = "success"
    professional_summary: str
    bullet_points: List[str]
    suggested_keywords: List[str]

# Dynamic Quiz Generator Schemas
class QuizRequest(BaseModel):
    skill_id: int = Field(..., description="ID of the skill")
    skill_name: str = Field(..., description="Name of the skill")
    difficulty: str = Field(default="medium", description="Difficulty level: easy, medium, hard")
    num_questions: int = Field(default=5, description="Number of questions to generate")

class QuestionItem(BaseModel):
    id: int
    question: str
    options: List[str]
    correct_answer: int = Field(..., description="0-indexed correct option index")
    explanation: str

class QuizResponse(BaseModel):
    status: str = "success"
    skill_id: int
    difficulty: str
    questions: List[QuestionItem]

# Skill Gap Analysis Schemas
class SkillGapRequest(BaseModel):
    student_id: int = Field(..., description="ID of the student")
    current_skills: List[str] = Field(..., description="List of currently acquired skills")
    target_role: str = Field(..., description="Target industry role")

class LearningItem(BaseModel):
    skill: str
    priority: str
    recommended_resource: str

class SkillGapResponse(BaseModel):
    status: str = "success"
    target_role: str
    readiness_score: int
    missing_skills: List[str]
    learning_path: List[LearningItem]
