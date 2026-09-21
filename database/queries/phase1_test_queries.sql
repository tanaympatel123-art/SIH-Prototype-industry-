-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Test & Verification Queries
-- File: phase1_test_queries.sql
-- Target Environment: MySQL 8.x / MariaDB (XAMPP / phpMyAdmin / MySQL CLI)
-- ==============================================================================

USE sih26044_db;

-- ------------------------------------------------------------------------------
-- QUERY 1: User Authentication & Role Resolution
-- Purpose: Simulates login query resolving role identity and profile linkage
-- ------------------------------------------------------------------------------
SELECT 
    u.id AS user_id,
    u.email,
    u.is_active,
    r.name AS role_name,
    COALESCE(
        CONCAT(sp.first_name, ' ', sp.last_name),
        cp.company_name,
        CONCAT(tp.first_name, ' ', tp.last_name),
        'Administrator'
    ) AS display_name,
    CASE 
        WHEN r.name = 'student' THEN sp.institution
        WHEN r.name = 'teacher' THEN tp.institution
        WHEN r.name = 'company' THEN cp.industry
        ELSE 'System Operations'
    END AS contextual_organization
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN student_profiles sp ON u.id = sp.user_id
LEFT JOIN company_profiles cp ON u.id = cp.user_id
LEFT JOIN teacher_profiles tp ON u.id = tp.user_id
ORDER BY u.id ASC;

-- ------------------------------------------------------------------------------
-- QUERY 2: Student Complete Skill Profile & Verification Status
-- Purpose: Displays a student's full skill portfolio including teacher endorsements
-- ------------------------------------------------------------------------------
SELECT 
    CONCAT(sp.first_name, ' ', sp.last_name) AS student_name,
    sp.student_identifier,
    sp.institution,
    s.skill_name,
    s.category AS skill_category,
    parent_s.skill_name AS parent_skill,
    ss.proficiency_level,
    ss.proficiency_score,
    ss.source AS provenance,
    ss.is_verified,
    sv.verification_status,
    CONCAT(tp.first_name, ' ', tp.last_name) AS verified_by_teacher,
    sv.evidence_type,
    sv.remarks AS teacher_remarks
FROM student_profiles sp
JOIN student_skills ss ON sp.id = ss.student_id
JOIN skills s ON ss.skill_id = s.id
LEFT JOIN skills parent_s ON s.parent_skill_id = parent_s.id
LEFT JOIN skill_verifications sv ON ss.id = sv.student_skill_id
LEFT JOIN teacher_profiles tp ON sv.verifier_teacher_id = tp.id
WHERE sp.id = 1 -- Aarav Sharma
ORDER BY ss.is_verified DESC, s.skill_name ASC;

-- ------------------------------------------------------------------------------
-- QUERY 3: Published Opportunities & Required Skills Directory
-- Purpose: Student-facing discovery query showing opportunities and skill requirements
-- ------------------------------------------------------------------------------
SELECT 
    o.id AS opportunity_id,
    o.title,
    cp.company_name,
    o.opportunity_type,
    o.work_mode,
    o.location,
    o.stipend_salary,
    o.application_deadline,
    COUNT(os.id) AS total_skills_required,
    SUM(CASE WHEN os.is_mandatory = TRUE THEN 1 ELSE 0 END) AS mandatory_skills_count,
    GROUP_CONCAT(
        CONCAT(s.skill_name, ' (', os.required_proficiency_level, IF(os.is_mandatory, '*', ''), ')')
        SEPARATOR ', '
    ) AS required_skills_list
FROM opportunities o
JOIN company_profiles cp ON o.company_id = cp.id
JOIN opportunity_skills os ON o.id = os.opportunity_id
JOIN skills s ON os.skill_id = s.id
WHERE o.status = 'published'
GROUP BY o.id, o.title, cp.company_name, o.opportunity_type, o.work_mode, o.location, o.stipend_salary, o.application_deadline
ORDER BY o.application_deadline ASC;

-- ------------------------------------------------------------------------------
-- QUERY 4: Candidate Matching Engine (Mandatory Skill Coverage)
-- Purpose: Calculates candidate skill compatibility against Opportunity #1 (Python Dev Intern)
-- ------------------------------------------------------------------------------
SELECT 
    sp.id AS student_id,
    CONCAT(sp.first_name, ' ', sp.last_name) AS student_name,
    sp.institution,
    sp.cgpa,
    COUNT(DISTINCT req.skill_id) AS mandatory_skills_required,
    COUNT(DISTINCT cand.skill_id) AS mandatory_skills_matched,
    ROUND((COUNT(DISTINCT cand.skill_id) / COUNT(DISTINCT req.skill_id)) * 100, 1) AS match_percentage
FROM student_profiles sp
-- Get all mandatory skills for Opportunity 1
CROSS JOIN (
    SELECT skill_id 
    FROM opportunity_skills 
    WHERE opportunity_id = 1 AND is_mandatory = TRUE
) req
-- Check if student possesses the required skill
LEFT JOIN student_skills cand ON sp.id = cand.student_id AND req.skill_id = cand.skill_id
GROUP BY sp.id, sp.first_name, sp.last_name, sp.institution, sp.cgpa
ORDER BY match_percentage DESC, sp.cgpa DESC;

-- ------------------------------------------------------------------------------
-- QUERY 5: Recruiter Application Tracking Pipeline
-- Purpose: Company view of applicants for Opportunity #1 with pipeline stages
-- ------------------------------------------------------------------------------
SELECT 
    a.id AS application_id,
    o.title AS opportunity_title,
    CONCAT(sp.first_name, ' ', sp.last_name) AS applicant_name,
    sp.student_identifier,
    sp.institution,
    sp.cgpa,
    a.application_status,
    a.applied_at,
    a.resume_reference,
    a.company_notes
FROM applications a
JOIN opportunities o ON a.opportunity_id = o.id
JOIN student_profiles sp ON a.student_id = sp.id
WHERE o.id = 1
ORDER BY FIELD(a.application_status, 'selected', 'interview', 'shortlisted', 'applied', 'rejected', 'withdrawn'), a.applied_at ASC;

-- ------------------------------------------------------------------------------
-- QUERY 6: Teacher Pending Verification Worklist
-- Purpose: Faculty dashboard displaying students awaiting manual skill verification
-- ------------------------------------------------------------------------------
SELECT 
    sv.id AS verification_id,
    CONCAT(sp.first_name, ' ', sp.last_name) AS student_name,
    sp.student_identifier,
    sp.institution,
    s.skill_name,
    ss.proficiency_level,
    ss.source AS claim_source,
    sv.evidence_type,
    sv.evidence_reference,
    sv.confidence_score,
    sv.verification_status,
    CONCAT(tp.first_name, ' ', tp.last_name) AS assigned_faculty
FROM skill_verifications sv
JOIN student_skills ss ON sv.student_skill_id = ss.id
JOIN skills s ON ss.skill_id = s.id
JOIN student_profiles sp ON ss.student_id = sp.id
JOIN teacher_profiles tp ON sv.verifier_teacher_id = tp.id
WHERE sv.verification_status = 'pending'
ORDER BY sv.created_at ASC;

-- ------------------------------------------------------------------------------
-- QUERY 7: Faculty Verification Audit History
-- Purpose: Complete compliance and accreditation log of verified/rejected competencies
-- ------------------------------------------------------------------------------
SELECT 
    sv.id AS verification_id,
    CONCAT(tp.first_name, ' ', tp.last_name) AS teacher_name,
    tp.department AS teacher_department,
    CONCAT(sp.first_name, ' ', sp.last_name) AS student_name,
    s.skill_name,
    sv.verification_status,
    sv.evidence_type,
    sv.remarks,
    sv.verified_at
FROM skill_verifications sv
JOIN student_skills ss ON sv.student_skill_id = ss.id
JOIN skills s ON ss.skill_id = s.id
JOIN student_profiles sp ON ss.student_id = sp.id
JOIN teacher_profiles tp ON sv.verifier_teacher_id = tp.id
WHERE sv.verification_status IN ('approved', 'rejected')
ORDER BY sv.verified_at DESC;

-- ------------------------------------------------------------------------------
-- QUERY 8: System Integrity & Row Count Audit
-- Purpose: Quick statistical health check of all Phase 1 core tables
-- ------------------------------------------------------------------------------
SELECT 'roles' AS entity_table, COUNT(*) AS total_records FROM roles
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'student_profiles', COUNT(*) FROM student_profiles
UNION ALL SELECT 'company_profiles', COUNT(*) FROM company_profiles
UNION ALL SELECT 'teacher_profiles', COUNT(*) FROM teacher_profiles
UNION ALL SELECT 'skills', COUNT(*) FROM skills
UNION ALL SELECT 'student_skills', COUNT(*) FROM student_skills
UNION ALL SELECT 'skill_verifications', COUNT(*) FROM skill_verifications
UNION ALL SELECT 'opportunities', COUNT(*) FROM opportunities
UNION ALL SELECT 'opportunity_skills', COUNT(*) FROM opportunity_skills
UNION ALL SELECT 'applications', COUNT(*) FROM applications;
