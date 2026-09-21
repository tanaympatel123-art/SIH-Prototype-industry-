-- Migration 001: Roles Definition
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Ensure UUID Extension is available
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Create Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Seed Default System Roles
INSERT INTO roles (name, description) VALUES
    ('student', 'Student seeking internships, learning, and skill verification'),
    ('teacher', 'Academic faculty verifying skills and providing mentorship'),
    ('company', 'Corporate partner posting opportunities and recruiting talent'),
    ('institution', 'College administration managing institutional records'),
    ('admin', 'Platform administrator managing system integrity and compliance')
ON CONFLICT (name) DO NOTHING;
