-- Migration 004: Skills Taxonomy and Student Skills
-- SIH26044: Academia-Industry Collaboration Portal

-- 1. Skill Categories (e.g. Web Dev, AI, Cloud)
CREATE TABLE IF NOT EXISTS skill_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Master Skills Dictionary
CREATE TABLE IF NOT EXISTS skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id INT NOT NULL REFERENCES skill_categories(id) ON DELETE RESTRICT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Student Skills (Many-to-Many Junction Table)
CREATE TABLE IF NOT EXISTS student_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE RESTRICT,
    proficiency_level VARCHAR(50) NOT NULL DEFAULT 'beginner',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verification_score NUMERIC(5, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_student_skill UNIQUE (student_id, skill_id),
    CONSTRAINT chk_proficiency CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced', 'expert'))
);

-- 4. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_skills_category_id ON skills(category_id);
CREATE INDEX IF NOT EXISTS idx_student_skills_student_id ON student_skills(student_id);
CREATE INDEX IF NOT EXISTS idx_student_skills_skill_id ON student_skills(skill_id);

-- 5. Insert Sample Skill Categories
INSERT INTO skill_categories (name, description) VALUES
    ('Frontend Development', 'Web and mobile user interface technologies'),
    ('Backend & Systems', 'Server-side programming, APIs, and microservices'),
    ('Databases & Storage', 'Relational and NoSQL database management'),
    ('Artificial Intelligence', 'Machine Learning, Deep Learning, and NLP'),
    ('DevOps & Cloud', 'CI/CD, containerization, and cloud infrastructure')
ON CONFLICT (name) DO NOTHING;

-- 6. Insert Sample Master Skills (Fixed: avoid SQL reserved keyword 'desc')
INSERT INTO skills (category_id, name, description)
SELECT sc.id, s.skill_name, s.skill_description
FROM skill_categories sc
JOIN (VALUES
    ('Frontend Development', 'React', 'JavaScript library for building user interfaces'),
    ('Frontend Development', 'TypeScript', 'Typed superset of JavaScript'),
    ('Backend & Systems', 'Python', 'Versatile high-level programming language'),
    ('Backend & Systems', 'FastAPI', 'High-performance Python web framework'),
    ('Backend & Systems', 'Node.js', 'JavaScript runtime built on Chrome V8 engine'),
    ('Databases & Storage', 'PostgreSQL', 'Advanced open-source relational database'),
    ('Databases & Storage', 'Redis', 'In-memory data structure store and cache'),
    ('Artificial Intelligence', 'Machine Learning', 'Statistical models for automated prediction'),
    ('DevOps & Cloud', 'Docker', 'Platform for containerizing software applications'),
    ('DevOps & Cloud', 'Git', 'Distributed version control system')
) AS s(cat_name, skill_name, skill_description) ON sc.name = s.cat_name
ON CONFLICT (name) DO NOTHING;
