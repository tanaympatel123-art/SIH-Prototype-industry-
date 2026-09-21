-- Seed & Simulation Script: End-to-End SIH Workflow Test
-- SIH26044: Academia-Industry Collaboration Portal

DO $$
DECLARE
    v_student_role_id SMALLINT;
    v_company_role_id SMALLINT;
    v_dtu_id UUID;
    v_student_user_id UUID;
    v_student_profile_id UUID;
    v_company_user_id UUID;
    v_company_profile_id UUID;
    v_opp_id UUID;
    v_python_id UUID;
    v_postgres_id UUID;
    v_git_id UUID;
    v_resume_id UUID;
    v_app_id UUID;
BEGIN
    -- 1. Get Role IDs
    SELECT id INTO v_student_role_id FROM roles WHERE name = 'student';
    SELECT id INTO v_company_role_id FROM roles WHERE name = 'company';

    -- 2. Get Institution ID (DTU)
    SELECT id INTO v_dtu_id FROM institutions WHERE code = 'AISHE-U-0099';

    -- 3. Create Student User & Profile
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('rahul.sharma@dtu.ac.in', '$2b$12$e8YkZ7kGf5.sample_hashed_password', v_student_role_id)
    RETURNING id INTO v_student_user_id;

    INSERT INTO student_profiles (user_id, institution_id, first_name, last_name, roll_number, department, current_semester, cgpa, graduation_year)
    VALUES (v_student_user_id, v_dtu_id, 'Rahul', 'Sharma', '2022CS0142', 'Computer Science', 6, 8.85, 2025)
    RETURNING id INTO v_student_profile_id;

    -- 4. Get Skill IDs
    SELECT id INTO v_python_id FROM skills WHERE name = 'Python';
    SELECT id INTO v_postgres_id FROM skills WHERE name = 'PostgreSQL';
    SELECT id INTO v_git_id FROM skills WHERE name = 'Git';

    -- 5. Assign Skills to Student
    INSERT INTO student_skills (student_id, skill_id, proficiency_level, is_verified, verification_score)
    VALUES
        (v_student_profile_id, v_python_id, 'intermediate', TRUE, 85.00),
        (v_student_profile_id, v_postgres_id, 'intermediate', TRUE, 90.00),
        (v_student_profile_id, v_git_id, 'beginner', FALSE, NULL);

    -- 6. Create Company User & Profile
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('campus.hiring@techcorp.in', '$2b$12$e8YkZ7kGf5.sample_hashed_password', v_company_role_id)
    RETURNING id INTO v_company_user_id;

    INSERT INTO company_profiles (user_id, company_name, industry_type, website, registration_number, headquarters, verification_status)
    VALUES (v_company_user_id, 'TechCorp Solutions', 'Information Technology', 'https://techcorp.in', 'U72200MH2020PTC123456', 'Bengaluru', 'verified')
    RETURNING id INTO v_company_profile_id;

    -- 7. Company Posts an Internship
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend_amount, duration_months, openings_count, description, application_deadline)
    VALUES (
        v_company_profile_id,
        'Backend Developer Intern (Python & Postgres)',
        'internship',
        'remote',
        'Bengaluru / Remote',
        25000.00,
        6,
        3,
        'Join our core engineering team to build scalable APIs using FastAPI and PostgreSQL.',
        NOW() + INTERVAL '30 days'
    )
    RETURNING id INTO v_opp_id;

    -- 8. Add Required Skills for this Internship (Python & PostgreSQL)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, is_mandatory, min_proficiency)
    VALUES
        (v_opp_id, v_python_id, TRUE, 'intermediate'),
        (v_opp_id, v_postgres_id, TRUE, 'intermediate');

    -- 9. Student Uploads a Resume
    INSERT INTO resumes (student_id, file_name, file_url, file_size_bytes, is_primary)
    VALUES (v_student_profile_id, 'Rahul_Sharma_Resume.pdf', 'https://storage.portal.in/resumes/rahul_cv.pdf', 245000, TRUE)
    RETURNING id INTO v_resume_id;

    -- 10. Student Applies for the Internship (100% Match!)
    INSERT INTO applications (opportunity_id, student_id, resume_id, cover_letter, match_score, status)
    VALUES (
        v_opp_id,
        v_student_profile_id,
        v_resume_id,
        'I have hands-on experience building backend APIs with Python and relational modeling with PostgreSQL.',
        100.00,
        'applied'
    )
    RETURNING id INTO v_app_id;

    -- 11. Record Initial Application History
    INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks)
    VALUES (v_app_id, NULL, 'applied', v_student_user_id, 'Application submitted by student with 100% verified skill match.');

    RAISE NOTICE 'SUCCESS: End-to-end workflow simulation data populated successfully!';
END $$;
