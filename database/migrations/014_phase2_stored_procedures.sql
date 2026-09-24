-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 2: Stored Procedures & Atomic Workflows
-- File: 014_phase2_stored_procedures.sql
-- Target: MySQL 8.x (InnoDB / utf8mb4) — XAMPP / phpMyAdmin / MySQL CLI
-- Branch: database/phase-2-optimization
-- ==============================================================================

USE sih26044_db;

-- ------------------------------------------------------------------------------
-- PRE-REQUISITE: Add profile_completion_pct column to student_profiles
-- (Column did not exist in Phase 1 schema — adding here as Phase 2 migration)
-- ------------------------------------------------------------------------------
ALTER TABLE student_profiles
    ADD COLUMN IF NOT EXISTS profile_completion_pct DECIMAL(5,2) NOT NULL DEFAULT 0.00
        COMMENT 'Percentage of profile completeness (0.00 – 100.00). Updated atomically by stored procedures.',
    ADD INDEX IF NOT EXISTS idx_student_profiles_completion (profile_completion_pct);

-- Backfill existing rows: 30% base for having any profile at all
UPDATE student_profiles
SET    profile_completion_pct = 30.00
WHERE  profile_completion_pct = 0.00;

-- ==============================================================================
-- STORED PROCEDURE 1: sp_approve_skill_verification
-- Purpose : Teacher approves a pending skill verification request.
--           Atomically:
--             (a) Updates skill_verifications row to 'approved'
--             (b) Marks the linked student_skill as is_verified = TRUE
--             (c) Increments student's profile_completion_pct by +10 (max 100)
-- Caller  : Teacher Dashboard → "Approve" action
-- ==============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_approve_skill_verification $$

CREATE PROCEDURE sp_approve_skill_verification (
    IN  p_verification_id   BIGINT UNSIGNED,   -- PK of skill_verifications row
    IN  p_teacher_id        BIGINT UNSIGNED,   -- PK of teacher_profiles row
    IN  p_remarks           TEXT               -- Faculty evaluation notes
)
BEGIN
    -- ─── Local variable declarations ───────────────────────────────────────────
    DECLARE v_student_skill_id  BIGINT UNSIGNED DEFAULT NULL;
    DECLARE v_student_id        BIGINT UNSIGNED DEFAULT NULL;
    DECLARE v_current_status    VARCHAR(20)     DEFAULT NULL;
    DECLARE v_teacher_matches   TINYINT         DEFAULT 0;
    DECLARE v_rows_affected     INT             DEFAULT 0;

    -- ─── Error handler — rolls back on any SQL exception ───────────────────────
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- ── Step 1: Fetch verification record & lock it for update ─────────────────
    SELECT sv.student_skill_id,
           sv.verification_status,
           ss.student_id
    INTO   v_student_skill_id,
           v_current_status,
           v_student_id
    FROM   skill_verifications sv
    JOIN   student_skills      ss ON ss.id = sv.student_skill_id
    WHERE  sv.id                  = p_verification_id
    FOR UPDATE;                  -- Pessimistic row lock — prevents concurrent approval

    -- ── Step 2: Guard — verification must exist ─────────────────────────────────
    IF v_student_skill_id IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Verification record not found.';
    END IF;

    -- ── Step 3: Guard — only 'pending' records can be approved ─────────────────
    IF v_current_status != 'pending' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Verification is not in pending status. Cannot approve.';
    END IF;

    -- ── Step 4: Guard — teacher must be the assigned verifier ──────────────────
    SELECT COUNT(*) INTO v_teacher_matches
    FROM   skill_verifications
    WHERE  id                 = p_verification_id
      AND  verifier_teacher_id = p_teacher_id;

    IF v_teacher_matches = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Teacher is not the assigned verifier for this request.';
    END IF;

    -- ── Step 5: Approve the verification row ───────────────────────────────────
    UPDATE skill_verifications
    SET    verification_status = 'approved',
           remarks             = p_remarks,
           verified_at         = NOW()
    WHERE  id                  = p_verification_id;

    -- ── Step 6: Mark student_skill as verified ─────────────────────────────────
    UPDATE student_skills
    SET    is_verified = TRUE,
           source      = 'teacher_verified',
           updated_at  = NOW()
    WHERE  id          = v_student_skill_id;

    -- ── Step 7: Increment profile completion (+10%, capped at 100.00) ──────────
    UPDATE student_profiles
    SET    profile_completion_pct = LEAST(profile_completion_pct + 10.00, 100.00),
           updated_at             = NOW()
    WHERE  id                     = v_student_id;

    COMMIT;

    -- ── Step 8: Return success summary ─────────────────────────────────────────
    SELECT
        'SUCCESS'                         AS result_status,
        p_verification_id                 AS verification_id,
        v_student_id                      AS student_id,
        'approved'                        AS new_verification_status,
        TRUE                              AS skill_now_verified,
        (SELECT profile_completion_pct
         FROM   student_profiles
         WHERE  id = v_student_id)        AS updated_completion_pct;

END $$

DELIMITER ;

-- ==============================================================================
-- STORED PROCEDURE 2: sp_update_application_status
-- Purpose : Enforces valid application state-machine transitions and records
--           full audit trail via application_status_history.
--
--           VALID TRANSITIONS:
--             applied      → shortlisted | rejected | withdrawn
--             shortlisted  → interview   | rejected | withdrawn
--             interview    → selected    | rejected | withdrawn
--             selected     → (terminal — no further transition)
--             rejected     → (terminal — no further transition)
--             withdrawn    → (terminal — no further transition)
--
-- Caller  : Recruiter Dashboard → status pipeline buttons
-- ==============================================================================

-- ── Pre-requisite: application_status_history table ────────────────────────────
CREATE TABLE IF NOT EXISTS application_status_history (
    id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id      BIGINT UNSIGNED NOT NULL,
    from_status         ENUM('applied','shortlisted','interview','selected','rejected','withdrawn') NULL
                            COMMENT 'NULL on initial submission',
    to_status           ENUM('applied','shortlisted','interview','selected','rejected','withdrawn') NOT NULL,
    changed_by_user_id  BIGINT UNSIGNED NULL
                            COMMENT 'NULL = system-triggered transition',
    notes               TEXT NULL,
    changed_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ash_application FOREIGN KEY (application_id)
        REFERENCES applications(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ash_user        FOREIGN KEY (changed_by_user_id)
        REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_ash_application_id (application_id),
    INDEX idx_ash_changed_at     (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Full immutable audit trail for every application status change.';

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_update_application_status $$

CREATE PROCEDURE sp_update_application_status (
    IN  p_application_id    BIGINT UNSIGNED,   -- PK of applications row
    IN  p_new_status        VARCHAR(50),        -- Target status string
    IN  p_notes             TEXT,              -- Recruiter notes / justification
    IN  p_changed_by        BIGINT UNSIGNED    -- user_id of recruiter performing action
)
BEGIN
    -- ─── Local variable declarations ───────────────────────────────────────────
    DECLARE v_current_status    VARCHAR(20)  DEFAULT NULL;
    DECLARE v_transition_valid  TINYINT      DEFAULT 0;

    -- ─── Error handler ─────────────────────────────────────────────────────────
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- ── Step 1: Lock and fetch current status ──────────────────────────────────
    SELECT application_status
    INTO   v_current_status
    FROM   applications
    WHERE  id = p_application_id
    FOR UPDATE;

    IF v_current_status IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Application record not found.';
    END IF;

    -- ── Step 2: Block transitions out of terminal states ───────────────────────
    IF v_current_status IN ('selected', 'rejected', 'withdrawn') THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Application is in a terminal state. No further transitions allowed.';
    END IF;

    -- ── Step 3: Validate the specific state-machine transition ────────────────
    --    We use a lookup expression to enforce the directed graph.
    SET v_transition_valid = CASE
        WHEN v_current_status = 'applied'     AND p_new_status IN ('shortlisted', 'rejected', 'withdrawn')   THEN 1
        WHEN v_current_status = 'shortlisted' AND p_new_status IN ('interview',   'rejected', 'withdrawn')   THEN 1
        WHEN v_current_status = 'interview'   AND p_new_status IN ('selected',    'rejected', 'withdrawn')   THEN 1
        ELSE 0
    END;

    IF v_transition_valid = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERROR: Invalid state transition. Review the allowed application workflow.';
    END IF;

    -- ── Step 4: Update applications table ──────────────────────────────────────
    UPDATE applications
    SET    application_status = p_new_status,
           company_notes      = IFNULL(p_notes, company_notes),
           updated_at         = NOW()
    WHERE  id                 = p_application_id;

    -- ── Step 5: Append to audit history ────────────────────────────────────────
    INSERT INTO application_status_history
        (application_id, from_status, to_status, changed_by_user_id, notes, changed_at)
    VALUES
        (p_application_id, v_current_status, p_new_status, p_changed_by, p_notes, NOW());

    COMMIT;

    -- ── Step 6: Return confirmation ────────────────────────────────────────────
    SELECT
        'SUCCESS'           AS result_status,
        p_application_id    AS application_id,
        v_current_status    AS previous_status,
        p_new_status        AS new_status,
        NOW()               AS transitioned_at;

END $$

DELIMITER ;

-- ==============================================================================
-- VERIFICATION: Confirm procedures are registered
-- ==============================================================================
SELECT routine_name, routine_type, created
FROM   information_schema.routines
WHERE  routine_schema = 'sih26044_db'
  AND  routine_type   = 'PROCEDURE'
ORDER BY routine_name;

SELECT 'Phase 2 — Stored Procedures migration completed successfully.' AS migration_status;
