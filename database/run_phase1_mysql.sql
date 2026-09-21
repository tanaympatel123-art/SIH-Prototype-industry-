-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1 Master Runner Script (MySQL 8.x / MariaDB)
-- Purpose: Creates schema, inserts seed data, and executes test verification queries.
-- Usage:
--   mysql -u root < database/run_phase1_mysql.sql
-- ==============================================================================

-- 1. Run Complete Schema
SOURCE c:/Users/divya/Downloads/sih26044/database/schema/all_in_one_phase1.sql;

-- 2. Populate Demonstration Seeds
SOURCE c:/Users/divya/Downloads/sih26044/database/seeds/phase1_seed.sql;

-- 3. Execute Phase 1 Verification Queries
SOURCE c:/Users/divya/Downloads/sih26044/database/queries/phase1_test_queries.sql;
