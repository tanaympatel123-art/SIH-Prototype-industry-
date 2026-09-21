-- Migration 004: Student Profiles (1-to-1 extension of users)
-- SIH26044: Academia-Industry Collaboration Portal

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

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_student_profiles_inst_id ON student_profiles(institution_id);
