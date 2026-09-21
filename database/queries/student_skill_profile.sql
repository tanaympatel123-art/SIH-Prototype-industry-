-- Query 1: Student Skill Profile
-- SIH26044: Academia-Industry Collaboration Portal
-- Purpose: Fetches complete student academic identity, college, and their verified & self-reported skills

SELECT 
    sp.id AS student_profile_id,
    sp.first_name,
    sp.last_name,
    sp.roll_number,
    sp.department,
    sp.current_semester,
    sp.cgpa,
    sp.graduation_year,
    sp.headline,
    inst.name AS college_name,
    inst.city AS college_city,
    u.email,
    s.name AS skill_name,
    sc.name AS skill_category,
    ps.name AS parent_skill,
    ss.proficiency,
    ss.is_verified,
    ss.assessment_score,
    ss.source,
    ss.confidence_score,
    ss.last_updated_at
FROM student_profiles sp
JOIN institutions inst ON sp.institution_id = inst.id
JOIN users u ON sp.user_id = u.id
JOIN student_skills ss ON ss.student_id = sp.id
JOIN skills s ON ss.skill_id = s.id
JOIN skill_categories sc ON s.category_id = sc.id
LEFT JOIN skills ps ON s.parent_skill_id = ps.id
WHERE u.email = 'rahul.sharma@dtu.ac.in'
ORDER BY ss.is_verified DESC, ss.proficiency DESC, s.name ASC;
