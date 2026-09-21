-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 09_opportunity_skills.sql
-- Entity: opportunity_skills
-- Purpose: Junction table binding opportunities to required skills and proficiencies
-- Application Matching Core:
--   Used by candidate recommendation and screening engines to compute skill gaps
--   and match percentages against student profile skills.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS opportunity_skills (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    opportunity_id BIGINT UNSIGNED NOT NULL,
    skill_id INT UNSIGNED NOT NULL,
    required_proficiency_level ENUM('beginner', 'intermediate', 'advanced', 'expert') NOT NULL DEFAULT 'intermediate',
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_opportunity_skill UNIQUE (opportunity_id, skill_id),
    CONSTRAINT fk_opportunity_skills_opp FOREIGN KEY (opportunity_id) 
        REFERENCES opportunities(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_opportunity_skills_skill FOREIGN KEY (skill_id) 
        REFERENCES skills(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_opportunity_skills_opp_id (opportunity_id),
    INDEX idx_opportunity_skills_skill_id (skill_id),
    INDEX idx_opportunity_skills_mandatory (is_mandatory)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
