-- Migration 011: Opportunity Required Skills Junction Table
-- SIH26044: Academia-Industry Collaboration Portal

CREATE TABLE IF NOT EXISTS opportunity_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    required_proficiency SMALLINT NOT NULL DEFAULT 3 CHECK (required_proficiency BETWEEN 1 AND 5),
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    skill_weight NUMERIC(3, 2) NOT NULL DEFAULT 1.00 CHECK (skill_weight > 0.00),
    CONSTRAINT uq_opportunity_skill UNIQUE (opportunity_id, skill_id)
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_opp_skills_opp_id ON opportunity_skills(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_opp_skills_skill_id ON opportunity_skills(skill_id);
