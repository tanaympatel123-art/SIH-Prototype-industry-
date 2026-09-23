from fastapi import APIRouter, HTTPException, status
from app.schemas import ResumeRequest, ResumeResponse
from app.services.llm_service import generate_optimized_resume

router = APIRouter(prefix="/ai/v1", tags=["Resume AI"])

@router.post(
    "/optimize-resume",
    response_model=ResumeResponse,
    summary="Generate ATS-optimized resume summary and bullet points",
    status_code=status.HTTP_200_OK
)
async def optimize_resume_route(payload: ResumeRequest):
    try:
        return await generate_optimized_resume(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Resume optimization failed: {str(e)}"
        )
