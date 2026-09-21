-- Migration 003: Stakeholder Profiles (Student, Company, Teacher)
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Student Profiles Table (1-to-1 extension of users for students)
CREATE TABLE IF NOT EXISTS student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    roll_number VARCHAR(50) NOT NULL,
    department VARCHAR(100) NOT NULL,
    current_semester SMALLINT NOT NULL,
    cgpa NUMERIC(4, 2),
    graduation_year INT NOT NULL,
    headline VARCHAR(255),
    bio TEXT,
    github_url VARCHAR(255),
    linkedin_url VARCHAR(255),
    portfolio_url VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Company Profiles Table (1-to-1 extension of users for companies)
CREATE TABLE IF NOT EXISTS company_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    industry_type VARCHAR(100) NOT NULL,
    website VARCHAR(255),
    registration_number VARCHAR(100), -- CIN or GSTIN
    company_size VARCHAR(50),
    headquarters VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(500),
    verification_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_company_verification CHECK (verification_status IN ('pending', 'verified', 'rejected'))
);

-- 3. Teacher Profiles Table (1-to-1 extension of users for faculty)
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
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Foreign Key & Lookup Indexes
CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_student_profiles_institution_id ON student_profiles(institution_id);
CREATE INDEX IF NOT EXISTS idx_company_profiles_user_id ON company_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_company_profiles_status ON company_profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_institution_id ON teacher_profiles(institution_id);
