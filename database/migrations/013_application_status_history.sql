-- Migration 013: Application Status History Audit Log
-- SIH26044: Academia-Industry Collaboration Portal

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

-- Index for application timeline lookup
CREATE INDEX IF NOT EXISTS idx_app_history_app_id ON application_status_history(application_id);
