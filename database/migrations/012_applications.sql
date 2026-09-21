-- Migration 012: Student Applications
-- SIH26044: Academia-Industry Collaboration Portal

CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE RESTRICT, -- Protect business records
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    cover_letter TEXT,
    match_score NUMERIC(5, 2) CHECK (match_score >= 0.00 AND match_score <= 100.00),
    status VARCHAR(50) NOT NULL DEFAULT 'APPLIED',
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_opportunity UNIQUE (opportunity_id, student_id),
    CONSTRAINT chk_application_state CHECK (status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_apps_student_id ON applications(student_id);
CREATE INDEX IF NOT EXISTS idx_apps_opp_score ON applications(opportunity_id, match_score DESC);
CREATE INDEX IF NOT EXISTS idx_apps_status ON applications(opportunity_id, status);
