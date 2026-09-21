-- Migration 002: Institutions and Users
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Create Institutions Table (Colleges / Universities)
CREATE TABLE IF NOT EXISTS institutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL, -- AISHE / College Code
    website VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create Users Table (Root Authentication)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id SMALLINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Create Performance Index on users(email) and users(role_id)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- 4. Insert Sample Accredited Institutions
INSERT INTO institutions (name, code, website, city, state, is_verified) VALUES
    ('Indian Institute of Technology Bombay', 'AISHE-U-0306', 'https://www.iitb.ac.in', 'Mumbai', 'Maharashtra', TRUE),
    ('National Institute of Technology Tiruchirappalli', 'AISHE-U-0467', 'https://www.nitt.edu', 'Tiruchirappalli', 'Tamil Nadu', TRUE),
    ('Delhi Technological University', 'AISHE-U-0099', 'https://www.dtu.ac.in', 'New Delhi', 'Delhi', TRUE)
ON CONFLICT (code) DO NOTHING;
