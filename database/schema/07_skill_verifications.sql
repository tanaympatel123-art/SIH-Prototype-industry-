-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 07_skill_verifications.sql
-- Entity: skill_verifications
-- Purpose: Audit trail of academic faculty endorsements & skill validations
-- Relational Model:
--   student_skills  ──<  skill_verifications  >──  teacher_profiles
-- Authority Principle:
--   A certified teacher profile is the final human authority for manual verification.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS skill_verifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_skill_id BIGINT UNSIGNED NOT NULL,
    verifier_teacher_id BIGINT UNSIGNED NOT NULL,
    verification_status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    evidence_type ENUM(
        'project',
        'certificate',
        'assessment',
        'coursework',
        'interview',
        'other'
    ) NOT NULL DEFAULT 'project',
    evidence_reference VARCHAR(500) NULL COMMENT 'External repository link, certificate ID, or artifact URI',
    confidence_score DECIMAL(5, 2) NULL COMMENT 'Optional AI/System confidence rating (0.00 - 100.00)',
    remarks TEXT NULL COMMENT 'Teacher evaluation feedback or rejection justification',
    verified_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_verifications_student_skill FOREIGN KEY (student_skill_id) 
        REFERENCES student_skills(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_verifications_teacher FOREIGN KEY (verifier_teacher_id) 
        REFERENCES teacher_profiles(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_verifications_student_skill (student_skill_id),
    INDEX idx_verifications_teacher (verifier_teacher_id),
    INDEX idx_verifications_status (verification_status),
    INDEX idx_verifications_verified_at (verified_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
