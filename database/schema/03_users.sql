-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 03_users.sql
-- Entity: users
-- Purpose: Root authentication and identity table
-- Design Decision: Direct role_id FK vs separate user_roles junction table
--   Chosen: Normalized 1:N relationship (users.role_id -> roles.id).
--   Rationale: In the SIH portal, each registered actor operates with a distinct primary
--   institutional persona (Student, Teacher, Company, Admin) mapped 1:1 to a specific profile.
--   A direct foreign key simplifies authorization middleware, enforces profile exclusivity,
--   eliminates unnecessary JOIN overhead on authentication lookups, and cleanly supports Phase 1.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id TINYINT UNSIGNED NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) 
        REFERENCES roles(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_users_email (email),
    INDEX idx_users_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
