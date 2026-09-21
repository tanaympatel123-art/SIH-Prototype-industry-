-- Migration 005: Opportunities and Applications Engine
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Opportunities Table (Internships & Jobs posted by Companies)
CREATE TABLE IF NOT EXISTS opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES company_profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    opportunity_type VARCHAR(50) NOT NULL DEFAULT 'internship',
    work_mode VARCHAR(50) NOT NULL DEFAULT 'remote',
    location VARCHAR(255),
    stipend_amount NUMERIC(10, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',
    duration_months INT DEFAULT 6,
    openings_count INT NOT NULL DEFAULT 1,
    description TEXT NOT NULL,
    requirements TEXT,
    application_deadline TIMESTAMPTZ NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_opp_type CHECK (opportunity_type IN ('internship', 'full_time', 'project', 'apprentice')),
    CONSTRAINT chk_work_mode CHECK (work_mode IN ('remote', 'hybrid', 'on_site')),
    CONSTRAINT chk_opp_status CHECK (status IN ('draft', 'active', 'closed', 'cancelled'))
);

-- 2. Opportunity Skills Junction Table (Skills required for an opportunity)
CREATE TABLE IF NOT EXISTS opportunity_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    min_proficiency VARCHAR(50) NOT NULL DEFAULT 'intermediate',
    CONSTRAINT uq_opportunity_skill UNIQUE (opportunity_id, skill_id),
    CONSTRAINT chk_min_proficiency CHECK (min_proficiency IN ('beginner', 'intermediate', 'advanced', 'expert'))
);

-- 3. Resumes Table (Uploaded CV documents metadata)
CREATE TABLE IF NOT EXISTS resumes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Applications Table (Student applications to opportunities)
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    resume_id UUID REFERENCES resumes(id) ON DELETE SET NULL,
    cover_letter TEXT,
    match_score NUMERIC(5, 2),
    status VARCHAR(50) NOT NULL DEFAULT 'applied',
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_opportunity UNIQUE (opportunity_id, student_id),
    CONSTRAINT chk_app_status CHECK (status IN ('applied', 'reviewing', 'shortlisted', 'interview_scheduled', 'offered', 'rejected', 'withdrawn'))
);

-- 5. Application Status History (Audit timeline for application progress)
CREATE TABLE IF NOT EXISTS application_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    remarks TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_opps_company_id ON opportunities(company_id);
CREATE INDEX IF NOT EXISTS idx_opps_status_created ON opportunities(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_opp_skills_opp_id ON opportunity_skills(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_opp_skills_skill_id ON opportunity_skills(skill_id);
CREATE INDEX IF NOT EXISTS idx_resumes_student_id ON resumes(student_id);
CREATE INDEX IF NOT EXISTS idx_apps_student_id ON applications(student_id);
CREATE INDEX IF NOT EXISTS idx_apps_opp_score ON applications(opportunity_id, match_score DESC);
CREATE INDEX IF NOT EXISTS idx_app_history_app_id ON application_status_history(application_id);
