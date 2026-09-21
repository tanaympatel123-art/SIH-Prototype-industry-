-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 1: Realistic Demonstration Seed Data
-- File: phase1_seed.sql
-- Target Environment: MySQL 8.x / MariaDB (XAMPP / phpMyAdmin / MySQL CLI)
-- 
-- Seed Persona Matrix:
--   Roles: 4 System Roles (student, company, teacher, admin)
--   Users: 8 Accounts (3 Students, 2 Companies, 2 Teachers, 1 Admin)
--   Profiles: 3 Student Profiles, 2 Company Profiles, 2 Teacher Profiles
--   Master Skills: 14 Categorized & Hierarchically Linked Skills
--   Student Skills: 13 Student Skill Inventory Entries (various sources & verifications)
--   Skill Verifications: 5 Verification Audit Records (approved, pending, rejected)
--   Opportunities: 3 Industry Postings (Python Developer, Web Developer, Data Analyst)
--   Opportunity Skills: 11 Skill Requirements with Mandatory Flags
--   Applications: 5 Recruitment Pipeline Applications across various statuses
-- ==============================================================================

USE sih26044_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------------------------
-- 1. SEED ROLES
-- ------------------------------------------------------------------------------
INSERT INTO roles (id, name, description) VALUES
    (1, 'student', 'Enrolled student seeking internships, skill benchmarking, and verification'),
    (2, 'company', 'Corporate partner posting opportunities, reviewing candidates, and hiring talent'),
    (3, 'teacher', 'Academic faculty responsible for reviewing and verifying student skills'),
    (4, 'admin', 'Platform administrator managing system governance, security, and integrity')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

-- ------------------------------------------------------------------------------
-- 2. SEED USERS
-- Default Password for all seed users: "password123"
-- Bcrypt Hash: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- ------------------------------------------------------------------------------
INSERT INTO users (id, role_id, email, password_hash, phone, is_active) VALUES
    -- Students (IDs 1-3)
    (1, 1, 'aarav.sharma@dtu.ac.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-9811001122', TRUE),
    (2, 1, 'priya.patel@dtu.ac.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-9822002233', TRUE),
    (3, 1, 'rohan.mehta@iitb.ac.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-9833003344', TRUE),
    
    -- Companies (IDs 4-5)
    (4, 2, 'recruitment@techcorp.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-8022114455', TRUE),
    (5, 2, 'talent@innovateai.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-1244556677', TRUE),
    
    -- Teachers (IDs 6-7)
    (6, 3, 'dr.verma@dtu.ac.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-9811998877', TRUE),
    (7, 3, 'ananya.roy@iitb.ac.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-9822887766', TRUE),
    
    -- Admin (ID 8)
    (8, 4, 'admin@sih26044.gov.in', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+91-1123456789', TRUE)
ON DUPLICATE KEY UPDATE email = VALUES(email), password_hash = VALUES(password_hash);

-- ------------------------------------------------------------------------------
-- 3. SEED STAKEHOLDER PROFILES
-- ------------------------------------------------------------------------------

-- Student Profiles
INSERT INTO student_profiles (
    id, user_id, student_identifier, first_name, last_name,
    institution, department, course_program, current_semester,
    graduation_year, cgpa, bio, location
) VALUES
    (1, 1, 'DTU2023CS0101', 'Aarav', 'Sharma',
     'Delhi Technological University', 'Computer Science and Engineering', 'B.Tech CSE', 6,
     2025, 8.85, 'Pre-final year CSE student passionate about backend systems, Python, and scalable databases.', 'New Delhi, Delhi'),
    
    (2, 2, 'DTU2023IT0204', 'Priya', 'Patel',
     'Delhi Technological University', 'Information Technology', 'B.Tech IT', 6,
     2025, 9.12, 'Full-stack web developer with deep interest in modern JavaScript, React, and UX performance.', 'New Delhi, Delhi'),
    
    (3, 3, 'IITB2023CS0042', 'Rohan', 'Mehta',
     'Indian Institute of Technology Bombay', 'Computer Science and Engineering', 'B.Tech CSE', 6,
     2025, 9.45, 'Algorithms enthusiast specializing in machine learning pipelines, Python, and relational database systems.', 'Mumbai, Maharashtra')
ON DUPLICATE KEY UPDATE student_identifier = VALUES(student_identifier), cgpa = VALUES(cgpa);

-- Company Profiles
INSERT INTO company_profiles (
    id, user_id, company_name, industry, company_description,
    website, location, company_size
) VALUES
    (1, 4, 'TechCorp India Technologies Pvt Ltd', 'Information Technology & Software Services',
     'Leading enterprise software solutions provider specializing in cloud migration, data platforms, and product engineering.',
     'https://www.techcorp.in', 'Bengaluru, Karnataka', '501-1000'),
    
    (2, 5, 'Innovate AI Systems', 'Artificial Intelligence & Machine Learning',
     'Cutting-edge startup developing predictive analytics, computer vision, and cognitive NLP solutions for global clients.',
     'https://www.innovateai.com', 'Gurugram, Haryana', '51-200')
ON DUPLICATE KEY UPDATE company_name = VALUES(company_name), website = VALUES(website);

-- Teacher Profiles
INSERT INTO teacher_profiles (
    id, user_id, employee_identifier, first_name, last_name,
    institution, department, designation, specialization, bio
) VALUES
    (1, 6, 'FAC-DTU-CS-014', 'Dr. Rajesh', 'Verma',
     'Delhi Technological University', 'Computer Science and Engineering', 'Associate Professor',
     'Data Systems, Cloud Computing & Distributed Architectures',
     'Over 15 years of academic and research experience. Active mentor for industry-sponsored capstone projects.'),
    
    (2, 7, 'FAC-IITB-AI-008', 'Prof. Ananya', 'Roy',
     'Indian Institute of Technology Bombay', 'Computer Science and Engineering', 'Professor',
     'Artificial Intelligence, Machine Learning & Natural Language Processing',
     'Senior researcher and IEEE fellow focusing on applied machine learning and ethical AI models.')
ON DUPLICATE KEY UPDATE employee_identifier = VALUES(employee_identifier), designation = VALUES(designation);

-- ------------------------------------------------------------------------------
-- 4. SEED MASTER SKILLS TAXONOMY
-- ------------------------------------------------------------------------------
INSERT INTO skills (id, skill_name, category, description, parent_skill_id) VALUES
    -- Base Skills
    (1, 'Python', 'Programming Languages', 'High-level interpreted programming language renowned for clean syntax and rich ecosystem', NULL),
    (2, 'Java', 'Programming Languages', 'Class-based, object-oriented language engineered for cross-platform portability', NULL),
    (3, 'C++', 'Programming Languages', 'High-performance compiled systems programming language with low-level memory control', NULL),
    (4, 'SQL', 'Databases', 'Declarative standard domain-specific language for managing structured relational data', NULL),
    (5, 'HTML', 'Web Development', 'Foundational markup language for authoring documents structured for web browsers', NULL),
    (6, 'CSS', 'Web Development', 'Style sheet language for styling, responsive layout, and presentation of web pages', NULL),
    (7, 'JavaScript', 'Web Development', 'Lightweight interpreted language with first-class functions for web applications', NULL),
    (8, 'Machine Learning', 'Artificial Intelligence', 'Computational study and construction of algorithms that learn from empirical data', NULL),
    (9, 'Data Structures', 'Computer Science Fundamentals', 'Techniques for organizing, accessing, and manipulating structured in-memory data', NULL),
    
    -- Hierarchical Child Skills
    (10, 'MySQL', 'Databases', 'Widely adopted open-source relational database management system using SQL', 4),
    (11, 'React', 'Web Development', 'Component-based JavaScript library for building high-speed single-page user interfaces', 7),
    (12, 'Angular', 'Web Development', 'TypeScript-based open-source framework for scalable client-side web applications', 7),
    (13, 'Deep Learning', 'Artificial Intelligence', 'Subfield of machine learning based on multi-layer artificial neural networks', 8),
    (14, 'Git & Version Control', 'DevOps & Tools', 'Distributed version control system for tracking software code iterations', NULL)
ON DUPLICATE KEY UPDATE skill_name = VALUES(skill_name), parent_skill_id = VALUES(parent_skill_id);

-- ------------------------------------------------------------------------------
-- 5. SEED STUDENT SKILLS (Junction)
-- Preserves distinction between self_declared, ai_extracted, and teacher_verified
-- ------------------------------------------------------------------------------
INSERT INTO student_skills (
    id, student_id, skill_id, proficiency_level, proficiency_score, source, is_verified
) VALUES
    -- Aarav Sharma (student_id = 1)
    (1, 1, 1, 'advanced', 88.50, 'teacher_verified', TRUE),
    (2, 1, 10, 'intermediate', 76.00, 'project', FALSE),
    (3, 1, 8, 'intermediate', 72.00, 'ai_extracted', FALSE), -- Extracted by AI from resume; awaiting teacher verification
    (4, 1, 14, 'advanced', 85.00, 'certificate', TRUE),
    
    -- Priya Patel (student_id = 2)
    (5, 2, 7, 'advanced', 91.00, 'project', TRUE),
    (6, 2, 11, 'advanced', 89.50, 'teacher_verified', TRUE),
    (7, 2, 5, 'expert', 95.00, 'certificate', TRUE),
    (8, 2, 6, 'advanced', 88.00, 'self_declared', FALSE),
    
    -- Rohan Mehta (student_id = 3)
    (9, 3, 1, 'expert', 96.00, 'teacher_verified', TRUE),
    (10, 3, 4, 'advanced', 90.00, 'project', TRUE),
    (11, 3, 8, 'advanced', 92.50, 'teacher_verified', TRUE),
    (12, 3, 9, 'expert', 97.00, 'quiz', TRUE),
    (13, 3, 13, 'intermediate', 78.00, 'ai_extracted', FALSE) -- AI extracted deep learning claim
ON DUPLICATE KEY UPDATE proficiency_level = VALUES(proficiency_level), is_verified = VALUES(is_verified);

-- ------------------------------------------------------------------------------
-- 6. SEED SKILL VERIFICATIONS (Audit Trail)
-- Demonstrates Approved, Pending, and Rejected states by Faculty
-- ------------------------------------------------------------------------------
INSERT INTO skill_verifications (
    id, student_skill_id, verifier_teacher_id, verification_status,
    evidence_type, evidence_reference, confidence_score, remarks, verified_at
) VALUES
    -- Dr. Verma approved Aarav's Python (student_skill_id = 1)
    (1, 1, 1, 'approved', 'project',
     'https://github.com/aaravsharma/fastapi-distributed-cache', 92.00,
     'Evaluated repository architecture, unit test coverage, and documentation. Student demonstrates strong idiomatic Python proficiency.',
     '2026-08-15 11:30:00'),
    
    -- Dr. Verma reviewing Aarav's AI-extracted ML skill (student_skill_id = 3, pending)
    (2, 3, 1, 'pending', 'certificate',
     'https://coursera.org/verify/ML-SPECIALIZATION-8832', 78.00,
     'Uploaded certificate verified on public ledger. Scheduled for practical coding evaluation in lab next week.',
     NULL),
    
    -- Dr. Verma approved Priya's React skill (student_skill_id = 6)
    (3, 6, 1, 'approved', 'project',
     'https://github.com/priyapatel/react-campus-marketplace', 94.00,
     'Live demonstration conducted. Excellent usage of modern hooks, memoization, and modular state management.',
     '2026-08-20 14:15:00'),
    
    -- Dr. Verma rejected Priya's self-declared CSS (student_skill_id = 8)
    (4, 8, 1, 'rejected', 'other',
     'https://priyapatel.dev/demo-portfolio', 45.00,
     'Portfolio layout broke on mobile viewpoints during responsiveness inspection. Advised to review CSS Grid and Flexbox standards.',
     '2026-08-22 16:45:00'),
    
    -- Prof. Roy approved Rohan's Machine Learning skill (student_skill_id = 11)
    (5, 11, 2, 'approved', 'coursework',
     'IITB Coursework Portal CS725 Grade Transcript', 98.00,
     'Achieved highest honors in advanced machine learning coursework and co-authored workshop paper on optimization.',
     '2026-08-10 10:00:00')
ON DUPLICATE KEY UPDATE verification_status = VALUES(verification_status), remarks = VALUES(remarks);

-- ------------------------------------------------------------------------------
-- 7. SEED OPPORTUNITIES
-- 3 Core Postings: Python Developer Intern, Web Developer Intern, Data Analyst Intern
-- ------------------------------------------------------------------------------
INSERT INTO opportunities (
    id, company_id, title, description, opportunity_type, location,
    work_mode, stipend_salary, openings, application_deadline, status
) VALUES
    (1, 1, 'Python Developer Intern',
     'TechCorp is hiring a Python Developer Intern to work on cloud microservices, REST APIs, and background job processing pipelines. Opportunity to transition to a full-time SDE role upon graduation.',
     'internship', 'Bengaluru, Karnataka', 'remote', '₹25,000 / month', 3,
     '2026-10-15', 'published'),
    
    (2, 1, 'Web Developer Intern',
     'Join our enterprise product UI team building responsive, highly performant web applications using React, modern JavaScript, and Tailwind CSS.',
     'internship', 'Bengaluru, Karnataka', 'hybrid', '₹22,000 / month', 2,
     '2026-10-25', 'published'),
    
    (3, 2, 'Data Analyst Intern',
     'Innovate AI Systems seeks a Data Analyst Intern to extract insights from multi-source datasets, build automated SQL pipelines, and develop predictive dashboards using Python and Machine Learning.',
     'internship', 'Gurugram, Haryana', 'onsite', '₹30,000 / month', 2,
     '2026-11-05', 'published')
ON DUPLICATE KEY UPDATE title = VALUES(title), stipend_salary = VALUES(stipend_salary);

-- ------------------------------------------------------------------------------
-- 8. SEED OPPORTUNITY SKILLS (Required Skill Mappings)
-- ------------------------------------------------------------------------------
INSERT INTO opportunity_skills (
    id, opportunity_id, skill_id, required_proficiency_level, is_mandatory
) VALUES
    -- Opportunity 1: Python Developer Intern (opp_id = 1)
    (1, 1, 1, 'advanced', TRUE),        -- Python (Mandatory)
    (2, 1, 4, 'intermediate', TRUE),    -- SQL (Mandatory)
    (3, 1, 14, 'intermediate', FALSE),  -- Git (Optional)
    
    -- Opportunity 2: Web Developer Intern (opp_id = 2)
    (4, 2, 7, 'advanced', TRUE),        -- JavaScript (Mandatory)
    (5, 2, 11, 'intermediate', TRUE),   -- React (Mandatory)
    (6, 2, 5, 'intermediate', FALSE),   -- HTML (Optional)
    (7, 2, 6, 'intermediate', FALSE),   -- CSS (Optional)
    
    -- Opportunity 3: Data Analyst Intern (opp_id = 3)
    (8, 3, 1, 'intermediate', TRUE),    -- Python (Mandatory)
    (9, 3, 4, 'advanced', TRUE),        -- SQL (Mandatory)
    (10, 3, 8, 'intermediate', TRUE),   -- Machine Learning (Mandatory)
    (11, 3, 10, 'intermediate', FALSE)  -- MySQL (Optional)
ON DUPLICATE KEY UPDATE required_proficiency_level = VALUES(required_proficiency_level);

-- ------------------------------------------------------------------------------
-- 9. SEED APPLICATIONS
-- Applications across pipeline stages: applied, shortlisted, interview, selected
-- ------------------------------------------------------------------------------
INSERT INTO applications (
    id, opportunity_id, student_id, application_status, applied_at,
    resume_reference, cover_note, company_notes
) VALUES
    -- Aarav applied for Python Developer Intern
    (1, 1, 1, 'shortlisted', '2026-08-25 09:30:00',
     'https://sih-storage.portal.gov.in/resumes/aarav_sharma_cv.pdf',
     'I have built production-ready Python web services and actively contribute to open-source.',
     'Strong GitHub portfolio and teacher verified Python credential. Move to coding round.'),
    
    -- Aarav applied for Data Analyst Intern
    (2, 3, 1, 'applied', '2026-08-26 14:10:00',
     'https://sih-storage.portal.gov.in/resumes/aarav_sharma_cv.pdf',
     'Eager to apply my Python and SQL abilities to real-world predictive data sets.',
     'Resume queued for initial recruiter screening.'),
    
    -- Priya applied for Web Developer Intern
    (3, 2, 2, 'interview', '2026-08-27 16:45:00',
     'https://sih-storage.portal.gov.in/resumes/priya_patel_cv.pdf',
     'Passionate React frontend developer with verified UI components and top academic standing.',
     'Excellent React portfolio project. Technical panel interview scheduled for tomorrow.'),
    
    -- Rohan applied for Python Developer Intern
    (4, 1, 3, 'selected', '2026-08-24 10:00:00',
     'https://sih-storage.portal.gov.in/resumes/rohan_mehta_cv.pdf',
     'Experienced in algorithmic problem solving and high-throughput Python systems.',
     'Exceptional interview performance and perfect problem-solving assessment score. Offer rolled out.'),
    
    -- Rohan applied for Data Analyst Intern
    (5, 3, 3, 'shortlisted', '2026-08-28 11:20:00',
     'https://sih-storage.portal.gov.in/resumes/rohan_mehta_cv.pdf',
     'Research background in machine learning and data engineering at IIT Bombay.',
     'Candidate has advanced ML coursework verified by Prof. Roy. Priority shortlist.')
ON DUPLICATE KEY UPDATE application_status = VALUES(application_status), company_notes = VALUES(company_notes);

SET FOREIGN_KEY_CHECKS = 1;
