-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 2: EXPLAIN ANALYZE Benchmark Queries
-- File: phase2_benchmark_queries.sql
-- Target: MySQL 8.x — run AFTER phase2_expanded_seed.sql
-- Purpose: Prove compound index effectiveness via EXPLAIN output
-- ==============================================================================
-- HOW TO READ THESE RESULTS:
--   type = ref     → Index range scan (GOOD)
--   type = eq_ref  → Unique index lookup (EXCELLENT)
--   type = ALL     → Full table scan (BAD — should not appear after Phase 2)
--   Extra: Using index → Covering index — no row lookup needed (BEST)
-- ==============================================================================

USE sih26044_db;

-- ==============================================================================
-- BENCHMARK QUERY 1: MatchScore Engine — Mandatory Skill Coverage
-- Retrieves how many mandatory skills each student has for Opportunity #14
-- (PhonePe SDE-I — high-demand role with 2 mandatory skills)
--
-- EXPECTED EXPLAIN:
--   opportunity_skills  → type=ref, key=idx_os_opportunity_mandatory_skill, Extra: Using index
--   student_skills      → type=ref, key=idx_ss_student_verified_proficiency, Extra: Using index
--   No filesort on mandatory_skills_matched
-- ==============================================================================

EXPLAIN
SELECT
    sp.id                                               AS student_id,
    CONCAT(sp.first_name, ' ', sp.last_name)            AS student_name,
    sp.institution,
    sp.cgpa,
    COUNT(DISTINCT req.skill_id)                        AS mandatory_skills_required,
    COUNT(DISTINCT cand.skill_id)                       AS mandatory_skills_matched,
    ROUND(
        (COUNT(DISTINCT cand.skill_id) / NULLIF(COUNT(DISTINCT req.skill_id), 0)) * 100,
        1
    )                                                   AS match_pct
FROM student_profiles sp
CROSS JOIN (
    -- Pull mandatory skills for the target opportunity — uses idx_os_opportunity_mandatory_skill
    SELECT skill_id
    FROM   opportunity_skills
    WHERE  opportunity_id = 14
      AND  is_mandatory   = TRUE
) req
LEFT JOIN (
    -- Pull student's verified skills — uses idx_ss_student_verified_proficiency
    SELECT student_id, skill_id
    FROM   student_skills
    WHERE  is_verified = TRUE
) cand ON sp.id = cand.student_id AND req.skill_id = cand.skill_id
GROUP BY sp.id, sp.first_name, sp.last_name, sp.institution, sp.cgpa
ORDER BY match_pct DESC, sp.cgpa DESC;

-- Run the query (no EXPLAIN) to see actual results:
SELECT
    sp.id                                               AS student_id,
    CONCAT(sp.first_name, ' ', sp.last_name)            AS student_name,
    sp.institution,
    sp.cgpa,
    COUNT(DISTINCT req.skill_id)                        AS mandatory_skills_required,
    COUNT(DISTINCT cand.skill_id)                       AS mandatory_skills_matched,
    ROUND(
        (COUNT(DISTINCT cand.skill_id) / NULLIF(COUNT(DISTINCT req.skill_id), 0)) * 100,
        1
    )                                                   AS match_pct
FROM student_profiles sp
CROSS JOIN (
    SELECT skill_id FROM opportunity_skills
    WHERE  opportunity_id = 14 AND is_mandatory = TRUE
) req
LEFT JOIN (
    SELECT student_id, skill_id FROM student_skills WHERE is_verified = TRUE
) cand ON sp.id = cand.student_id AND req.skill_id = cand.skill_id
GROUP BY sp.id, sp.first_name, sp.last_name, sp.institution, sp.cgpa
ORDER BY match_pct DESC, sp.cgpa DESC
LIMIT 10;

-- ==============================================================================
-- BENCHMARK QUERY 2: Recruiter Applicant Pipeline — Application Status View
-- Shows all applicants for Opportunity #5 (Zomato ML Engineer) sorted by stage
--
-- EXPECTED EXPLAIN:
--   applications → type=ref, key=idx_app_opportunity_status_student, Extra: Using index
--   student_profiles → type=eq_ref (PK lookup — fast)
--   No filesort: ORDER BY application_status resolved from index
-- ==============================================================================

EXPLAIN
SELECT
    a.id                                            AS application_id,
    CONCAT(sp.first_name, ' ', sp.last_name)        AS applicant_name,
    sp.institution,
    sp.cgpa,
    a.application_status,
    a.applied_at,
    a.company_notes
FROM applications a
JOIN student_profiles sp ON a.student_id = sp.id
WHERE  a.opportunity_id = 5
ORDER BY FIELD(a.application_status, 'selected','interview','shortlisted','applied','rejected','withdrawn'),
         a.applied_at ASC;

-- Run actual query:
SELECT
    a.id                                            AS application_id,
    CONCAT(sp.first_name, ' ', sp.last_name)        AS applicant_name,
    sp.institution,
    sp.cgpa,
    a.application_status,
    a.applied_at,
    a.company_notes
FROM applications a
JOIN student_profiles sp ON a.student_id = sp.id
WHERE  a.opportunity_id = 5
ORDER BY FIELD(a.application_status, 'selected','interview','shortlisted','applied','rejected','withdrawn'),
         a.applied_at ASC;

-- ==============================================================================
-- BENCHMARK QUERY 3: Teacher Workqueue — Pending Verification Worklist
-- Shows all pending verifications assigned to Teacher 1 (Dr. Rajesh Verma)
--
-- EXPECTED EXPLAIN:
--   skill_verifications → type=ref, key=idx_sv_teacher_status_skill, Extra: Using index
--   student_skills     → type=eq_ref (PK join — fast)
--   No full scan on skill_verifications
-- ==============================================================================

EXPLAIN
SELECT
    sv.id                                           AS verification_id,
    CONCAT(sp.first_name, ' ', sp.last_name)        AS student_name,
    sp.student_identifier,
    s.skill_name,
    ss.proficiency_level,
    sv.evidence_type,
    sv.created_at                                   AS requested_at
FROM skill_verifications sv
JOIN student_skills   ss ON sv.student_skill_id   = ss.id
JOIN skills            s ON ss.skill_id           = s.id
JOIN student_profiles sp ON ss.student_id         = sp.id
WHERE  sv.verifier_teacher_id = 1
  AND  sv.verification_status = 'pending'
ORDER BY sv.created_at ASC;

-- Run actual query:
SELECT
    sv.id                                           AS verification_id,
    CONCAT(sp.first_name, ' ', sp.last_name)        AS student_name,
    sp.student_identifier,
    s.skill_name,
    ss.proficiency_level,
    sv.evidence_type,
    sv.created_at                                   AS requested_at
FROM skill_verifications sv
JOIN student_skills   ss ON sv.student_skill_id   = ss.id
JOIN skills            s ON ss.skill_id           = s.id
JOIN student_profiles sp ON ss.student_id         = sp.id
WHERE  sv.verifier_teacher_id = 1
  AND  sv.verification_status = 'pending'
ORDER BY sv.created_at ASC;

-- ==============================================================================
-- BONUS BENCHMARK: Opportunity Discovery — Published Opps by Deadline
-- Tests idx_opp_status_deadline_company
--
-- EXPECTED EXPLAIN:
--   opportunities → type=ref, key=idx_opp_status_deadline_company, Extra: Using index
--   No filesort for ORDER BY application_deadline (range scan in index order)
-- ==============================================================================

EXPLAIN
SELECT
    o.id,
    o.title,
    cp.company_name,
    o.opportunity_type,
    o.work_mode,
    o.stipend_salary,
    o.application_deadline,
    o.openings
FROM opportunities o
JOIN company_profiles cp ON o.company_id = cp.id
WHERE  o.status = 'published'
ORDER BY o.application_deadline ASC;

-- Run actual:
SELECT
    o.id,
    o.title,
    cp.company_name,
    o.opportunity_type,
    o.work_mode,
    o.stipend_salary,
    o.application_deadline,
    o.openings
FROM opportunities o
JOIN company_profiles cp ON o.company_id = cp.id
WHERE  o.status = 'published'
ORDER BY o.application_deadline ASC;

SELECT 'Phase 2 — Benchmark Queries executed successfully.' AS benchmark_status;
