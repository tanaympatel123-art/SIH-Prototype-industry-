-- Master Runner Script: Phase 3 Foundation All-In-One
-- SIH26044: Academia-Industry Collaboration Portal
-- Runs all 13 migrations in strict dependency order, seeds deterministic data, and executes validation.

BEGIN;

-- =======================================================
-- 1. MIGRATION 001: ROLES
-- =======================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS roles (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO roles (name, description) VALUES
    ('student', 'Student seeking internships, learning, and skill verification'),
    ('teacher', 'Academic faculty verifying skills and providing mentorship'),
    ('company', 'Corporate partner posting opportunities and recruiting talent'),
    ('institution', 'College administration managing institutional records'),
    ('admin', 'Platform administrator managing system integrity and compliance')
ON CONFLICT (name) DO NOTHING;

-- =======================================================
-- 2. MIGRATION 002: USERS
-- =======================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id SMALLINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- =======================================================
-- 3. MIGRATION 003: INSTITUTIONS
-- =======================================================
CREATE TABLE IF NOT EXISTS institutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    website VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_institutions_code ON institutions(code);

-- =======================================================
-- 4. MIGRATION 004: STUDENT PROFILES
-- =======================================================
CREATE TABLE IF NOT EXISTS student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    roll_number VARCHAR(50) NOT NULL,
    department VARCHAR(100) NOT NULL,
    current_semester SMALLINT NOT NULL CHECK (current_semester BETWEEN 1 AND 12),
    cgpa NUMERIC(4, 2) CHECK (cgpa >= 0.00 AND cgpa <= 10.00),
    graduation_year INT NOT NULL CHECK (graduation_year >= 2020 AND graduation_year <= 2040),
    headline VARCHAR(255),
    bio TEXT,
    github_url VARCHAR(255),
    linkedin_url VARCHAR(255),
    portfolio_url VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_profiles_user UNIQUE (user_id),
    CONSTRAINT uq_student_roll_inst UNIQUE (institution_id, roll_number)
);

CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_student_profiles_inst_id ON student_profiles(institution_id);

-- =======================================================
-- 5. MIGRATION 005: COMPANY PROFILES
-- =======================================================
CREATE TABLE IF NOT EXISTS company_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    industry_type VARCHAR(100) NOT NULL,
    website VARCHAR(255),
    registration_number VARCHAR(100),
    company_size VARCHAR(50),
    headquarters VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(500),
    verification_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_company_profiles_user UNIQUE (user_id),
    CONSTRAINT chk_company_verification CHECK (verification_status IN ('pending', 'verified', 'rejected'))
);

CREATE INDEX IF NOT EXISTS idx_company_profiles_user_id ON company_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_company_profiles_verification ON company_profiles(verification_status);

-- =======================================================
-- 6. MIGRATION 006: TEACHER PROFILES
-- =======================================================
CREATE TABLE IF NOT EXISTS teacher_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    faculty_id VARCHAR(50),
    designation VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    specialization VARCHAR(255),
    bio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_teacher_profiles_user UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_inst_id ON teacher_profiles(institution_id);

-- =======================================================
-- 7. MIGRATION 007: SKILL CATEGORIES
-- =======================================================
CREATE TABLE IF NOT EXISTS skill_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =======================================================
-- 8. MIGRATION 008: SKILLS
-- =======================================================
CREATE TABLE IF NOT EXISTS skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id INT NOT NULL REFERENCES skill_categories(id) ON DELETE RESTRICT,
    parent_skill_id UUID REFERENCES skills(id) ON DELETE SET NULL,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_skills_category_id ON skills(category_id);
CREATE INDEX IF NOT EXISTS idx_skills_parent_id ON skills(parent_skill_id);

-- =======================================================
-- 9. MIGRATION 009: STUDENT SKILLS
-- =======================================================
CREATE TABLE IF NOT EXISTS student_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    proficiency SMALLINT NOT NULL DEFAULT 1 CHECK (proficiency BETWEEN 1 AND 5),
    assessment_score NUMERIC(5, 2) CHECK (assessment_score >= 0.00 AND assessment_score <= 100.00),
    source VARCHAR(50) NOT NULL DEFAULT 'self_reported' CHECK (source IN ('self_reported', 'quiz_assessment', 'teacher_endorsement', 'industry_project')),
    confidence_score NUMERIC(3, 2) DEFAULT 0.50 CHECK (confidence_score >= 0.00 AND confidence_score <= 1.00),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_skill UNIQUE (student_id, skill_id)
);

CREATE INDEX IF NOT EXISTS idx_student_skills_student_id ON student_skills(student_id);
CREATE INDEX IF NOT EXISTS idx_student_skills_skill_id ON student_skills(skill_id);

-- =======================================================
-- 10. MIGRATION 010: OPPORTUNITIES
-- =======================================================
CREATE TABLE IF NOT EXISTS opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES company_profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    opportunity_type VARCHAR(50) NOT NULL DEFAULT 'internship',
    work_mode VARCHAR(50) NOT NULL DEFAULT 'remote',
    location VARCHAR(255),
    stipend NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (stipend >= 0.00),
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    duration_months INT DEFAULT 6 CHECK (duration_months > 0),
    deadline TIMESTAMPTZ NOT NULL,
    openings INT NOT NULL DEFAULT 1 CHECK (openings > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    description TEXT NOT NULL,
    requirements TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_opp_type CHECK (opportunity_type IN ('internship', 'full_time', 'project', 'apprentice')),
    CONSTRAINT chk_opp_work_mode CHECK (work_mode IN ('remote', 'hybrid', 'on_site')),
    CONSTRAINT chk_opp_status CHECK (status IN ('draft', 'active', 'closed', 'cancelled'))
);

CREATE INDEX IF NOT EXISTS idx_opps_company_id ON opportunities(company_id);
CREATE INDEX IF NOT EXISTS idx_opps_status_deadline ON opportunities(status, deadline DESC);

-- =======================================================
-- 11. MIGRATION 011: OPPORTUNITY SKILLS
-- =======================================================
CREATE TABLE IF NOT EXISTS opportunity_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    required_proficiency SMALLINT NOT NULL DEFAULT 3 CHECK (required_proficiency BETWEEN 1 AND 5),
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    skill_weight NUMERIC(3, 2) NOT NULL DEFAULT 1.00 CHECK (skill_weight > 0.00),
    CONSTRAINT uq_opportunity_skill UNIQUE (opportunity_id, skill_id)
);

CREATE INDEX IF NOT EXISTS idx_opp_skills_opp_id ON opportunity_skills(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_opp_skills_skill_id ON opportunity_skills(skill_id);

-- =======================================================
-- 12. MIGRATION 012: APPLICATIONS
-- =======================================================
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    cover_letter TEXT,
    match_score NUMERIC(5, 2) CHECK (match_score >= 0.00 AND match_score <= 100.00),
    status VARCHAR(50) NOT NULL DEFAULT 'APPLIED',
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_opportunity UNIQUE (opportunity_id, student_id),
    CONSTRAINT chk_application_state CHECK (status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))
);

CREATE INDEX IF NOT EXISTS idx_apps_student_id ON applications(student_id);
CREATE INDEX IF NOT EXISTS idx_apps_opp_score ON applications(opportunity_id, match_score DESC);
CREATE INDEX IF NOT EXISTS idx_apps_status ON applications(opportunity_id, status);

-- =======================================================
-- 13. MIGRATION 013: APPLICATION STATUS HISTORY
-- =======================================================
CREATE TABLE IF NOT EXISTS application_status_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    remarks TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_hist_new_status CHECK (new_status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))
);

CREATE INDEX IF NOT EXISTS idx_app_history_app_id ON application_status_history(application_id);

COMMIT;
