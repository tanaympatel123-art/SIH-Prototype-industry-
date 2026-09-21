-- Migration 007: Assessment Engine and Teacher Skill Verification
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Assessments Table (Quizzes linked to skills)
CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL DEFAULT 30,
    pass_percentage NUMERIC(5, 2) NOT NULL DEFAULT 70.00,
    total_questions INT NOT NULL DEFAULT 5,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Assessment Questions Table
CREATE TABLE IF NOT EXISTS assessment_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL DEFAULT 'multiple_choice',
    difficulty VARCHAR(50) NOT NULL DEFAULT 'medium',
    marks INT NOT NULL DEFAULT 1,
    explanation TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_difficulty CHECK (difficulty IN ('easy', 'medium', 'hard'))
);

-- 3. Assessment Options Table
CREATE TABLE IF NOT EXISTS assessment_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES assessment_questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE
);

-- 4. Assessment Attempts Table (Student test sessions)
CREATE TABLE IF NOT EXISTS assessment_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE RESTRICT,
    score_obtained NUMERIC(5, 2) NOT NULL DEFAULT 0.00,
    passed BOOLEAN NOT NULL DEFAULT FALSE,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- 5. Skill Verifications Table (Audit log of faculty / quiz endorsements)
CREATE TABLE IF NOT EXISTS skill_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_skill_id UUID NOT NULL REFERENCES student_skills(id) ON DELETE CASCADE,
    verified_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    verification_source VARCHAR(50) NOT NULL DEFAULT 'quiz',
    certificate_url VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'approved',
    comments TEXT,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_verification_source CHECK (verification_source IN ('quiz', 'teacher_endorsement', 'company_internship', 'external_certificate')),
    CONSTRAINT chk_verification_status CHECK (status IN ('pending', 'approved', 'rejected'))
);

-- 6. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_assessments_skill_id ON assessments(skill_id);
CREATE INDEX IF NOT EXISTS idx_assessment_questions_test_id ON assessment_questions(assessment_id);
CREATE INDEX IF NOT EXISTS idx_assessment_options_question_id ON assessment_options(question_id);
CREATE INDEX IF NOT EXISTS idx_assessment_attempts_student_id ON assessment_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_skill_verifications_skill_id ON skill_verifications(student_skill_id);
