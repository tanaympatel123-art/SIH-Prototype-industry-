from fastapi import APIRouter, HTTPException, status
from app.schemas import QuizRequest, QuizResponse
from app.services.llm_service import generate_skill_quiz

router = APIRouter(prefix="/ai/v1", tags=["Quiz AI"])

@router.post(
    "/generate-quiz",
    response_model=QuizResponse,
    summary="Generate dynamic skill quiz questions",
    status_code=status.HTTP_200_OK
)
async def generate_quiz_route(payload: QuizRequest):
    try:
        return await generate_skill_quiz(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Quiz generation failed: {str(e)}"
        )
