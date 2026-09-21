-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 06_student_skills.sql
-- Entity: student_skills
-- Purpose: Many-to-many junction connecting students to skills with proficiency & provenance
-- Integrity Rule (AI vs Teacher Verification):
--   When source = 'ai_extracted' (e.g., from resume OCR or NLP extraction),
--   is_verified MUST remain FALSE by default.
--   A separate validation event in `skill_verifications` signed by a verified faculty member
--   is strictly required to elevate a skill to is_verified = TRUE.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS student_skills (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    proficiency_level ENUM('beginner', 'intermediate', 'advanced', 'expert') NOT NULL DEFAULT 'beginner',
    proficiency_score DECIMAL(5, 2) NULL COMMENT 'Normalized competency score from 0.00 to 100.00',
    source ENUM(
        'self_declared',
        'quiz',
        'project',
        'certificate',
        'teacher_verified',
        'ai_extracted'
    ) NOT NULL DEFAULT 'self_declared',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_skill UNIQUE (student_id, skill_id),
    CONSTRAINT fk_student_skills_student FOREIGN KEY (student_id) 
        REFERENCES student_profiles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_student_skills_skill FOREIGN KEY (skill_id) 
        REFERENCES skills(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_student_skills_student_id (student_id),
    INDEX idx_student_skills_skill_id (skill_id),
    INDEX idx_student_skills_is_verified (is_verified),
    INDEX idx_student_skills_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
