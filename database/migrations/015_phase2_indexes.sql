-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 2: Compound & Covering Indexes for MatchScore Engine
-- File: 015_phase2_indexes.sql
-- Target: MySQL 8.x (InnoDB) — XAMPP / phpMyAdmin / MySQL CLI
-- Branch: database/phase-2-optimization
-- ==============================================================================
--
-- STRATEGY:
--   The MatchScore Engine performs three JOIN-heavy queries on every candidate
--   search. Without compound indexes, MySQL falls back to full scans on the
--   junction tables which grow as O(students × skills × opportunities).
--
--   Each index below is justified by EXPLAIN output and query-plan analysis.
-- ==============================================================================

USE sih26044_db;

-- ==============================================================================
-- INDEX 1: Compound covering index on student_skills
--          (student_id, skill_id, is_verified, proficiency_level)
--
-- JUSTIFIES: MatchScore JOIN: student_skills → skills → opportunity_skills
-- QUERY PATTERN:
--   SELECT skill_id, is_verified, proficiency_level
--   FROM   student_skills
--   WHERE  student_id = ? AND is_verified = TRUE
--
-- WHY COMPOUND: MySQL can resolve the WHERE + SELECT entirely from the index
-- leaf page (covering index). No table row lookup needed. BIG win on large
-- student cohorts.
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_ss_student_verified_proficiency
    ON student_skills (student_id, is_verified, proficiency_level, skill_id)
    COMMENT 'Covering index for MatchScore: filter verified skills per student';

-- ==============================================================================
-- INDEX 2: Compound covering index on opportunity_skills
--          (opportunity_id, is_mandatory, skill_id, required_proficiency_level)
--
-- JUSTIFIES: MatchScore requirement fetch per opportunity
-- QUERY PATTERN:
--   SELECT skill_id, required_proficiency_level
--   FROM   opportunity_skills
--   WHERE  opportunity_id = ? AND is_mandatory = TRUE
--
-- WHY COMPOUND: Mandatory skill resolution for a single opportunity is the
-- innermost sub-query of every match score calculation.
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_os_opportunity_mandatory_skill
    ON opportunity_skills (opportunity_id, is_mandatory, skill_id, required_proficiency_level)
    COMMENT 'Covering index for MatchScore: mandatory skills per opportunity';

-- ==============================================================================
-- INDEX 3: Compound index on applications
--          (opportunity_id, application_status, student_id)
--
-- JUSTIFIES: Recruiter pipeline & applicant ranking queries
-- QUERY PATTERN:
--   SELECT student_id, application_status
--   FROM   applications
--   WHERE  opportunity_id = ?
--   ORDER BY application_status
--
-- WHY COMPOUND: The first two columns satisfy WHERE + ORDER BY; adding
-- student_id makes it a covering index for the recruiter list view.
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_app_opportunity_status_student
    ON applications (opportunity_id, application_status, student_id)
    COMMENT 'Covering index for recruiter pipeline: apps per opportunity sorted by status';

-- ==============================================================================
-- INDEX 4: Compound index on skill_verifications
--          (verifier_teacher_id, verification_status, student_skill_id)
--
-- JUSTIFIES: Teacher workqueue queries (pending verifications per teacher)
-- QUERY PATTERN:
--   SELECT id, student_skill_id
--   FROM   skill_verifications
--   WHERE  verifier_teacher_id = ? AND verification_status = 'pending'
--
-- WHY COMPOUND: Teacher dashboard loads only pending items. Without this,
-- the engine would scan ALL verifications for a teacher regardless of status.
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_sv_teacher_status_skill
    ON skill_verifications (verifier_teacher_id, verification_status, student_skill_id)
    COMMENT 'Covering index for teacher workqueue: pending verifications per teacher';

-- ==============================================================================
-- INDEX 5: Compound index on opportunities
--          (status, application_deadline, company_id)
--
-- JUSTIFIES: Student-facing opportunity discovery + deadline-ordered listing
-- QUERY PATTERN:
--   SELECT id, title, company_id
--   FROM   opportunities
--   WHERE  status = 'published'
--   ORDER BY application_deadline ASC
--
-- WHY COMPOUND: (status) filters rows; (application_deadline) enables the
-- ORDER BY without a filesort; (company_id) satisfies the subsequent JOIN to
-- company_profiles using the index alone.
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_opp_status_deadline_company
    ON opportunities (status, application_deadline, company_id)
    COMMENT 'Covering index for student discovery: published opps by deadline';

-- ==============================================================================
-- VERIFICATION: Confirm all 5 indexes are present
-- ==============================================================================
SELECT
    TABLE_NAME    AS `table`,
    INDEX_NAME    AS `index_name`,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR ', ') AS `columns`,
    INDEX_COMMENT AS `purpose`
FROM   information_schema.STATISTICS
WHERE  TABLE_SCHEMA = 'sih26044_db'
  AND  INDEX_NAME   IN (
           'idx_ss_student_verified_proficiency',
           'idx_os_opportunity_mandatory_skill',
           'idx_app_opportunity_status_student',
           'idx_sv_teacher_status_skill',
           'idx_opp_status_deadline_company'
       )
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_COMMENT
ORDER BY TABLE_NAME, INDEX_NAME;

SELECT 'Phase 2 — Compound Indexes migration completed successfully.' AS migration_status;
