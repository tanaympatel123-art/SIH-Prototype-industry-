-- Query 2: Opportunity List & Search
-- SIH26044: Academia-Industry Collaboration Portal
-- Purpose: Browses active job & internship listings with employer info and aggregated required skills

SELECT 
    o.id AS opportunity_id,
    o.title,
    o.opportunity_type,
    o.work_mode,
    o.location,
    o.stipend,
    o.currency,
    o.duration_months,
    o.openings,
    o.deadline,
    o.status,
    cp.company_name,
    cp.headquarters,
    cp.verification_status,
    json_agg(
        json_build_object(
            'skill_name', s.name,
            'required_proficiency', os.required_proficiency,
            'is_mandatory', os.is_mandatory,
            'weight', os.skill_weight
        ) ORDER BY os.is_mandatory DESC, os.skill_weight DESC
    ) AS required_skills
FROM opportunities o
JOIN company_profiles cp ON o.company_id = cp.id
JOIN opportunity_skills os ON os.opportunity_id = o.id
JOIN skills s ON os.skill_id = s.id
WHERE o.status = 'active' 
  AND o.deadline > NOW()
GROUP BY o.id, cp.company_name, cp.headquarters, cp.verification_status
ORDER BY o.created_at DESC;
