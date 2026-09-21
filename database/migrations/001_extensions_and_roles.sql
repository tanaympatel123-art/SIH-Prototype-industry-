-- Migration 001: Extensions and Roles
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Create Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id SMALLSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Insert Default System Roles
INSERT INTO roles (name, description) VALUES
    ('student', 'Student seeking internships, learning, and skill verification'),
    ('company', 'Corporate partner posting opportunities and recruiting talent'),
    ('teacher', 'Academic faculty verifying skills and providing mentorship'),
    ('institution_admin', 'College administration managing department records'),
    ('super_admin', 'Platform administrator managing system integrity')
ON CONFLICT (name) DO NOTHING;
