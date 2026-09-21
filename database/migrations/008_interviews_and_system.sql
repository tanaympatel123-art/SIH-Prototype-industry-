-- Migration 008: Interview Scheduling, Feedback, Notifications, and Audit Logs
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Interview Slots Table (Recruiter Calendar Availability)
CREATE TABLE IF NOT EXISTS interview_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES company_profiles(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    is_booked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Interviews Table (Confirmed Applicant Interviews)
CREATE TABLE IF NOT EXISTS interviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    slot_id UUID UNIQUE REFERENCES interview_slots(id) ON DELETE RESTRICT,
    scheduled_time TIMESTAMPTZ NOT NULL,
    meeting_url VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_interview_status CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled'))
);

-- 3. Feedback Table (Recruiter Post-Interview Review & Ratings)
CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    submitted_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    technical_score SMALLINT CHECK (technical_score BETWEEN 1 AND 10),
    communication_score SMALLINT CHECK (communication_score BETWEEN 1 AND 10),
    strengths TEXT,
    improvements TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Notifications Table (In-App User Alerts)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Audit Logs Table (Append-Only Compliance & Security Trail)
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_slots_company_id ON interview_slots(company_id);
CREATE INDEX IF NOT EXISTS idx_interviews_app_id ON interviews(application_id);
CREATE INDEX IF NOT EXISTS idx_feedback_app_id ON feedback(application_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
