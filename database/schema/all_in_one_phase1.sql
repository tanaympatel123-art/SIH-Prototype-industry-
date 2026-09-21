-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation — All-In-One MySQL 8.x Master Script
-- Target Environment: MySQL 8.x / MariaDB (XAMPP / phpMyAdmin / MySQL CLI)
-- 
-- Execution Order:
--   1. Database Initialization
--   2. roles (RBAC master)
--   3. users (Authentication root)
--   4. student_profiles, company_profiles, teacher_profiles (1:1 profiles)
--   5. skills (Master ontology with self-referencing hierarchy)
--   6. student_skills (Student skill inventory with provenance)
--   7. skill_verifications (Teacher verification audit trail)
--   8. opportunities (Corporate opportunity postings)
--   9. opportunity_skills (Required skill bindings)
--   10. applications (Recruitment lifecycle submissions)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. DATABASE INITIALIZATION
-- ------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS sih26044_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sih26044_db;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables in reverse dependency order for clean re-runs if necessary
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS opportunity_skills;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS skill_verifications;
DROP TABLE IF EXISTS student_skills;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS teacher_profiles;
DROP TABLE IF EXISTS company_profiles;
DROP TABLE IF EXISTS student_profiles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------------------
-- 2. ROLES TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE roles (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_roles_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (id, name, description) VALUES
    (1, 'student', 'Enrolled student seeking internships, skill benchmarking, and verification'),
    (2, 'company', 'Corporate partner posting opportunities, reviewing candidates, and hiring talent'),
    (3, 'teacher', 'Academic faculty responsible for reviewing and verifying student skills'),
    (4, 'admin', 'Platform administrator managing system governance, security, and integrity');

-- ------------------------------------------------------------------------------
-- 3. USERS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE users (
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

-- ------------------------------------------------------------------------------
-- 4. STAKEHOLDER PROFILES (1:1 with users)
-- ------------------------------------------------------------------------------

-- Student Profiles
CREATE TABLE student_profiles (
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

-- Company Profiles
CREATE TABLE company_profiles (
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

-- Teacher Profiles
CREATE TABLE teacher_profiles (
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

-- ------------------------------------------------------------------------------
-- 5. SKILLS MASTER TAXONOMY
-- ------------------------------------------------------------------------------
CREATE TABLE skills (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NULL,
    parent_skill_id INT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_skills_skill_name UNIQUE (skill_name),
    CONSTRAINT fk_skills_parent FOREIGN KEY (parent_skill_id) 
        REFERENCES skills(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_skills_category (category),
    INDEX idx_skills_parent_id (parent_skill_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 6. STUDENT SKILLS JUNCTION
-- ------------------------------------------------------------------------------
CREATE TABLE student_skills (
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

-- ------------------------------------------------------------------------------
-- 7. SKILL VERIFICATIONS (Audit trail with Teacher authority)
-- ------------------------------------------------------------------------------
CREATE TABLE skill_verifications (
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

-- ------------------------------------------------------------------------------
-- 8. OPPORTUNITIES TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE opportunities (
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

-- ------------------------------------------------------------------------------
-- 9. OPPORTUNITY SKILLS JUNCTION
-- ------------------------------------------------------------------------------
CREATE TABLE opportunity_skills (
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

-- ------------------------------------------------------------------------------
-- 10. APPLICATIONS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE applications (
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
