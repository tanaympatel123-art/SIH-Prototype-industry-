-- ==============================================================================
-- SIH26044: Academia-Industry Collaboration Portal
-- Phase 2: Expanded Demo Seed Dataset
-- File: phase2_expanded_seed.sql
-- Target: MySQL 8.x — run AFTER phase1_seed.sql
-- Branch: database/phase-2-optimization
-- ==============================================================================
-- COUNTS (this file):
--   Students   : 30 new (IDs 4–33 for student_profiles; user IDs 9–38)
--   Companies  : 5  new (IDs 3–7 for company_profiles;  user IDs 39–43)
--   Teachers   : 3  new (IDs 3–5 for teacher_profiles;  user IDs 44–46)
--   Opportunities: 15 new (IDs 3–17)
--   Skills     : 15 new (IDs 16–30)
--   Applications: 45 new
--   student_skills: 90 new
-- ==============================================================================

USE sih26044_db;
SET FOREIGN_KEY_CHECKS = 0;

-- ==============================================================================
-- SECTION 1: ADDITIONAL USERS (IDs 9–46)
-- Password hash: bcrypt('password123') = $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- ==============================================================================

INSERT IGNORE INTO users (id, role_id, email, password_hash, is_active) VALUES
-- 30 students (role_id=1 = student, based on phase1_seed roles)
( 9,  1, 'student004@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(10,  1, 'student005@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(11,  1, 'student006@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(12,  1, 'student007@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(13,  1, 'student008@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(14,  1, 'student009@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(15,  1, 'student010@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(16,  1, 'student011@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(17,  1, 'student012@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(18,  1, 'student013@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(19,  1, 'student014@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(20,  1, 'student015@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(21,  1, 'student016@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(22,  1, 'student017@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(23,  1, 'student018@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(24,  1, 'student019@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(25,  1, 'student020@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(26,  1, 'student021@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(27,  1, 'student022@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(28,  1, 'student023@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(29,  1, 'student024@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(30,  1, 'student025@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(31,  1, 'student026@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(32,  1, 'student027@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(33,  1, 'student028@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(34,  1, 'student029@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(35,  1, 'student030@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(36,  1, 'student031@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(37,  1, 'student032@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(38,  1, 'student033@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
-- 5 companies (role_id=2)
(39,  2, 'company003@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(40,  2, 'company004@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(41,  2, 'company005@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(42,  2, 'company006@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(43,  2, 'company007@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
-- 3 teachers (role_id=3)
(44,  3, 'teacher003@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(45,  3, 'teacher004@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(46,  3, 'teacher005@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);

-- ==============================================================================
-- SECTION 2: 30 STUDENT PROFILES (IDs 4–33)
-- Institution spread: DTU, IIT Bombay, NIT Trichy, VIT Vellore, BITS Pilani, IIIT Hyd
-- ==============================================================================

INSERT IGNORE INTO student_profiles
    (id, user_id, student_identifier, first_name, last_name, institution, department,
     course_program, current_semester, graduation_year, cgpa, location, profile_completion_pct)
VALUES
( 4,  9,  'DTU2024004',  'Arjun',     'Kapoor',   'Delhi Technological University', 'Computer Science',    'B.Tech CSE',         7, 2026, 8.20, 'Delhi',      40.00),
( 5, 10,  'DTU2024005',  'Sneha',     'Gupta',    'Delhi Technological University', 'Electronics',         'B.Tech ECE',         6, 2026, 7.85, 'Delhi',      30.00),
( 6, 11,  'IITB2024006', 'Vikram',    'Singh',    'IIT Bombay',                    'Computer Science',    'B.Tech CSE',         8, 2025, 9.10, 'Mumbai',     50.00),
( 7, 12,  'IITB2024007', 'Kavya',     'Nair',     'IIT Bombay',                    'Data Science',        'M.Tech DS',          3, 2025, 8.75, 'Mumbai',     45.00),
( 8, 13,  'NITR2024008', 'Rahul',     'Das',      'NIT Trichy',                    'Information Tech',    'B.Tech IT',          7, 2026, 8.00, 'Tiruchirappalli', 35.00),
( 9, 14,  'NITR2024009', 'Pooja',     'Krishnan', 'NIT Trichy',                    'Computer Science',    'B.Tech CSE',         6, 2026, 8.55, 'Tiruchirappalli', 30.00),
(10, 15,  'VIT2024010',  'Amit',      'Joshi',    'VIT Vellore',                   'Software Engineering','B.Tech SE',          5, 2027, 7.60, 'Vellore',    30.00),
(11, 16,  'VIT2024011',  'Divya',     'Iyer',     'VIT Vellore',                   'Computer Science',    'B.Tech CSE',         7, 2026, 8.90, 'Vellore',    40.00),
(12, 17,  'BITS2024012', 'Karan',     'Malhotra', 'BITS Pilani',                   'Computer Science',    'B.E. CSE',           7, 2025, 9.30, 'Pilani',     55.00),
(13, 18,  'BITS2024013', 'Ananya',    'Sharma',   'BITS Pilani',                   'Mathematics & CS',    'B.E. MSC',           6, 2026, 8.65, 'Pilani',     40.00),
(14, 19,  'IIITH2024014','Siddharth', 'Rao',      'IIIT Hyderabad',                'CSE',                 'B.Tech CSE',         7, 2025, 9.20, 'Hyderabad',  50.00),
(15, 20,  'IIITH2024015','Preethi',   'Reddy',    'IIIT Hyderabad',                'Data Science',        'M.Tech CDS',         2, 2026, 8.80, 'Hyderabad',  45.00),
(16, 21,  'DTU2024016',  'Nikhil',    'Bajaj',    'Delhi Technological University', 'Mechanical',          'B.Tech ME',          5, 2027, 7.20, 'Delhi',      25.00),
(17, 22,  'DTU2024017',  'Richa',     'Sood',     'Delhi Technological University', 'Computer Science',    'B.Tech CSE',         8, 2025, 8.40, 'Delhi',      40.00),
(18, 23,  'IITB2024018', 'Gaurav',    'Tiwari',   'IIT Bombay',                    'AI & ML',             'M.Tech AI',          2, 2026, 9.05, 'Mumbai',     50.00),
(19, 24,  'NITR2024019', 'Swati',     'Mishra',   'NIT Trichy',                    'Information Tech',    'B.Tech IT',          7, 2026, 7.90, 'Tiruchirappalli', 30.00),
(20, 25,  'VIT2024020',  'Tejas',     'Patil',    'VIT Vellore',                   'Computer Science',    'B.Tech CSE',         6, 2027, 8.30, 'Vellore',    30.00),
(21, 26,  'BITS2024021', 'Neha',      'Choudhary','BITS Pilani',                   'Physics',             'B.E. PHY',           7, 2025, 7.80, 'Pilani',     25.00),
(22, 27,  'IIITH2024022','Ravi',      'Kumar',    'IIIT Hyderabad',                'CSE',                 'B.Tech CSE',         8, 2025, 9.40, 'Hyderabad',  55.00),
(23, 28,  'DTU2024023',  'Ishaan',    'Chandra',  'Delhi Technological University', 'Data Engineering',    'B.Tech DS',          6, 2026, 8.10, 'Delhi',      30.00),
(24, 29,  'IITB2024024', 'Tanvi',     'Shah',     'IIT Bombay',                    'Computer Science',    'B.Tech CSE',         7, 2025, 8.95, 'Mumbai',     45.00),
(25, 30,  'NITR2024025', 'Aditya',    'Pandey',   'NIT Trichy',                    'Information Tech',    'B.Tech IT',          5, 2027, 7.50, 'Tiruchirappalli', 25.00),
(26, 31,  'VIT2024026',  'Shruti',    'Verma',    'VIT Vellore',                   'Computer Science',    'B.Tech CSE',         7, 2026, 8.70, 'Vellore',    40.00),
(27, 32,  'BITS2024027', 'Manish',    'Agarwal',  'BITS Pilani',                   'CSE',                 'B.E. CSE',           8, 2025, 9.15, 'Pilani',     50.00),
(28, 33,  'IIITH2024028','Lavanya',   'Bhat',     'IIIT Hyderabad',                'Data Science',        'M.Tech DS',          3, 2026, 8.50, 'Hyderabad',  40.00),
(29, 34,  'DTU2024029',  'Parth',     'Mehta',    'Delhi Technological University', 'Computer Science',    'B.Tech CSE',         6, 2026, 8.00, 'Delhi',      30.00),
(30, 35,  'IITB2024030', 'Kritika',   'Jain',     'IIT Bombay',                    'Mathematics',         'B.S. Math',          7, 2025, 8.60, 'Mumbai',     35.00),
(31, 36,  'NITR2024031', 'Yash',      'Dubey',    'NIT Trichy',                    'Computer Science',    'B.Tech CSE',         5, 2027, 7.40, 'Tiruchirappalli', 25.00),
(32, 37,  'VIT2024032',  'Pallavi',   'Desai',    'VIT Vellore',                   'Information Tech',    'B.Tech IT',          8, 2025, 8.85, 'Vellore',    45.00),
(33, 38,  'BITS2024033', 'Akash',     'Saxena',   'BITS Pilani',                   'CSE',                 'B.E. CSE',           6, 2026, 9.00, 'Pilani',     50.00);

-- ==============================================================================
-- SECTION 3: 5 COMPANY PROFILES (IDs 3–7)
-- ==============================================================================

INSERT IGNORE INTO company_profiles
    (id, user_id, company_name, industry, company_description, website, location, company_size)
VALUES
(3, 39, 'Zomato Technology',    'Food Technology & Delivery',  'India\'s leading food delivery and restaurant discovery platform.',             'https://www.zomato.com',      'Gurugram, Haryana', '5001-10000'),
(4, 40, 'BYJU\'S EdTech',       'Education Technology',        'World\'s largest ed-tech company providing personalized learning at scale.',    'https://byjus.com',           'Bengaluru, Karnataka', '10001+'),
(5, 41, 'Razorpay Payments',    'Fintech & Payments',          'India\'s leading full-stack financial solutions company for businesses.',        'https://razorpay.com',        'Bengaluru, Karnataka', '1001-5000'),
(6, 42, 'Ola Electric',         'Electric Vehicles & Mobility','EV startup disrupting the automotive industry with Made-in-India scooters.',   'https://olaelectric.com',     'Bengaluru, Karnataka', '1001-5000'),
(7, 43, 'PhonePe Digital',      'Fintech & Digital Payments',  'India\'s leading UPI-based payments platform serving 500M+ users.',             'https://phonepe.com',         'Bengaluru, Karnataka', '1001-5000');

-- ==============================================================================
-- SECTION 4: 3 ADDITIONAL TEACHER PROFILES (IDs 3–5)
-- ==============================================================================

INSERT IGNORE INTO teacher_profiles
    (id, user_id, employee_identifier, first_name, last_name, institution, department, designation, specialization)
VALUES
(3, 44, 'IITB-PROF-003', 'Dr. Priya',    'Natarajan', 'IIT Bombay',        'Data Science',   'Associate Professor',  'Machine Learning, Deep Learning'),
(4, 45, 'NITR-PROF-004', 'Prof. Suresh', 'Menon',     'NIT Trichy',        'Computer Science','Professor',            'Database Systems, Cloud Computing'),
(5, 46, 'VIT-PROF-005',  'Dr. Meera',    'Pillai',    'VIT Vellore',       'Software Eng.',  'Assistant Professor',   'Web Technologies, Microservices');

-- ==============================================================================
-- SECTION 5: 15 NEW SKILLS (IDs 16–30)
-- ==============================================================================

INSERT IGNORE INTO skills (id, skill_name, category, description, parent_skill_id) VALUES
(16, 'React.js',          'Frontend Development', 'Component-based UI library by Meta',          11),  -- parent: React (id 11)
(17, 'Node.js',           'Backend Development',  'Server-side JavaScript runtime',              7),   -- parent: JavaScript (id 7)
(18, 'PostgreSQL',        'Databases',            'Advanced open-source relational database',    4),   -- parent: SQL (id 4) - Note: MySQL is already skill #10
(19, 'MongoDB',           'Databases',            'Document-oriented NoSQL database',            NULL),
(20, 'TensorFlow',        'AI & Machine Learning','Open-source ML framework by Google',          8),   -- parent: Machine Learning (id 8)
(21, 'PyTorch',           'AI & Machine Learning','ML framework by Meta',                        8),   -- parent: Machine Learning (id 8)
(22, 'Data Visualization','Data Science',         'Charts, dashboards, BI tools',                NULL),
(23, 'AWS',               'Cloud Computing',      'Amazon Web Services cloud platform',          NULL),
(24, 'Docker',            'DevOps',               'Containerization platform',                   NULL),
(25, 'Kubernetes',        'DevOps',               'Container orchestration system',              24),  -- parent: Docker
(26, 'REST API Design',   'Backend Development',  'Design and development of RESTful APIs',      NULL),
(27, 'Git & GitHub',      'Version Control',      'Distributed version control system',          14),  -- parent: Git (id 14)
(28, 'System Design',     'Software Engineering', 'High-level architecture & design patterns',   NULL),
(29, 'Flutter',           'Mobile Development',   'Cross-platform mobile framework by Google',   NULL),
(30, 'Cybersecurity',     'Security',             'Application and network security fundamentals',NULL);

-- ==============================================================================
-- SECTION 6: 15 NEW OPPORTUNITIES (IDs 3–17)
-- ==============================================================================

INSERT IGNORE INTO opportunities
    (id, company_id, title, description, opportunity_type, location, work_mode,
     stipend_salary, openings, application_deadline, status)
VALUES
-- Zomato (company_id=3)
( 3, 3, 'Backend Engineer Intern',        'Build scalable microservices for food ordering pipeline',     'internship', 'Gurugram', 'hybrid', '₹35,000/month', 3, '2025-08-15', 'published'),
( 4, 3, 'Data Analyst – Growth',          'Analyze user behaviour funnels and growth metrics',           'internship', 'Gurugram', 'onsite', '₹30,000/month', 2, '2025-08-20', 'published'),
( 5, 3, 'ML Engineer (Full-Time)',         'Deploy recommendation models in production Spark pipelines',  'full_time',  'Gurugram', 'hybrid', '₹18-22 LPA',   4, '2025-09-30', 'published'),
-- BYJU'S (company_id=4)
( 6, 4, 'Full-Stack Developer Intern',    'Build interactive learning modules with React & Node.js',     'internship', 'Bengaluru', 'remote', '₹25,000/month', 5, '2025-07-31', 'published'),
( 7, 4, 'AI Content Personalization',     'Implement NLP pipelines for adaptive content recommendations', 'internship', 'Bengaluru', 'hybrid', '₹32,000/month', 2, '2025-08-10', 'published'),
-- Razorpay (company_id=5)
( 8, 5, 'Backend Platform Engineer',      'Design payment processing APIs using Java/Node.js',           'full_time',  'Bengaluru', 'hybrid', '₹20-28 LPA',   3, '2025-09-15', 'published'),
( 9, 5, 'Security Engineer Intern',       'Penetration testing, threat modelling for payment flows',     'internship', 'Bengaluru', 'onsite', '₹40,000/month', 2, '2025-08-05', 'published'),
(10, 5, 'DevOps Engineer Intern',         'Containerize microservices using Docker & Kubernetes on AWS',  'internship', 'Bengaluru', 'hybrid', '₹35,000/month', 2, '2025-08-25', 'published'),
-- Ola Electric (company_id=6)
(11, 6, 'Embedded Systems Intern',        'Firmware development for EV battery management systems',      'internship', 'Bengaluru', 'onsite', '₹28,000/month', 4, '2025-09-01', 'published'),
(12, 6, 'Data Engineer Intern',           'Build real-time telemetry data pipelines for EV fleet',       'internship', 'Bengaluru', 'hybrid', '₹30,000/month', 3, '2025-08-30', 'published'),
(13, 6, 'Mobile App Developer (Flutter)', 'Develop customer-facing Ola Electric app in Flutter',         'full_time',  'Bengaluru', 'hybrid', '₹15-20 LPA',   2, '2025-10-15', 'published'),
-- PhonePe (company_id=7)
(14, 7, 'SDE-I (Full-Time)',              'Design scalable UPI transaction processing systems',           'full_time',  'Bengaluru', 'onsite', '₹22-30 LPA',   5, '2025-09-20', 'published'),
(15, 7, 'Data Science Intern',            'Build fraud detection models on real-time transaction data',   'internship', 'Bengaluru', 'hybrid', '₹38,000/month', 3, '2025-08-12', 'published'),
(16, 7, 'Cloud Infrastructure Intern',    'Manage AWS infrastructure supporting 500M+ active users',      'internship', 'Bengaluru', 'onsite', '₹42,000/month', 2, '2025-08-18', 'published'),
(17, 7, 'Backend Engineer (Part-Time)',   'Build REST APIs for PhonePe merchant analytics dashboard',     'part_time',  'Bengaluru', 'remote', '₹20,000/month', 3, '2025-08-28', 'published');

-- ==============================================================================
-- SECTION 7: OPPORTUNITY SKILLS MAPPINGS
-- ==============================================================================

INSERT IGNORE INTO opportunity_skills (opportunity_id, skill_id, required_proficiency_level, is_mandatory) VALUES
-- Opportunity 3: Backend Engineer Intern (Zomato)
(3, 17, 'intermediate', TRUE),   -- Node.js
(3, 26, 'intermediate', TRUE),   -- REST API Design
(3, 18, 'beginner',     FALSE),  -- PostgreSQL
(3, 24, 'beginner',     FALSE),  -- Docker
-- Opportunity 4: Data Analyst – Growth (Zomato)
(4,  6, 'intermediate', TRUE),   -- Data Analysis
(4, 22, 'intermediate', TRUE),   -- Data Visualization
(4, 18, 'beginner',     FALSE),  -- PostgreSQL
-- Opportunity 5: ML Engineer Full-Time (Zomato)
(5,  8, 'advanced',     TRUE),   -- Machine Learning (id 8)
(5, 20, 'intermediate', TRUE),   -- TensorFlow
(5,  1, 'advanced',     FALSE),  -- Python (id 1)
-- Opportunity 6: Full-Stack Developer Intern (BYJU'S)
(6, 16, 'intermediate', TRUE),   -- React.js
(6, 17, 'intermediate', TRUE),   -- Node.js
(6,  1, 'beginner',     FALSE),  -- Python (id 1)
-- Opportunity 7: AI Content Personalization (BYJU'S)
(7,  8, 'intermediate', TRUE),   -- Machine Learning (id 8)
(7, 21, 'beginner',     TRUE),   -- PyTorch
(7,  1, 'intermediate', FALSE),  -- Python (id 1)
-- Opportunity 8: Backend Platform Engineer (Razorpay)
(8, 26, 'advanced',     TRUE),   -- REST API Design
(8, 28, 'intermediate', TRUE),   -- System Design
(8, 18, 'intermediate', FALSE),  -- PostgreSQL
-- Opportunity 9: Security Engineer Intern (Razorpay)
(9, 30, 'intermediate', TRUE),   -- Cybersecurity
(9, 26, 'beginner',     FALSE),  -- REST API Design
-- Opportunity 10: DevOps Engineer Intern (Razorpay)
(10, 24, 'intermediate', TRUE),  -- Docker
(10, 25, 'beginner',     TRUE),  -- Kubernetes
(10, 23, 'beginner',     FALSE), -- AWS
-- Opportunity 11: Embedded Systems Intern (Ola)
(11,  2, 'intermediate', TRUE),  -- Java (id 2)
(11, 27, 'beginner',     FALSE), -- Git & GitHub
-- Opportunity 12: Data Engineer Intern (Ola)
(12,  6, 'intermediate', TRUE),  -- CSS / Data
(12, 23, 'beginner',     TRUE),  -- AWS
(12, 18, 'intermediate', FALSE), -- PostgreSQL
-- Opportunity 13: Flutter Developer (Ola)
(13, 29, 'intermediate', TRUE),  -- Flutter
(13, 27, 'intermediate', FALSE), -- Git & GitHub
-- Opportunity 14: SDE-I (PhonePe)
(14, 28, 'advanced',     TRUE),  -- System Design
(14, 26, 'advanced',     TRUE),  -- REST API Design
(14, 18, 'intermediate', FALSE), -- PostgreSQL
(14, 24, 'beginner',     FALSE), -- Docker
-- Opportunity 15: Data Science Intern (PhonePe)
(15,  8, 'intermediate', TRUE),  -- Machine Learning (id 8)
(15,  1, 'intermediate', FALSE), -- Python (id 1)
-- Opportunity 16: Cloud Infrastructure Intern (PhonePe)
(16, 23, 'intermediate', TRUE),  -- AWS
(16, 24, 'intermediate', TRUE),  -- Docker
(16, 25, 'beginner',     FALSE), -- Kubernetes
-- Opportunity 17: Backend Engineer Part-Time (PhonePe)
(17, 17, 'intermediate', TRUE),  -- Node.js
(17, 26, 'intermediate', TRUE),  -- REST API Design
(17, 27, 'beginner',     FALSE); -- Git & GitHub

-- ==============================================================================
-- SECTION 8: STUDENT SKILLS (90 rows — 3 skills per student for students 4–33)
-- ==============================================================================

INSERT IGNORE INTO student_skills
    (student_id, skill_id, proficiency_level, proficiency_score, source, is_verified)
VALUES
-- Student 4 (Arjun Kapoor – DTU CSE)
( 4, 17, 'intermediate', 65.00, 'project',      FALSE),
( 4, 26, 'beginner',     45.00, 'self_declared', FALSE),
( 4,  1, 'intermediate', 70.00, 'quiz',          FALSE),
-- Student 5 (Sneha Gupta – DTU ECE)
( 5,  2, 'beginner',     40.00, 'self_declared', FALSE),
( 5, 27, 'beginner',     50.00, 'self_declared', FALSE),
( 5, 10, 'beginner',     35.00, 'self_declared', FALSE),
-- Student 6 (Vikram Singh – IIT Bombay CSE)
( 6,  1, 'advanced',     88.00, 'certificate',   TRUE),
( 6,  8, 'advanced',     85.00, 'project',       TRUE),
( 6, 20, 'intermediate', 72.00, 'quiz',          FALSE),
-- Student 7 (Kavya Nair – IIT Bombay DS)
( 7,  8, 'advanced',     90.00, 'project',       TRUE),
( 7, 22, 'intermediate', 75.00, 'certificate',   FALSE),
( 7,  1, 'advanced',     87.00, 'project',       TRUE),
-- Student 8 (Rahul Das – NIT Trichy IT)
( 8, 18, 'intermediate', 62.00, 'project',       FALSE),
( 8, 17, 'beginner',     48.00, 'self_declared', FALSE),
( 8, 27, 'intermediate', 60.00, 'project',       FALSE),
-- Student 9 (Pooja Krishnan – NIT Trichy CSE)
( 9, 16, 'intermediate', 68.00, 'project',       FALSE),
( 9, 17, 'beginner',     50.00, 'self_declared', FALSE),
( 9,  1, 'intermediate', 72.00, 'quiz',          FALSE),
-- Student 10 (Amit Joshi – VIT SE)
(10, 16, 'beginner',     45.00, 'self_declared', FALSE),
(10,  1, 'beginner',     40.00, 'self_declared', FALSE),
(10, 27, 'beginner',     42.00, 'self_declared', FALSE),
-- Student 11 (Divya Iyer – VIT CSE)
(11, 16, 'advanced',     82.00, 'project',       TRUE),
(11, 17, 'intermediate', 70.00, 'project',       FALSE),
(11, 26, 'intermediate', 65.00, 'project',       FALSE),
-- Student 12 (Karan Malhotra – BITS CSE)
(12,  1, 'expert',       95.00, 'teacher_verified', TRUE),
(12, 28, 'advanced',     88.00, 'project',          TRUE),
(12,  8, 'advanced',     85.00, 'project',          FALSE),
-- Student 13 (Ananya Sharma – BITS MSC)
(13,  1, 'advanced',     82.00, 'quiz',          TRUE),
(13, 22, 'advanced',     78.00, 'certificate',   FALSE),
(13, 10, 'intermediate', 70.00, 'project',       FALSE),
-- Student 14 (Siddharth Rao – IIIT Hyd CSE)
(14, 28, 'expert',       92.00, 'teacher_verified', TRUE),
(14, 26, 'advanced',     88.00, 'project',          TRUE),
(14,  1, 'advanced',     85.00, 'quiz',              FALSE),
-- Student 15 (Preethi Reddy – IIIT Hyd DS)
(15,  8, 'expert',       94.00, 'teacher_verified', TRUE),
(15, 21, 'advanced',     86.00, 'project',          TRUE),
(15, 10, 'advanced',     90.00, 'certificate',      FALSE),
-- Student 16 (Nikhil Bajaj – DTU ME)
(16,  2, 'beginner',     35.00, 'self_declared', FALSE),
(16, 27, 'beginner',     38.00, 'self_declared', FALSE),
(16, 26, 'beginner',     30.00, 'self_declared', FALSE),
-- Student 17 (Richa Sood – DTU CSE)
(17, 16, 'intermediate', 72.00, 'project',       FALSE),
(17, 17, 'advanced',     80.00, 'project',       TRUE),
(17, 26, 'advanced',     78.00, 'project',       FALSE),
-- Student 18 (Gaurav Tiwari – IIT Bombay AI)
(18, 20, 'advanced',     88.00, 'certificate',   TRUE),
(18, 21, 'advanced',     85.00, 'project',       TRUE),
(18,  8, 'expert',       92.00, 'teacher_verified', TRUE),
-- Student 19 (Swati Mishra – NIT Trichy IT)
(19, 10, 'intermediate', 65.00, 'quiz',          FALSE),
(19, 22, 'beginner',     48.00, 'self_declared', FALSE),
(19, 19, 'beginner',     42.00, 'self_declared', FALSE),
-- Student 20 (Tejas Patil – VIT CSE)
(20, 16, 'advanced',     80.00, 'project',       FALSE),
(20, 17, 'intermediate', 68.00, 'project',       FALSE),
(20, 18, 'intermediate', 65.00, 'project',       FALSE),
-- Student 21 (Neha Choudhary – BITS Physics)
(21, 27, 'intermediate', 60.00, 'self_declared', FALSE),
(21,  1, 'beginner',     40.00, 'self_declared', FALSE),
(21, 22, 'beginner',     38.00, 'self_declared', FALSE),
-- Student 22 (Ravi Kumar – IIIT Hyd CSE)
(22,  1, 'expert',       96.00, 'teacher_verified', TRUE),
(22, 28, 'expert',       94.00, 'teacher_verified', TRUE),
(22, 24, 'advanced',     85.00, 'certificate',      FALSE),
-- Student 23 (Ishaan Chandra – DTU DS)
(23, 10, 'advanced',     80.00, 'project',       FALSE),
(23, 22, 'intermediate', 68.00, 'project',       FALSE),
(23, 18, 'intermediate', 62.00, 'quiz',          FALSE),
-- Student 24 (Tanvi Shah – IIT Bombay CSE)
(24,  1, 'advanced',     87.00, 'project',       TRUE),
(24, 28, 'advanced',     84.00, 'project',       TRUE),
(24, 26, 'advanced',     82.00, 'certificate',   FALSE),
-- Student 25 (Aditya Pandey – NIT Trichy IT)
(25, 17, 'beginner',     42.00, 'self_declared', FALSE),
(25, 27, 'beginner',     45.00, 'self_declared', FALSE),
(25, 18, 'beginner',     40.00, 'self_declared', FALSE),
-- Student 26 (Shruti Verma – VIT CSE)
(26, 16, 'advanced',     83.00, 'project',       TRUE),
(26, 17, 'intermediate', 72.00, 'project',       FALSE),
(26, 26, 'intermediate', 70.00, 'project',       FALSE),
-- Student 27 (Manish Agarwal – BITS CSE)
(27,  1, 'expert',       93.00, 'teacher_verified', TRUE),
(27, 24, 'advanced',     85.00, 'certificate',      TRUE),
(27, 23, 'intermediate', 73.00, 'project',           FALSE),
-- Student 28 (Lavanya Bhat – IIIT Hyd DS)
(28,  8, 'advanced',     86.00, 'project',       TRUE),
(28, 10, 'advanced',     88.00, 'certificate',   TRUE),
(28, 21, 'intermediate', 74.00, 'project',       FALSE),
-- Student 29 (Parth Mehta – DTU CSE)
(29, 17, 'intermediate', 65.00, 'project',       FALSE),
(29, 26, 'intermediate', 62.00, 'project',       FALSE),
(29, 27, 'intermediate', 58.00, 'project',       FALSE),
-- Student 30 (Kritika Jain – IIT Bombay Math)
(30,  1, 'intermediate', 72.00, 'quiz',          FALSE),
(30, 10, 'advanced',     80.00, 'project',       FALSE),
(30, 22, 'intermediate', 68.00, 'certificate',   FALSE),
-- Student 31 (Yash Dubey – NIT Trichy CSE)
(31, 16, 'beginner',     42.00, 'self_declared', FALSE),
(31,  1, 'beginner',     38.00, 'self_declared', FALSE),
(31, 27, 'beginner',     44.00, 'self_declared', FALSE),
-- Student 32 (Pallavi Desai – VIT IT)
(32, 17, 'advanced',     80.00, 'project',       FALSE),
(32, 26, 'advanced',     78.00, 'project',       FALSE),
(32, 18, 'advanced',     75.00, 'certificate',   TRUE),
-- Student 33 (Akash Saxena – BITS CSE)
(33,  1, 'expert',       94.00, 'teacher_verified', TRUE),
(33, 28, 'advanced',     87.00, 'project',          TRUE),
(33, 24, 'intermediate', 72.00, 'project',           FALSE);

-- ==============================================================================
-- SECTION 9: 45 APPLICATIONS
-- (spread across new opportunities; status mix for pipeline demo)
-- ==============================================================================

INSERT IGNORE INTO applications
    (opportunity_id, student_id, application_status, resume_reference, cover_note)
VALUES
-- Opportunity 3: Zomato Backend Intern
( 3,  4, 'applied',      'resume_arjun_kapoor.pdf',    'Strong in Node.js. Excited to scale backend services.'),
( 3,  9, 'shortlisted',  'resume_pooja_krishnan.pdf',  'REST API projects at college, love distributed systems.'),
( 3, 17, 'interview',    'resume_richa_sood.pdf',      'Built full-stack projects, proficient in Node and Express.'),
-- Opportunity 4: Zomato Data Analyst
( 4, 23, 'applied',      'resume_ishaan_chandra.pdf',  'Data analysis capstone project on e-commerce funnels.'),
( 4, 30, 'shortlisted',  'resume_kritika_jain.pdf',    'Math background gives edge in quantitative analysis.'),
( 4,  7, 'selected',     'resume_kavya_nair.pdf',      'Advanced data analysis + visualization skills verified.'),
-- Opportunity 5: Zomato ML Engineer
( 5,  6, 'shortlisted',  'resume_vikram_singh.pdf',    'TensorFlow certified, 2 ML research papers.'),
( 5, 18, 'interview',    'resume_gaurav_tiwari.pdf',   'IIT Bombay AI MTech — production ML experience.'),
( 5, 15, 'shortlisted',  'resume_preethi_reddy.pdf',   'Expert-level ML skills verified by IIIT Hyd faculty.'),
-- Opportunity 6: BYJU'S Full-Stack
( 6,  9, 'applied',      'resume_pooja_krishnan.pdf',  'React and Node experience from college projects.'),
( 6, 11, 'interview',    'resume_divya_iyer.pdf',      'Advanced React skills verified, multiple project demos.'),
( 6, 20, 'shortlisted',  'resume_tejas_patil.pdf',     'Full-stack portfolio on GitHub — MERN stack ready.'),
( 6, 26, 'applied',      'resume_shruti_verma.pdf',    'Advanced React, loves edtech impact.'),
-- Opportunity 7: BYJU'S AI Content
( 7, 18, 'shortlisted',  'resume_gaurav_tiwari.pdf',   'PyTorch NLP projects at IIT Bombay AI lab.'),
( 7, 28, 'interview',    'resume_lavanya_bhat.pdf',    'ML/DS expert from IIIT Hyd. NLP projects published.'),
( 7, 15, 'applied',      'resume_preethi_reddy.pdf',   'Expert ML skills, willing to specialize in NLP.'),
-- Opportunity 8: Razorpay Backend Engineer
( 8, 14, 'interview',    'resume_siddharth_rao.pdf',   'System design expert from IIIT Hyd. Top-rated internship.'),
( 8, 22, 'shortlisted',  'resume_ravi_kumar.pdf',      'Expert system design, built payment APIs in projects.'),
( 8, 24, 'applied',      'resume_tanvi_shah.pdf',       'Advanced REST API + System Design from IIT Bombay.'),
-- Opportunity 9: Razorpay Security Intern
( 9, 27, 'shortlisted',  'resume_manish_agarwal.pdf',  'Cybersecurity coursework, CTF participant.'),
( 9, 33, 'applied',      'resume_akash_saxena.pdf',    'Interest in fintech security, backend background.'),
-- Opportunity 10: Razorpay DevOps Intern
(10, 27, 'interview',    'resume_manish_agarwal.pdf',  'Docker certified, AWS hands-on labs done.'),
(10, 22, 'shortlisted',  'resume_ravi_kumar.pdf',      'Containerized microservices in final year project.'),
-- Opportunity 11: Ola Embedded Systems
(11, 16, 'applied',      'resume_nikhil_bajaj.pdf',    'Mechanical + basic electronics background.'),
(11, 21, 'applied',      'resume_neha_choudhary.pdf',  'Physics major, interested in EV tech.'),
-- Opportunity 12: Ola Data Engineer
(12, 23, 'interview',    'resume_ishaan_chandra.pdf',  'Data engineering capstone on real-time IoT streams.'),
(12,  7, 'shortlisted',  'resume_kavya_nair.pdf',      'Expert data skills from IIT Bombay DS program.'),
(12, 19, 'applied',      'resume_swati_mishra.pdf',    'Basic data analysis + MongoDB experience.'),
-- Opportunity 13: Ola Flutter Developer
(13, 29, 'applied',      'resume_flutter_dev.pdf',     'Learning Flutter — 1 demo app published on Play Store.'),
-- Opportunity 14: PhonePe SDE-I
(14, 14, 'shortlisted',  'resume_siddharth_rao.pdf',   'Expert system design, strong competitive programming.'),
(14, 22, 'interview',    'resume_ravi_kumar.pdf',      'Expert level in system design verified by faculty.'),
(14, 12, 'applied',      'resume_karan_malhotra.pdf',  'Expert Python + System Design from BITS Pilani.'),
(14, 33, 'shortlisted',  'resume_akash_saxena.pdf',    'Expert Python + strong DSA background BITS CSE.'),
(14, 24, 'applied',      'resume_tanvi_shah.pdf',       'Strong system design + REST API portfolio.'),
-- Opportunity 15: PhonePe Data Science Intern
(15,  7, 'interview',    'resume_kavya_nair.pdf',      'ML/Data Science expertise — IIT Bombay DS.'),
(15, 15, 'shortlisted',  'resume_preethi_reddy.pdf',   'Expert ML from IIIT Hyd. Fraud detection research interest.'),
(15, 13, 'applied',      'resume_ananya_sharma.pdf',   'Advanced Python + Data Analysis from BITS.'),
(15, 28, 'applied',      'resume_lavanya_bhat.pdf',    'IIIT Hyd DS — strong ML and analysis background.'),
-- Opportunity 16: PhonePe Cloud Infrastructure
(16, 27, 'applied',      'resume_manish_agarwal.pdf',  'Docker + AWS certified, loves cloud architecture.'),
(16, 22, 'applied',      'resume_ravi_kumar.pdf',      'Strong on container tech, interested in cloud infra.'),
-- Opportunity 17: PhonePe Backend Part-Time
(17, 29, 'applied',      'resume_parth_mehta.pdf',     'Node.js + REST APIs from college project work.'),
(17, 17, 'applied',      'resume_richa_sood.pdf',      'Advanced Node.js skills with real projects.'),
(17,  4, 'applied',      'resume_arjun_kapoor.pdf',    'Good fit for part-time while finishing final year.'),
(17, 32, 'shortlisted',  'resume_pallavi_desai.pdf',   'Advanced Node and REST APIs, production experience.');

-- ==============================================================================
-- RESTORE FK CHECKS
-- ==============================================================================
SET FOREIGN_KEY_CHECKS = 1;

-- ==============================================================================
-- VERIFICATION: Row count audit
-- ==============================================================================
SELECT 'users'              AS entity, COUNT(*) AS total FROM users
UNION ALL SELECT 'student_profiles',   COUNT(*) FROM student_profiles
UNION ALL SELECT 'company_profiles',   COUNT(*) FROM company_profiles
UNION ALL SELECT 'teacher_profiles',   COUNT(*) FROM teacher_profiles
UNION ALL SELECT 'skills',             COUNT(*) FROM skills
UNION ALL SELECT 'student_skills',     COUNT(*) FROM student_skills
UNION ALL SELECT 'opportunities',      COUNT(*) FROM opportunities
UNION ALL SELECT 'opportunity_skills', COUNT(*) FROM opportunity_skills
UNION ALL SELECT 'applications',       COUNT(*) FROM applications;

SELECT 'Phase 2 — Expanded Seed Data loaded successfully.' AS seed_status;
