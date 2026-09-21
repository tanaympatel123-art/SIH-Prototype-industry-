-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Database Foundation
-- File: 05_skills.sql
-- Entity: skills
-- Purpose: Canonical master skill taxonomy
-- Self-Referencing Foreign Key (parent_skill_id) Rationale:
--   Enables a recursive hierarchical skill ontology (e.g., SQL -> MySQL,
--   JavaScript -> React / Angular, Machine Learning -> Deep Learning).
--   This enables ontology roll-ups, parent-child skill inheritance, and advanced
--   candidate matching where specialized capability implies foundational mastery.
-- ==============================================================================

USE sih26044_db;

CREATE TABLE IF NOT EXISTS skills (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NULL,
    parent_skill_id INT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_skills_skill_name UNIQUE (skill_name),
    CONSTRAINT fk_skills_parent FOREIGN KEY (parent_skill_id) 
        REFERENCES skills(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_skills_category (category),
    INDEX idx_skills_parent_id (parent_skill_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed canonical master skill taxonomy with hierarchical relationships
-- 1. Base foundational skills
INSERT INTO skills (id, skill_name, category, description, parent_skill_id) VALUES
    (1, 'Python', 'Programming Languages', 'General-purpose high-level programming language', NULL),
    (2, 'Java', 'Programming Languages', 'Object-oriented class-based programming language', NULL),
    (3, 'C++', 'Programming Languages', 'High-performance compiled systems programming language', NULL),
    (4, 'SQL', 'Databases', 'Standard query language for relational database management systems', NULL),
    (5, 'HTML', 'Web Development', 'Standard markup language for web document structure', NULL),
    (6, 'CSS', 'Web Development', 'Style sheet language for web presentation and layout', NULL),
    (7, 'JavaScript', 'Web Development', 'Dynamic scripting language for web client and server execution', NULL),
    (8, 'Machine Learning', 'Artificial Intelligence', 'Algorithms and statistical models that learn from data', NULL),
    (9, 'Data Structures', 'Computer Science Fundamentals', 'Organization, management, and storage formats for efficient access', NULL)
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- 2. Derived specialized child skills referencing parent skills
INSERT INTO skills (id, skill_name, category, description, parent_skill_id) VALUES
    (10, 'MySQL', 'Databases', 'Open-source relational database management system', 4),
    (11, 'React', 'Web Development', 'Declarative component-based JavaScript library for user interfaces', 7),
    (12, 'Angular', 'Web Development', 'TypeScript-based open-source web application framework', 7),
    (13, 'Deep Learning', 'Artificial Intelligence', 'Neural network architectures modeled on human cognitive processes', 8),
    (14, 'Git & Version Control', 'DevOps & Tools', 'Distributed version control system for source code tracking', NULL)
ON DUPLICATE KEY UPDATE description = VALUES(description), parent_skill_id = VALUES(parent_skill_id);
