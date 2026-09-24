-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 2: One-Click MySQL Runner
-- File: run_phase2_mysql.sql
-- Target: MySQL 8.x — run from MySQL CLI or phpMyAdmin
-- Usage (CLI):
--   mysql -u root -p sih26044_db < run_phase2_mysql.sql
-- Usage (phpMyAdmin):
--   Open SQL tab → paste this file → Execute
-- ==============================================================================
-- RUN ORDER:
--   Step 1  — 014_phase2_stored_procedures.sql  (ALTER + SP definitions)
--   Step 2  — 015_phase2_indexes.sql            (5 compound indexes)
--   Step 3  — phase2_expanded_seed.sql          (30+ students, 5 companies, etc.)
--   Step 4  — phase2_benchmark_queries.sql      (EXPLAIN + results)
-- ==============================================================================

SELECT '========================================' AS '';
SELECT 'SIH26044 — DATABASE PHASE 2 RUNNER' AS '';
SELECT '========================================' AS '';
SELECT NOW() AS run_started_at;

USE sih26044_db;

-- ------------------------------------------------------------------------------
-- STEP 1: Stored Procedures & Schema Alterations
-- ------------------------------------------------------------------------------
SELECT 'STEP 1: Running stored procedures migration...' AS step;
SOURCE database/migrations/014_phase2_stored_procedures.sql;
SELECT 'STEP 1: COMPLETE' AS status;

-- ------------------------------------------------------------------------------
-- STEP 2: Compound Indexes
-- ------------------------------------------------------------------------------
SELECT 'STEP 2: Creating compound indexes...' AS step;
SOURCE database/migrations/015_phase2_indexes.sql;
SELECT 'STEP 2: COMPLETE' AS status;

-- ------------------------------------------------------------------------------
-- STEP 3: Expanded Seed Dataset
-- ------------------------------------------------------------------------------
SELECT 'STEP 3: Loading expanded seed data...' AS step;
SOURCE database/seeds/phase2_expanded_seed.sql;
SELECT 'STEP 3: COMPLETE' AS status;

-- ------------------------------------------------------------------------------
-- STEP 4: Benchmark Queries
-- ------------------------------------------------------------------------------
SELECT 'STEP 4: Running benchmark EXPLAIN queries...' AS step;
SOURCE database/queries/phase2_benchmark_queries.sql;
SELECT 'STEP 4: COMPLETE' AS status;

-- ------------------------------------------------------------------------------
-- FINAL STATUS
-- ------------------------------------------------------------------------------
SELECT '========================================'   AS '';
SELECT 'PHASE 2 RUNNER — ALL STEPS COMPLETE'       AS '';
SELECT '========================================'   AS '';
SELECT NOW() AS run_finished_at;

SELECT
    'SUMMARY' AS '',
    (SELECT COUNT(*) FROM information_schema.routines
     WHERE routine_schema = 'sih26044_db' AND routine_type = 'PROCEDURE') AS stored_procedures,
    (SELECT COUNT(*) FROM information_schema.statistics
     WHERE table_schema = 'sih26044_db'
       AND index_name IN (
           'idx_ss_student_verified_proficiency',
           'idx_os_opportunity_mandatory_skill',
           'idx_app_opportunity_status_student',
           'idx_sv_teacher_status_skill',
           'idx_opp_status_deadline_company'
       )
    )                                                AS phase2_indexes_created,
    (SELECT COUNT(*) FROM student_profiles)          AS total_students,
    (SELECT COUNT(*) FROM company_profiles)          AS total_companies,
    (SELECT COUNT(*) FROM opportunities)             AS total_opportunities,
    (SELECT COUNT(*) FROM applications)              AS total_applications;
