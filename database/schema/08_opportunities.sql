-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 08_opportunities.sql
-- Entity: opportunities
-- Purpose: Internship, job, and collaborative project postings published by corporate partners
-- Relational Model:
--   company_profiles  ──<  opportunities
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS opportunities (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    opportunity_type ENUM('internship', 'full_time', 'part_time', 'contract') NOT NULL DEFAULT 'internship',
    location VARCHAR(150) NOT NULL,
    work_mode ENUM('onsite', 'remote', 'hybrid') NOT NULL DEFAULT 'onsite',
    stipend_salary VARCHAR(100) NULL COMMENT 'Remuneration representation (e.g. ₹25,000/month or ₹8-10 LPA)',
    openings INT UNSIGNED NOT NULL DEFAULT 1,
    application_deadline DATE NOT NULL,
    status ENUM('draft', 'published', 'closed', 'archived') NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_opportunities_company FOREIGN KEY (company_id) 
        REFERENCES company_profiles(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_opportunities_company_id (company_id),
    INDEX idx_opportunities_status (status),
    INDEX idx_opportunities_deadline (application_deadline),
    INDEX idx_opportunities_type (opportunity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
