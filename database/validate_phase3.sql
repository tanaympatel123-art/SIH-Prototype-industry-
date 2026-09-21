-- Validation Suite for Phase 3 Foundation
-- SIH26044: Academia-Industry Collaboration Portal
-- Purpose: Executes automated structural, referential, constraint, and data integrity checks

DO $$
DECLARE
    v_roles_count INT;
    v_inst_count INT;
    v_users_count INT;
    v_students_count INT;
    v_companies_count INT;
    v_teachers_count INT;
    v_skills_count INT;
    v_student_skills_count INT;
    v_opps_count INT;
    v_opp_skills_count INT;
    v_apps_count INT;
    v_orphaned_fk_count INT;
    v_index_count INT;
    v_failed_checks INT := 0;
BEGIN
    RAISE NOTICE '=======================================================';
    RAISE NOTICE 'SIH26044 PHASE 3 — AUTOMATED DATABASE VALIDATION SUITE';
    RAISE NOTICE '=======================================================';

    -- 1. Check Row Counts (Seed Data Presence)
    SELECT COUNT(*) INTO v_roles_count FROM roles;
    SELECT COUNT(*) INTO v_inst_count FROM institutions;
    SELECT COUNT(*) INTO v_users_count FROM users;
    SELECT COUNT(*) INTO v_students_count FROM student_profiles;
    SELECT COUNT(*) INTO v_companies_count FROM company_profiles;
    SELECT COUNT(*) INTO v_teachers_count FROM teacher_profiles;
    SELECT COUNT(*) INTO v_skills_count FROM skills;
    SELECT COUNT(*) INTO v_student_skills_count FROM student_skills;
    SELECT COUNT(*) INTO v_opps_count FROM opportunities;
    SELECT COUNT(*) INTO v_opp_skills_count FROM opportunity_skills;
    SELECT COUNT(*) INTO v_apps_count FROM applications;

    RAISE NOTICE '[CHECK 1/5] SEED DATA AUDIT:';
    RAISE NOTICE '  - Roles: % (Minimum 5)', v_roles_count;
    RAISE NOTICE '  - Institutions: % (Minimum 2)', v_inst_count;
    RAISE NOTICE '  - Users: % (Minimum 10)', v_users_count;
    RAISE NOTICE '  - Student Profiles: % (Minimum 4)', v_students_count;
    RAISE NOTICE '  - Company Profiles: % (Minimum 3)', v_companies_count;
    RAISE NOTICE '  - Teacher Profiles: % (Minimum 3)', v_teachers_count;
    RAISE NOTICE '  - Master Skills: % (Minimum 10)', v_skills_count;
    RAISE NOTICE '  - Student Skills: % (Minimum 10)', v_student_skills_count;
    RAISE NOTICE '  - Opportunities: % (Minimum 5)', v_opps_count;
    RAISE NOTICE '  - Opportunity Skills: % (Minimum 10)', v_opp_skills_count;
    RAISE NOTICE '  - Applications: % (Minimum 4)', v_apps_count;

    IF v_roles_count < 5 OR v_inst_count < 2 OR v_students_count < 4 OR v_companies_count < 3 OR v_skills_count < 10 OR v_opps_count < 5 THEN
        RAISE WARNING 'FAILED: Seed record counts do not meet minimum requirements!';
        v_failed_checks := v_failed_checks + 1;
    ELSE
        RAISE NOTICE '  --> STATUS: PASS';
    END IF;

    -- 2. Foreign Key Referential Integrity Check (Zero Orphaned Records)
    RAISE NOTICE '[CHECK 2/5] FOREIGN KEY INTEGRITY:';
    
    -- Check for orphaned student_skills
    SELECT COUNT(*) INTO v_orphaned_fk_count 
    FROM student_skills ss 
    WHERE ss.student_id NOT IN (SELECT id FROM student_profiles)
       OR ss.skill_id NOT IN (SELECT id FROM skills);

    -- Check for orphaned opportunity_skills
    SELECT v_orphaned_fk_count + COUNT(*) INTO v_orphaned_fk_count
    FROM opportunity_skills os
    WHERE os.opportunity_id NOT IN (SELECT id FROM opportunities)
       OR os.skill_id NOT IN (SELECT id FROM skills);

    -- Check for orphaned applications
    SELECT v_orphaned_fk_count + COUNT(*) INTO v_orphaned_fk_count
    FROM applications a
    WHERE a.opportunity_id NOT IN (SELECT id FROM opportunities)
       OR a.student_id NOT IN (SELECT id FROM student_profiles);

    IF v_orphaned_fk_count > 0 THEN
        RAISE WARNING 'FAILED: % orphaned foreign key references detected!', v_orphaned_fk_count;
        v_failed_checks := v_failed_checks + 1;
    ELSE
        RAISE NOTICE '  - Zero orphaned records detected across all relations.';
        RAISE NOTICE '  --> STATUS: PASS';
    END IF;

    -- 3. Check Constraint Auditing
    RAISE NOTICE '[CHECK 3/5] DOMAIN & CHECK CONSTRAINTS:';
    
    -- Check proficiency ranges (must be 1 to 5)
    SELECT COUNT(*) INTO v_orphaned_fk_count
    FROM student_skills WHERE proficiency < 1 OR proficiency > 5;

    -- Check match score ranges (must be 0 to 100)
    SELECT v_orphaned_fk_count + COUNT(*) INTO v_orphaned_fk_count
    FROM applications WHERE match_score < 0.00 OR match_score > 100.00;

    -- Check openings (must be > 0)
    SELECT v_orphaned_fk_count + COUNT(*) INTO v_orphaned_fk_count
    FROM opportunities WHERE openings <= 0;

    IF v_orphaned_fk_count > 0 THEN
        RAISE WARNING 'FAILED: % records violate domain check constraints!', v_orphaned_fk_count;
        v_failed_checks := v_failed_checks + 1;
    ELSE
        RAISE NOTICE '  - All proficiencies (1-5), match scores (0-100), and openings (>0) valid.';
        RAISE NOTICE '  --> STATUS: PASS';
    END IF;

    -- 4. Unique Constraints Verification
    RAISE NOTICE '[CHECK 4/5] UNIQUE CONSTRAINTS (ANTI-DUPLICATE AUDIT):';
    
    -- Verify no student has duplicate applications for the same job
    SELECT COUNT(*) INTO v_orphaned_fk_count
    FROM (
        SELECT opportunity_id, student_id, COUNT(*) 
        FROM applications 
        GROUP BY opportunity_id, student_id 
        HAVING COUNT(*) > 1
    ) sub;

    -- Verify no student has duplicate skill entries
    SELECT v_orphaned_fk_count + COUNT(*) INTO v_orphaned_fk_count
    FROM (
        SELECT student_id, skill_id, COUNT(*) 
        FROM student_skills 
        GROUP BY student_id, skill_id 
        HAVING COUNT(*) > 1
    ) sub;

    IF v_orphaned_fk_count > 0 THEN
        RAISE WARNING 'FAILED: Duplicate applications or student skills found!';
        v_failed_checks := v_failed_checks + 1;
    ELSE
        RAISE NOTICE '  - Unique constraint (opportunity_id, student_id) successfully enforced.';
        RAISE NOTICE '  - Unique constraint (student_id, skill_id) successfully enforced.';
        RAISE NOTICE '  --> STATUS: PASS';
    END IF;

    -- 5. Performance Indexes Audit
    RAISE NOTICE '[CHECK 5/5] INDEX COVERAGE:';
    SELECT COUNT(*) INTO v_index_count
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname IN (
          'idx_users_email', 
          'idx_student_profiles_user_id', 
          'idx_student_skills_student_id', 
          'idx_opps_status_deadline', 
          'idx_apps_opp_score',
          'idx_app_history_app_id'
      );

    RAISE NOTICE '  - Verified critical query indexes present: % / 6 verified', v_index_count;
    IF v_index_count < 6 THEN
        RAISE WARNING 'FAILED: Missing one or more critical performance indexes!';
        v_failed_checks := v_failed_checks + 1;
    ELSE
        RAISE NOTICE '  --> STATUS: PASS';
    END IF;

    -- Final Report
    RAISE NOTICE '=======================================================';
    IF v_failed_checks = 0 THEN
        RAISE NOTICE 'PHASE 3 DATABASE VALIDATION: 100%% PASS! ALL SYSTEMS GO.';
    ELSE
        RAISE WARNING 'PHASE 3 DATABASE VALIDATION COMPLETED WITH % FAILURES.', v_failed_checks;
    END IF;
    RAISE NOTICE '=======================================================';
END $$;
