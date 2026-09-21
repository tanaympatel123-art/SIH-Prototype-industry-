-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 04_profiles.sql
-- Entities: student_profiles, company_profiles, teacher_profiles
-- Purpose: Role-specific profile extensions with strict 1:1 user relationships
-- Design Principle: Authentication credentials remain isolated in `users` table;
--                   no email/password attributes duplicated here.
-- ==============================================================================

USE sih26044_db;

-- ------------------------------------------------------------------------------
-- 1. STUDENT PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS student_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    student_identifier VARCHAR(50) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    institution VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL,
    course_program VARCHAR(100) NOT NULL,
    current_semester TINYINT UNSIGNED NULL,
    graduation_year YEAR NOT NULL,
    cgpa DECIMAL(4, 2) NULL,
    bio TEXT NULL,
    location VARCHAR(150) NULL,
    profile_photo_url VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_profiles_user_id UNIQUE (user_id),
    CONSTRAINT uq_student_profiles_identifier UNIQUE (student_identifier),
    CONSTRAINT fk_student_profiles_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_student_profiles_user_id (user_id),
    INDEX idx_student_profiles_institution (institution),
    INDEX idx_student_profiles_grad_year (graduation_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. COMPANY PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS company_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    company_description TEXT NULL,
    website VARCHAR(255) NULL,
    location VARCHAR(150) NULL,
    company_size VARCHAR(50) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_company_profiles_user_id UNIQUE (user_id),
    CONSTRAINT fk_company_profiles_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_company_profiles_user_id (user_id),
    INDEX idx_company_profiles_company_name (company_name),
    INDEX idx_company_profiles_industry (industry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 3. TEACHER PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS teacher_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    employee_identifier VARCHAR(50) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    institution VARCHAR(255) NOT NULL,
    department VARCHAR(100) NOT NULL,
    designation VARCHAR(100) NOT NULL,
    specialization VARCHAR(255) NULL,
    bio TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_teacher_profiles_user_id UNIQUE (user_id),
    CONSTRAINT uq_teacher_profiles_identifier UNIQUE (employee_identifier),
    CONSTRAINT fk_teacher_profiles_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_teacher_profiles_user_id (user_id),
    INDEX idx_teacher_profiles_institution (institution),
    INDEX idx_teacher_profiles_department (department)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
