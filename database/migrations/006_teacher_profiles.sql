-- Migration 006: Teacher Profiles (1-to-1 extension of users)
-- SIH26044: Academia-Industry Collaboration Portal

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

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_user_id ON teacher_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_profiles_inst_id ON teacher_profiles(institution_id);
