import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.schemas import HealthResponse
from app.routes.resume import router as resume_router
from app.routes.quiz import router as quiz_router
from app.routes.skill_gap import router as skill_gap_router

app = FastAPI(
    title="SIH26044 AI Engine Microservice",
    description="Dedicated FastAPI AI microservice serving Resume Optimization, Dynamic Quizzes, and Skill Gap Analysis for Academia-Industry Portal.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS for Node.js Express Backend & local dev tools
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Health Endpoint required by Express Backend Circuit Breaker
@app.get("/health", response_model=HealthResponse, tags=["Health Check"])
def health_check():
    return HealthResponse(
        status="healthy",
        service="SIH26044 AI Engine",
        version="1.0.0",
        ai_provider=settings.AI_PROVIDER
    )

# Include Router Modules
app.include_router(resume_router)
app.include_router(quiz_router)
app.include_router(skill_gap_router)

@app.get("/", include_in_schema=False)
def root():
    return {
        "message": "SIH26044 AI Engine is online.",
        "health": "/health",
        "docs": "/docs"
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True if settings.ENVIRONMENT == "development" else False
    )
