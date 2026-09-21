-- Migration 005: Company Profiles (1-to-1 extension of users)
-- SIH26044: Academia-Industry Collaboration Portal

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
    CONSTRAINT uq_company_profiles_user UNIQUE (user_id),
    CONSTRAINT chk_company_verification CHECK (verification_status IN ('pending', 'verified', 'rejected'))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_company_profiles_user_id ON company_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_company_profiles_verification ON company_profiles(verification_status);
