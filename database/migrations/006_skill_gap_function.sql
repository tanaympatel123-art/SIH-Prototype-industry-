-- Migration 006: Automated Skill Match & Skill Gap Calculation Function
-- SIH26044: Academia-Industry Collaboration Portal

CREATE OR REPLACE FUNCTION calculate_skill_match(
    p_student_id UUID,
    p_opportunity_id UUID
)
RETURNS TABLE (
    match_score NUMERIC,
    matched_skills TEXT[],
    missing_skills TEXT[]
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_required INT;
    v_matched_count INT;
    v_matched TEXT[];
    v_missing TEXT[];
    v_score NUMERIC(5,2);
BEGIN
    -- 1. Get skills that student possesses from the required list
    SELECT 
        COALESCE(array_agg(s.name), ARRAY[]::TEXT[]),
        COUNT(s.id)
    INTO v_matched, v_matched_count
    FROM opportunity_skills os
    JOIN skills s ON os.skill_id = s.id
    JOIN student_skills ss ON ss.skill_id = os.skill_id AND ss.student_id = p_student_id;

    -- 2. Get missing skills (required by opportunity but not possessed by student)
    SELECT 
        COALESCE(array_agg(s.name), ARRAY[]::TEXT[])
    INTO v_missing
    FROM opportunity_skills os
    JOIN skills s ON os.skill_id = s.id
    WHERE os.skill_id NOT IN (
        SELECT ss.skill_id 
        FROM student_skills ss 
        WHERE ss.student_id = p_student_id
    )
    AND os.opportunity_id = p_opportunity_id;

    -- 3. Total required skills
    SELECT COUNT(*) INTO v_total_required
    FROM opportunity_skills
    WHERE opportunity_id = p_opportunity_id;

    -- 4. Calculate Percentage Score
    IF v_total_required = 0 THEN
        v_score := 100.00;
    ELSE
        v_score := ROUND((v_matched_count::NUMERIC / v_total_required::NUMERIC) * 100, 2);
    END IF;

    RETURN QUERY SELECT v_score, v_matched, v_missing;
END;
$$;
