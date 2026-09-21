-- Migration 010: Opportunities Table (Internships & Jobs)
-- SIH26044: Academia-Industry Collaboration Portal

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

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_opps_company_id ON opportunities(company_id);
CREATE INDEX IF NOT EXISTS idx_opps_status_deadline ON opportunities(status, deadline DESC);
