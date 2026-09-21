-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 10_applications.sql
-- Entity: applications
-- Purpose: Candidate submissions for published opportunities and recruitment pipeline tracking
-- Relational Model:
--   student_profiles  ──<  applications  >──  opportunities
-- Constraint:
--   UNIQUE(student_id, opportunity_id) guarantees single application per posting.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS applications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    opportunity_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    application_status ENUM(
        'applied',
        'shortlisted',
        'interview',
        'selected',
        'rejected',
        'withdrawn'
    ) NOT NULL DEFAULT 'applied',
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resume_reference VARCHAR(500) NULL COMMENT 'Storage URL or identifier of candidate resume artifact',
    cover_note TEXT NULL COMMENT 'Student personal statement or introduction',
    company_notes TEXT NULL COMMENT 'Internal evaluation notes recorded by corporate recruiters',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_applications_student_opp UNIQUE (student_id, opportunity_id),
    CONSTRAINT fk_applications_opportunity FOREIGN KEY (opportunity_id) 
        REFERENCES opportunities(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_applications_student FOREIGN KEY (student_id) 
        REFERENCES student_profiles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_applications_student_id (student_id),
    INDEX idx_applications_opportunity_id (opportunity_id),
    INDEX idx_applications_status (application_status),
    INDEX idx_applications_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
