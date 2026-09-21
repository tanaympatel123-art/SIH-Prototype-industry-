-- Migration 009: Student Skills Junction Table
-- SIH26044: Academia-Industry Collaboration Portal

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

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_student_skills_student_id ON student_skills(student_id);
CREATE INDEX IF NOT EXISTS idx_student_skills_skill_id ON student_skills(skill_id);
