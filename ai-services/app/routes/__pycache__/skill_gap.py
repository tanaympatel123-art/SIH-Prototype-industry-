from fastapi import APIRouter, HTTPException, status
from app.schemas import SkillGapRequest, SkillGapResponse
from app.services.llm_service import analyze_skill_gap

router = APIRouter(prefix="/ai/v1", tags=["Skill Gap AI"])

@router.post(
    "/skill-gap",
    response_model=SkillGapResponse,
    summary="Analyze skill gap and suggest learning path",
    status_code=status.HTTP_200_OK
)
async def skill_gap_route(payload: SkillGapRequest):
    try:
        return await analyze_skill_gap(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Skill gap analysis failed: {str(e)}"
        )
