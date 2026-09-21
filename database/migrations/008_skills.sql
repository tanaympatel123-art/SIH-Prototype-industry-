-- Migration 008: Skills Master Taxonomy with Hierarchy
-- SIH26044: Academia-Industry Collaboration Portal

CREATE TABLE IF NOT EXISTS skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id INT NOT NULL REFERENCES skill_categories(id) ON DELETE RESTRICT,
    parent_skill_id UUID REFERENCES skills(id) ON DELETE SET NULL, -- Hierarchical support
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_skills_category_id ON skills(category_id);
CREATE INDEX IF NOT EXISTS idx_skills_parent_id ON skills(parent_skill_id);
