-- Migration 007: Skill Categories Taxonomy
-- SIH26044: Academia-Industry Collaboration Portal

CREATE TABLE IF NOT EXISTS skill_categories (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
