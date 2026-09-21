-- Seed Data for Phase 3 Foundation
-- SIH26044: Academia-Industry Collaboration Portal
-- Deterministic datasets: 2 Institutions, 5 Roles, 3 Companies, 4 Students, 3 Teachers, 12 Skills, 6 Opportunities, Applications

DO $$
DECLARE
    -- Role IDs
    r_student SMALLINT;
    r_teacher SMALLINT;
    r_company SMALLINT;
    r_institution SMALLINT;
    r_admin SMALLINT;

    -- Institution IDs
    inst_dtu UUID;
    inst_iitb UUID;

    -- User IDs
    u_c1 UUID; u_c2 UUID; u_c3 UUID;
    u_s1 UUID; u_s2 UUID; u_s3 UUID; u_s4 UUID;
    u_t1 UUID; u_t2 UUID; u_t3 UUID;

    -- Profile IDs
    cp1 UUID; cp2 UUID; cp3 UUID;
    sp1 UUID; sp2 UUID; sp3 UUID; sp4 UUID;
    tp1 UUID; tp2 UUID; tp3 UUID;

    -- Skill Category IDs
    cat_prog INT; cat_web INT; cat_db INT; cat_devops INT; cat_ai INT;

    -- Skill IDs
    sk_python UUID; sk_java UUID; sk_js UUID;
    sk_react UUID; sk_node UUID;
    sk_postgres UUID; sk_redis UUID;
    sk_docker UUID; sk_git UUID; sk_k8s UUID;
    sk_ml UUID; sk_dl UUID;

    -- Opportunity IDs
    opp1 UUID; opp2 UUID; opp3 UUID; opp4 UUID; opp5 UUID; opp6 UUID;

    -- Application IDs
    app1 UUID; app2 UUID; app3 UUID;
BEGIN
    -- 1. Fetch Role IDs
    SELECT id INTO r_student FROM roles WHERE name = 'student';
    SELECT id INTO r_teacher FROM roles WHERE name = 'teacher';
    SELECT id INTO r_company FROM roles WHERE name = 'company';
    SELECT id INTO r_institution FROM roles WHERE name = 'institution';
    SELECT id INTO r_admin FROM roles WHERE name = 'admin';

    -- 2. Seed Institutions
    INSERT INTO institutions (name, code, website, city, state, is_verified) VALUES
        ('Delhi Technological University', 'AISHE-U-0099', 'https://www.dtu.ac.in', 'New Delhi', 'Delhi', TRUE)
    ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO inst_dtu;

    INSERT INTO institutions (name, code, website, city, state, is_verified) VALUES
        ('Indian Institute of Technology Bombay', 'AISHE-U-0306', 'https://www.iitb.ac.in', 'Mumbai', 'Maharashtra', TRUE)
    ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name RETURNING id INTO inst_iitb;

    -- 3. Seed Companies (3 Companies)
    -- Company 1: TechCorp
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('careers@techcorp.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_company)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_c1;

    INSERT INTO company_profiles (user_id, company_name, industry_type, website, registration_number, company_size, headquarters, verification_status)
    VALUES (u_c1, 'TechCorp Solutions', 'Information Technology', 'https://techcorp.in', 'U72200MH2020PTC123456', '51-200', 'Bengaluru', 'verified')
    ON CONFLICT (user_id) DO UPDATE SET company_name = EXCLUDED.company_name RETURNING id INTO cp1;

    -- Company 2: CloudScale Networks
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('talent@cloudscale.io', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_company)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_c2;

    INSERT INTO company_profiles (user_id, company_name, industry_type, website, registration_number, company_size, headquarters, verification_status)
    VALUES (u_c2, 'CloudScale Networks', 'Cloud & DevOps Infrastructure', 'https://cloudscale.io', 'U72200KA2021PTC654321', '201-500', 'Hyderabad', 'verified')
    ON CONFLICT (user_id) DO UPDATE SET company_name = EXCLUDED.company_name RETURNING id INTO cp2;

    -- Company 3: Quantum AI Labs
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('hr@quantumai.org', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_company)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_c3;

    INSERT INTO company_profiles (user_id, company_name, industry_type, website, registration_number, company_size, headquarters, verification_status)
    VALUES (u_c3, 'Quantum AI Labs', 'Artificial Intelligence & Robotics', 'https://quantumai.org', 'U72200DL2022PTC998877', '11-50', 'Pune', 'verified')
    ON CONFLICT (user_id) DO UPDATE SET company_name = EXCLUDED.company_name RETURNING id INTO cp3;

    -- 4. Seed Teachers (3 Teachers)
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('rajesh.kumar@dtu.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_teacher)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_t1;

    INSERT INTO teacher_profiles (user_id, institution_id, first_name, last_name, faculty_id, designation, department, specialization)
    VALUES (u_t1, inst_dtu, 'Rajesh', 'Kumar', 'FAC-DTU-01', 'Professor', 'Computer Science', 'Distributed Systems & Databases')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO tp1;

    INSERT INTO users (email, password_hash, role_id)
    VALUES ('anita.desai@iitb.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_teacher)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_t2;

    INSERT INTO teacher_profiles (user_id, institution_id, first_name, last_name, faculty_id, designation, department, specialization)
    VALUES (u_t2, inst_iitb, 'Anita', 'Desai', 'FAC-IITB-42', 'Associate Professor', 'Electrical Engineering', 'Deep Learning & Signal Processing')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO tp2;

    INSERT INTO users (email, password_hash, role_id)
    VALUES ('vikram.singh@dtu.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_teacher)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_t3;

    INSERT INTO teacher_profiles (user_id, institution_id, first_name, last_name, faculty_id, designation, department, specialization)
    VALUES (u_t3, inst_dtu, 'Vikram', 'Singh', 'FAC-DTU-18', 'Assistant Professor', 'Information Technology', 'Cloud Computing & DevOps')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO tp3;

    -- 5. Seed Students (4 Students)
    -- Student 1: Rahul Sharma (DTU, CS)
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('rahul.sharma@dtu.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_student)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_s1;

    INSERT INTO student_profiles (user_id, institution_id, first_name, last_name, roll_number, department, current_semester, cgpa, graduation_year, headline)
    VALUES (u_s1, inst_dtu, 'Rahul', 'Sharma', '2022CS0142', 'Computer Science', 6, 8.85, 2025, 'Aspiring Backend & Systems Engineer')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO sp1;

    -- Student 2: Priya Patel (IIT Bombay, EE)
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('priya.patel@iitb.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_student)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_s2;

    INSERT INTO student_profiles (user_id, institution_id, first_name, last_name, roll_number, department, current_semester, cgpa, graduation_year, headline)
    VALUES (u_s2, inst_iitb, 'Priya', 'Patel', '2021EE0089', 'Electrical Engineering', 8, 9.20, 2024, 'Machine Learning & Embedded AI Researcher')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO sp2;

    -- Student 3: Amit Verma (DTU, IT)
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('amit.verma@dtu.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_student)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_s3;

    INSERT INTO student_profiles (user_id, institution_id, first_name, last_name, roll_number, department, current_semester, cgpa, graduation_year, headline)
    VALUES (u_s3, inst_dtu, 'Amit', 'Verma', '2022IT0055', 'Information Technology', 6, 7.90, 2025, 'Full Stack Web Developer & UI Enthusiast')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO sp3;

    -- Student 4: Sneha Reddy (IIT Bombay, CS)
    INSERT INTO users (email, password_hash, role_id)
    VALUES ('sneha.reddy@iitb.ac.in', '$2b$12$e8YkZ7kGf5.hashed_password_for_seed', r_student)
    ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email RETURNING id INTO u_s4;

    INSERT INTO student_profiles (user_id, institution_id, first_name, last_name, roll_number, department, current_semester, cgpa, graduation_year, headline)
    VALUES (u_s4, inst_iitb, 'Sneha', 'Reddy', '2023CS0012', 'Computer Science', 4, 9.45, 2026, 'Competitive Programmer & Java Developer')
    ON CONFLICT (user_id) DO UPDATE SET first_name = EXCLUDED.first_name RETURNING id INTO sp4;

    -- 6. Seed Skill Categories
    INSERT INTO skill_categories (name, description) VALUES
        ('Programming', 'Core programming and computational thinking'),
        ('Web Development', 'Modern frontend and backend web architecture'),
        ('Databases', 'Relational, document, and in-memory data systems'),
        ('Cloud & DevOps', 'Continuous delivery, containers, and infrastructure as code'),
        ('Artificial Intelligence', 'Machine learning algorithms, neural nets, and statistical modeling')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO cat_prog FROM skill_categories WHERE name = 'Programming';
    SELECT id INTO cat_web FROM skill_categories WHERE name = 'Web Development';
    SELECT id INTO cat_db FROM skill_categories WHERE name = 'Databases';
    SELECT id INTO cat_devops FROM skill_categories WHERE name = 'Cloud & DevOps';
    SELECT id INTO cat_ai FROM skill_categories WHERE name = 'Artificial Intelligence';

    -- 7. Seed Skills with Hierarchy (12 Skills)
    INSERT INTO skills (category_id, name, description) VALUES
        (cat_prog, 'Python', 'Interpreted high-level language widely used in AI and web development'),
        (cat_prog, 'Java', 'Object-oriented language popular in enterprise and Android development'),
        (cat_prog, 'JavaScript', 'Dynamic web programming language running in browser and Node.js')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_python FROM skills WHERE name = 'Python';
    SELECT id INTO sk_java FROM skills WHERE name = 'Java';
    SELECT id INTO sk_js FROM skills WHERE name = 'JavaScript';

    -- Sub-skills referencing parent skills
    INSERT INTO skills (category_id, parent_skill_id, name, description) VALUES
        (cat_web, sk_js, 'React', 'Component-based frontend library for declarative UI building'),
        (cat_web, sk_js, 'Node.js', 'Asynchronous event-driven JavaScript server environment')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_react FROM skills WHERE name = 'React';
    SELECT id INTO sk_node FROM skills WHERE name = 'Node.js';

    -- Database skills
    INSERT INTO skills (category_id, name, description) VALUES
        (cat_db, 'PostgreSQL', 'Enterprise open-source relational object database'),
        (cat_db, 'Redis', 'In-memory key-value data structure store used for caching')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_postgres FROM skills WHERE name = 'PostgreSQL';
    SELECT id INTO sk_redis FROM skills WHERE name = 'Redis';

    -- Cloud & DevOps skills
    INSERT INTO skills (category_id, name, description) VALUES
        (cat_devops, 'Docker', 'Container engine enabling consistent application virtualization'),
        (cat_devops, 'Git', 'Distributed source code version control system')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_docker FROM skills WHERE name = 'Docker';
    SELECT id INTO sk_git FROM skills WHERE name = 'Git';

    INSERT INTO skills (category_id, parent_skill_id, name, description) VALUES
        (cat_devops, sk_docker, 'Kubernetes', 'Container orchestration engine for automated scaling')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_k8s FROM skills WHERE name = 'Kubernetes';

    -- AI skills
    INSERT INTO skills (category_id, name, description) VALUES
        (cat_ai, 'Machine Learning', 'Predictive statistical modelling and supervised/unsupervised learning')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_ml FROM skills WHERE name = 'Machine Learning';

    INSERT INTO skills (category_id, parent_skill_id, name, description) VALUES
        (cat_ai, sk_ml, 'Deep Learning', 'Multi-layer neural architectures for vision, NLP, and generative tasks')
    ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

    SELECT id INTO sk_dl FROM skills WHERE name = 'Deep Learning';

    -- 8. Seed Student Skills (Students with multiple skills)
    -- Rahul: Python(4), PostgreSQL(4), Git(3)
    INSERT INTO student_skills (student_id, skill_id, proficiency, assessment_score, source, confidence_score, is_verified) VALUES
        (sp1, sk_python, 4, 88.00, 'quiz_assessment', 0.90, TRUE),
        (sp1, sk_postgres, 4, 92.00, 'teacher_endorsement', 0.95, TRUE),
        (sp1, sk_git, 3, 75.00, 'self_reported', 0.70, FALSE)
    ON CONFLICT (student_id, skill_id) DO UPDATE SET proficiency = EXCLUDED.proficiency;

    -- Priya: Python(5), Machine Learning(4), Deep Learning(4), Docker(3)
    INSERT INTO student_skills (student_id, skill_id, proficiency, assessment_score, source, confidence_score, is_verified) VALUES
        (sp2, sk_python, 5, 96.00, 'quiz_assessment', 0.98, TRUE),
        (sp2, sk_ml, 4, 90.00, 'teacher_endorsement', 0.92, TRUE),
        (sp2, sk_dl, 4, 86.00, 'teacher_endorsement', 0.88, TRUE),
        (sp2, sk_docker, 3, 70.00, 'self_reported', 0.65, FALSE)
    ON CONFLICT (student_id, skill_id) DO UPDATE SET proficiency = EXCLUDED.proficiency;

    -- Amit: JavaScript(3), React(3), Git(2)
    INSERT INTO student_skills (student_id, skill_id, proficiency, assessment_score, source, confidence_score, is_verified) VALUES
        (sp3, sk_js, 3, 72.00, 'self_reported', 0.70, FALSE),
        (sp3, sk_react, 3, 78.00, 'quiz_assessment', 0.80, TRUE),
        (sp3, sk_git, 2, NULL, 'self_reported', 0.50, FALSE)
    ON CONFLICT (student_id, skill_id) DO UPDATE SET proficiency = EXCLUDED.proficiency;

    -- Sneha: Java(4), PostgreSQL(3), Git(3)
    INSERT INTO student_skills (student_id, skill_id, proficiency, assessment_score, source, confidence_score, is_verified) VALUES
        (sp4, sk_java, 4, 90.00, 'quiz_assessment', 0.92, TRUE),
        (sp4, sk_postgres, 3, 80.00, 'self_reported', 0.75, FALSE),
        (sp4, sk_git, 3, 74.00, 'self_reported', 0.70, FALSE)
    ON CONFLICT (student_id, skill_id) DO UPDATE SET proficiency = EXCLUDED.proficiency;

    -- 9. Seed Opportunities (TechCorp has 3 opportunities; CloudScale has 1; Quantum AI has 2 = Total 6)
    -- Opportunity 1: Backend Developer Intern (TechCorp)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp1, 'Backend Developer Intern', 'internship', 'remote', 'Bengaluru / Remote', 25000.00, 6, 3,
        NOW() + INTERVAL '30 days', 'Build and deploy RESTful microservices with Python, PostgreSQL, and Git.'
    ) RETURNING id INTO opp1;

    -- Opportunity 2: Full Stack Web Intern (TechCorp)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp1, 'Full Stack Web Intern', 'internship', 'hybrid', 'Bengaluru', 22000.00, 4, 2,
        NOW() + INTERVAL '25 days', 'Develop interactive dashboard portals using React, Node.js, and PostgreSQL.'
    ) RETURNING id INTO opp2;

    -- Opportunity 3: Data Engineering Intern (TechCorp)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp1, 'Data Engineering Intern', 'internship', 'on_site', 'Bengaluru', 28000.00, 6, 2,
        NOW() + INTERVAL '45 days', 'Construct scalable batch pipelines utilizing Python, PostgreSQL, and Redis.'
    ) RETURNING id INTO opp3;

    -- Opportunity 4: Cloud DevOps Apprentice (CloudScale Networks)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp2, 'Cloud DevOps Apprentice', 'internship', 'remote', 'Hyderabad / Remote', 30000.00, 6, 2,
        NOW() + INTERVAL '20 days', 'Automate CI/CD workflows and manage container clusters using Docker and Kubernetes.'
    ) RETURNING id INTO opp4;

    -- Opportunity 5: Machine Learning Research Intern (Quantum AI Labs)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp3, 'Machine Learning Research Intern', 'internship', 'hybrid', 'Pune', 35000.00, 6, 1,
        NOW() + INTERVAL '15 days', 'Train predictive and deep neural architectures on high-dimensional datasets.'
    ) RETURNING id INTO opp5;

    -- Opportunity 6: Frontend React Developer (Quantum AI Labs)
    INSERT INTO opportunities (company_id, title, opportunity_type, work_mode, location, stipend, duration_months, openings, deadline, description)
    VALUES (
        cp3, 'Frontend React Developer', 'internship', 'remote', 'Pune / Remote', 20000.00, 3, 2,
        NOW() + INTERVAL '40 days', 'Build real-time AI dashboard interfaces with React and JavaScript.'
    ) RETURNING id INTO opp6;

    -- 10. Seed Opportunity Required Skills (Multiple required skills per opportunity)
    -- Backend Developer Intern: Python (weight 1.5, prof 3), PostgreSQL (weight 1.5, prof 3), Git (weight 1.0, prof 2)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp1, sk_python, 3, TRUE, 1.50),
        (opp1, sk_postgres, 3, TRUE, 1.50),
        (opp1, sk_git, 2, FALSE, 1.00);

    -- Full Stack Web Intern: React (weight 1.5, prof 3), Node.js (weight 1.2, prof 3), PostgreSQL (weight 1.0, prof 2)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp2, sk_react, 3, TRUE, 1.50),
        (opp2, sk_node, 3, TRUE, 1.20),
        (opp2, sk_postgres, 2, FALSE, 1.00);

    -- Data Engineering Intern: Python (weight 1.5, prof 4), PostgreSQL (weight 1.5, prof 4), Redis (weight 1.0, prof 2)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp3, sk_python, 4, TRUE, 1.50),
        (opp3, sk_postgres, 4, TRUE, 1.50),
        (opp3, sk_redis, 2, FALSE, 1.00);

    -- Cloud DevOps Apprentice: Docker (weight 1.5, prof 3), Kubernetes (weight 1.5, prof 3), Git (weight 1.0, prof 2)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp4, sk_docker, 3, TRUE, 1.50),
        (opp4, sk_k8s, 3, TRUE, 1.50),
        (opp4, sk_git, 2, TRUE, 1.00);

    -- Machine Learning Research Intern: Python (weight 1.5, prof 4), Machine Learning (weight 2.0, prof 4)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp5, sk_python, 4, TRUE, 1.50),
        (opp5, sk_ml, 4, TRUE, 2.00);

    -- Frontend React Developer: React (weight 2.0, prof 3), JavaScript (weight 1.0, prof 3)
    INSERT INTO opportunity_skills (opportunity_id, skill_id, required_proficiency, is_mandatory, skill_weight) VALUES
        (opp6, sk_react, 3, TRUE, 2.00),
        (opp6, sk_js, 3, TRUE, 1.00);

    -- 11. Seed Applications & History
    -- Rahul applies to Backend Developer Intern (Shortlisted)
    INSERT INTO applications (opportunity_id, student_id, match_score, status, cover_letter)
    VALUES (opp1, sp1, 95.00, 'SHORTLISTED', 'Experienced with Python backend microservices and relational modeling with PostgreSQL.')
    RETURNING id INTO app1;

    INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks) VALUES
        (app1, NULL, 'APPLIED', u_s1, 'Application submitted with 95% skill fit.'),
        (app1, 'APPLIED', 'UNDER_REVIEW', u_c1, 'Recruiter reviewing academic credentials.'),
        (app1, 'UNDER_REVIEW', 'SHORTLISTED', u_c1, 'Candidate shortlisted for technical round.');

    -- Rahul applies to Data Engineering Intern (Applied)
    INSERT INTO applications (opportunity_id, student_id, match_score, status, cover_letter)
    VALUES (opp3, sp1, 80.00, 'APPLIED', 'Interested in data pipelines and database scaling.')
    RETURNING id INTO app2;

    INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks) VALUES
        (app2, NULL, 'APPLIED', u_s1, 'Application submitted.');

    -- Priya applies to Machine Learning Research Intern (Interview Scheduled)
    INSERT INTO applications (opportunity_id, student_id, match_score, status, cover_letter)
    VALUES (opp5, sp2, 98.00, 'INTERVIEW_SCHEDULED', 'Authored research paper on neural architectures; verified Python & ML proficiencies.')
    RETURNING id INTO app3;

    INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks) VALUES
        (app3, NULL, 'APPLIED', u_s2, 'Submitted with 98% skill match.'),
        (app3, 'APPLIED', 'SHORTLISTED', u_c3, 'Top tier candidate from IIT Bombay.'),
        (app3, 'SHORTLISTED', 'INTERVIEW_SCHEDULED', u_c3, 'Technical interview scheduled.');

    -- Amit applies to Full Stack Web Intern
    INSERT INTO applications (opportunity_id, student_id, match_score, status, cover_letter)
    VALUES (opp2, sp3, 75.00, 'APPLIED', 'Built 3 React projects during coursework.');

    -- Sneha applies to Backend Developer Intern
    INSERT INTO applications (opportunity_id, student_id, match_score, status, cover_letter)
    VALUES (opp1, sp4, 65.00, 'APPLIED', 'Strong Java and PostgreSQL background.');

    RAISE NOTICE 'SUCCESS: Phase 3 Seed Data successfully inserted!';
END $$;
