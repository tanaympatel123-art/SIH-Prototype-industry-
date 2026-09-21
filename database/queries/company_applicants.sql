-- Query 4: Company Ranked Applicants Leaderboard
-- SIH26044: Academia-Industry Collaboration Portal
-- Purpose: Recruiter dashboard view displaying candidates for an opportunity ordered by match score

SELECT 
    o.title AS opportunity_title,
    a.id AS application_id,
    a.match_score,
    a.status AS application_status,
    a.applied_at,
    sp.id AS student_id,
    CONCAT(sp.first_name, ' ', sp.last_name) AS applicant_name,
    sp.roll_number,
    sp.department,
    sp.cgpa,
    sp.graduation_year,
    inst.name AS college_name,
    u.email AS student_email,
    COALESCE(
        json_agg(
            json_build_object(
                'skill', s.name,
                'proficiency', ss.proficiency,
                'is_verified', ss.is_verified,
                'score', ss.assessment_score
            )
        ) FILTER (WHERE s.id IS NOT NULL),
        '[]'::json
    ) AS student_skills
FROM applications a
JOIN opportunities o ON a.opportunity_id = o.id
JOIN company_profiles cp ON o.company_id = cp.id
JOIN student_profiles sp ON a.student_id = sp.id
JOIN institutions inst ON sp.institution_id = inst.id
JOIN users u ON sp.user_id = u.id
LEFT JOIN student_skills ss ON ss.student_id = sp.id
LEFT JOIN skills s ON ss.skill_id = s.id
WHERE cp.company_name = 'TechCorp Solutions'
  AND o.title = 'Backend Developer Intern'
GROUP BY o.title, a.id, a.match_score, a.status, a.applied_at, sp.id, sp.first_name, sp.last_name, sp.roll_number, sp.department, sp.cgpa, sp.graduation_year, inst.name, u.email
ORDER BY a.match_score DESC, a.applied_at ASC;
