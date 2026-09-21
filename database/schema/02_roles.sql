-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 02_roles.sql
-- Entity: roles
-- Purpose: System-level Role-Based Access Control (RBAC) master table
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_roles_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed canonical Phase 1 system roles
INSERT INTO roles (id, name, description) VALUES
    (1, 'student', 'Enrolled student seeking internships, skill benchmarking, and verification'),
    (2, 'company', 'Corporate partner posting opportunities, reviewing candidates, and hiring talent'),
    (3, 'teacher', 'Academic faculty responsible for reviewing and verifying student skills'),
    (4, 'admin', 'Platform administrator managing system governance, security, and integrity')
ON DUPLICATE KEY UPDATE description = VALUES(description);
