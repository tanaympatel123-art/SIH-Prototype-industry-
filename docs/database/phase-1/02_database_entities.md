# 02. Database Entity Catalog & Schema Specifications
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Entity Catalog, Attribute Specifications & Domain Analysis  
**Target Database:** PostgreSQL (v15+)  
**Author:** Database Architect & Engineer Team  
**Audience:** Development Team & Student Learners  

---

## 1. Domain Grouping Overview

To maintain clean architectural boundaries, all database tables are organized into 9 logical domains:

```
├── 1. CORE (Identity & Stakeholder Profiles)
├── 2. SKILLS (Skill Taxonomy & Verification)
├── 3. ASSESSMENT (Quizzes, Questions, Attempts & Answers)
├── 4. OPPORTUNITIES (Listings, Skill Needs & Application Engine)
├── 5. PORTFOLIO (Student Projects, Resumes & Certificates)
├── 6. INTERVIEWS (Scheduling, Slots & Evaluator Notes)
├── 7. LEARNING (Upskilling, Resources & Gap Recommendations)
├── 8. COLLABORATION (Faculty-Industry Programs, Research & Mentorship)
└── 9. SYSTEM (Notifications, Feedback & Security Audit Logs)
```

---

## 2. Comprehensive Entity Catalog

### Domain 1: CORE (Identity & Stakeholder Profiles)

#### 1.1 `roles`
* **Purpose:** Stores the system-wide role definitions enforcing Role-Based Access Control (RBAC).
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `SMALLSERIAL` (or `INT`), PRIMARY KEY
  * `name`: `VARCHAR(50)`, UNIQUE, NOT NULL (e.g. `'student'`, `'company'`, `'teacher'`, `'institution_admin'`, `'super_admin'`)
  * `description`: `TEXT`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 1.2 `institutions`
* **Purpose:** Represents colleges, universities, and polytechnics. All students and teachers must belong to an accredited institution.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `name`: `VARCHAR(255)`, NOT NULL
  * `code`: `VARCHAR(50)`, UNIQUE, NOT NULL (AISHE code or college registration code)
  * `website`: `VARCHAR(255)`
  * `city`: `VARCHAR(100)`, NOT NULL
  * `state`: `VARCHAR(100)`, NOT NULL
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 1.3 `users`
* **Purpose:** The root authentication entity. Holds credentials, login metadata, and primary email for all human actors.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `email`: `VARCHAR(255)`, UNIQUE, NOT NULL
  * `password_hash`: `VARCHAR(255)`, NOT NULL (Bcrypt/Argon2id hash only)
  * `role_id`: `INT`, NOT NULL, FOREIGN KEY REFERENCES `roles(id)`
  * `phone`: `VARCHAR(20)`
  * `is_active`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `is_email_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `last_login_at`: `TIMESTAMPTZ`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 1.4 `student_profiles`
* **Purpose:** Extended academic and biographical details specific to student users.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, UNIQUE, NOT NULL, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `institution_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `institutions(id)` ON DELETE RESTRICT
  * `first_name`: `VARCHAR(100)`, NOT NULL
  * `last_name`: `VARCHAR(100)`, NOT NULL
  * `roll_number`: `VARCHAR(50)`, NOT NULL (USN / Registration Number)
  * `department`: `VARCHAR(100)`, NOT NULL (e.g. Computer Science, Mechanical)
  * `current_semester`: `SMALLINT`, NOT NULL
  * `cgpa`: `NUMERIC(4,2)` (e.g. 8.75)
  * `graduation_year`: `INT`, NOT NULL
  * `headline`: `VARCHAR(255)`
  * `bio`: `TEXT`
  * `github_url`: `VARCHAR(255)`
  * `linkedin_url`: `VARCHAR(255)`
  * `portfolio_url`: `VARCHAR(255)`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 1.5 `company_profiles`
* **Purpose:** Corporate identity, industry domain, verification documentation, and recruiter details.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, UNIQUE, NOT NULL, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `company_name`: `VARCHAR(255)`, NOT NULL
  * `industry_type`: `VARCHAR(100)`, NOT NULL (e.g. IT, FinTech, Manufacturing)
  * `website`: `VARCHAR(255)`
  * `registration_number`: `VARCHAR(100)` (CIN or GSTIN)
  * `company_size`: `VARCHAR(50)` (e.g. '1-10', '11-50', '51-200', '500+')
  * `headquarters`: `VARCHAR(255)`
  * `description`: `TEXT`
  * `logo_url`: `VARCHAR(500)`
  * `verification_status`: `VARCHAR(50)`, DEFAULT `'pending'` ('pending', 'verified', 'rejected')
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 1.6 `teacher_profiles`
* **Purpose:** Faculty profile capturing designation, department, institutional affiliation, and research interests.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, UNIQUE, NOT NULL, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `institution_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `institutions(id)` ON DELETE RESTRICT
  * `first_name`: `VARCHAR(100)`, NOT NULL
  * `last_name`: `VARCHAR(100)`, NOT NULL
  * `faculty_id`: `VARCHAR(50)` (Employee ID)
  * `designation`: `VARCHAR(100)`, NOT NULL (e.g. Assistant Professor, HOD)
  * `department`: `VARCHAR(100)`, NOT NULL
  * `specialization`: `VARCHAR(255)`
  * `bio`: `TEXT`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 2: SKILLS (Taxonomy & Verification)

#### 2.1 `skill_categories`
* **Purpose:** Logical taxonomy grouping skills (e.g. "Web Development", "Data Science", "Embedded Systems", "Soft Skills").
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `SERIAL`, PRIMARY KEY
  * `name`: `VARCHAR(100)`, UNIQUE, NOT NULL
  * `description`: `TEXT`

#### 2.2 `skills`
* **Purpose:** Master canonical list of standardized technical and professional skills.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `category_id`: `INT`, NOT NULL, FOREIGN KEY REFERENCES `skill_categories(id)` ON DELETE RESTRICT
  * `name`: `VARCHAR(100)`, UNIQUE, NOT NULL (e.g. 'PostgreSQL', 'Python', 'React')
  * `description`: `TEXT`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 2.3 `student_skills`
* **Purpose:** Junction entity linking a student to their claimed/assessed skills, storing current proficiency level.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `proficiency_level`: `VARCHAR(50)`, NOT NULL, DEFAULT `'beginner'` ('beginner', 'intermediate', 'advanced', 'expert')
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `verification_score`: `NUMERIC(5,2)` (Score from quiz or assessment, e.g. 85.00)
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * *Constraint:* `UNIQUE(student_id, skill_id)`

#### 2.4 `skill_verifications`
* **Purpose:** Audit log of who verified a student's skill (Teacher, Quiz Engine, or Corporate Recruiter) and on what basis.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_skills(id)` ON DELETE CASCADE
  * `verified_by_user_id`: `UUID`, FOREIGN KEY REFERENCES `users(id)` ON DELETE SET NULL
  * `verification_source`: `VARCHAR(50)`, NOT NULL ('quiz', 'teacher_endorsement', 'company_internship', 'external_certificate')
  * `certificate_url`: `VARCHAR(500)`
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'approved'` ('pending', 'approved', 'rejected')
  * `comments`: `TEXT`
  * `verified_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 3: ASSESSMENT (Quiz Engine)

#### 3.1 `assessments`
* **Purpose:** Standardized evaluation tests tied to specific skills or subjects (e.g. "PostgreSQL Fundamentals Quiz").
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `title`: `VARCHAR(255)`, NOT NULL
  * `description`: `TEXT`
  * `duration_minutes`: `INT`, NOT NULL, DEFAULT `30`
  * `pass_percentage`: `NUMERIC(5,2)`, NOT NULL, DEFAULT `70.00`
  * `total_questions`: `INT`, NOT NULL, DEFAULT `10`
  * `is_active`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 3.2 `assessment_questions`
* **Purpose:** Individual questions inside an assessment test.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `assessment_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessments(id)` ON DELETE CASCADE
  * `question_text`: `TEXT`, NOT NULL
  * `question_type`: `VARCHAR(50)`, NOT NULL, DEFAULT `'multiple_choice'` ('multiple_choice', 'single_choice', 'true_false')
  * `difficulty`: `VARCHAR(50)`, NOT NULL, DEFAULT `'medium'` ('easy', 'medium', 'hard')
  * `marks`: `INT`, NOT NULL, DEFAULT `1`
  * `explanation`: `TEXT`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 3.3 `assessment_options`
* **Purpose:** Possible answers/choices for each question.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `question_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_questions(id)` ON DELETE CASCADE
  * `option_text`: `TEXT`, NOT NULL
  * `is_correct`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`

#### 3.4 `assessment_attempts`
* **Purpose:** An instance of a student attempting an assessment.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `assessment_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessments(id)` ON DELETE RESTRICT
  * `score_obtained`: `NUMERIC(5,2)`
  * `passed`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `started_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `completed_at`: `TIMESTAMPTZ`

#### 3.5 `assessment_answers`
* **Purpose:** The student's recorded option selections for each question in a given attempt.
* **Classification:** **P2 (Optional / Analytics)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `attempt_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_attempts(id)` ON DELETE CASCADE
  * `question_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_questions(id)` ON DELETE RESTRICT
  * `selected_option_id`: `UUID`, FOREIGN KEY REFERENCES `assessment_options(id)` ON DELETE SET NULL
  * `is_correct`: `BOOLEAN`, NOT NULL

---

### Domain 4: OPPORTUNITIES (Listings & Applications)

#### 4.1 `opportunities`
* **Purpose:** Job, internship, or project postings published by company partners.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `company_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `company_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `opportunity_type`: `VARCHAR(50)`, NOT NULL ('internship', 'full_time', 'project', 'apprentice')
  * `work_mode`: `VARCHAR(50)`, NOT NULL ('remote', 'hybrid', 'on_site')
  * `location`: `VARCHAR(255)`
  * `stipend_amount`: `NUMERIC(10,2)` (0 for unpaid, >0 for paid)
  * `currency`: `VARCHAR(10)`, DEFAULT `'INR'`
  * `duration_months`: `INT`
  * `openings_count`: `INT`, NOT NULL, DEFAULT `1`
  * `description`: `TEXT`, NOT NULL
  * `requirements`: `TEXT`
  * `application_deadline`: `TIMESTAMPTZ`, NOT NULL
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'active'` ('draft', 'active', 'closed', 'cancelled')
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 4.2 `opportunity_skills`
* **Purpose:** Junction table defining required or preferred skills for an opportunity with minimum proficiency.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `opportunity_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `opportunities(id)` ON DELETE CASCADE
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `is_mandatory`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `min_proficiency`: `VARCHAR(50)`, NOT NULL, DEFAULT `'intermediate'` ('beginner', 'intermediate', 'advanced', 'expert')
  * *Constraint:* `UNIQUE(opportunity_id, skill_id)`

#### 4.3 `applications`
* **Purpose:** Represents a student's formal application to an opportunity.
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `opportunity_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `opportunities(id)` ON DELETE RESTRICT
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `resume_id`: `UUID`, FOREIGN KEY REFERENCES `resumes(id)` ON DELETE SET NULL
  * `cover_letter`: `TEXT`
  * `match_score`: `NUMERIC(5,2)` (Calculated skill match %, e.g. 88.50)
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'applied'` ('applied', 'reviewing', 'shortlisted', 'interview_scheduled', 'offered', 'rejected', 'withdrawn')
  * `applied_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * *Constraint:* `UNIQUE(opportunity_id, student_id)` (prevents double applying)

#### 4.4 `application_status_history`
* **Purpose:** Audit log of all state transitions for an application over time.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `application_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `applications(id)` ON DELETE CASCADE
  * `old_status`: `VARCHAR(50)`
  * `new_status`: `VARCHAR(50)`, NOT NULL
  * `changed_by_user_id`: `UUID`, FOREIGN KEY REFERENCES `users(id)` ON DELETE SET NULL
  * `remarks`: `TEXT`
  * `changed_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 5: PORTFOLIO & ASSETS

#### 5.1 `resumes`
* **Purpose:** Stores student uploaded resumes (metadata & secure storage URI).
* **Classification:** **P0 (Essential MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `file_name`: `VARCHAR(255)`, NOT NULL
  * `file_url`: `VARCHAR(500)`, NOT NULL
  * `file_size_bytes`: `BIGINT`, NOT NULL
  * `is_primary`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 5.2 `projects`
* **Purpose:** Academic, personal, and hackathon projects showcased by students.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `description`: `TEXT`, NOT NULL
  * `project_url`: `VARCHAR(500)`
  * `github_url`: `VARCHAR(500)`
  * `start_date`: `DATE`
  * `end_date`: `DATE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 5.3 `certificates`
* **Purpose:** External course certifications (Coursera, AWS, NPTEL) uploaded for faculty endorsement.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `issuing_organization`: `VARCHAR(255)`, NOT NULL
  * `issue_date`: `DATE`, NOT NULL
  * `credential_id`: `VARCHAR(255)`
  * `credential_url`: `VARCHAR(500)`
  * `file_url`: `VARCHAR(500)`
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `verified_by_teacher_id`: `UUID`, FOREIGN KEY REFERENCES `teacher_profiles(id)` ON DELETE SET NULL

---

### Domain 6: INTERVIEWS

#### 6.1 `interview_slots`
* **Purpose:** Available interview calendar slots created by company recruiters.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `company_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `company_profiles(id)` ON DELETE CASCADE
  * `start_time`: `TIMESTAMPTZ`, NOT NULL
  * `end_time`: `TIMESTAMPTZ`, NOT NULL
  * `is_booked`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 6.2 `interviews`
* **Purpose:** A confirmed interview appointment linked to an application.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `application_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `applications(id)` ON DELETE CASCADE
  * `slot_id`: `UUID`, UNIQUE, FOREIGN KEY REFERENCES `interview_slots(id)` ON DELETE RESTRICT
  * `scheduled_time`: `TIMESTAMPTZ`, NOT NULL
  * `meeting_url`: `VARCHAR(500)`
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'scheduled'` ('scheduled', 'completed', 'cancelled', 'rescheduled')
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 7: LEARNING & SKILL GAP

#### 7.1 `learning_resources`
* **Purpose:** Curated tutorials, documentation, and MOOC courses recommended for bridging specific skill gaps.
* **Classification:** **P2 (Optional / Post-MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `provider`: `VARCHAR(100)` (e.g. 'Coursera', 'NPTEL', 'YouTube', 'Official Docs')
  * `resource_url`: `VARCHAR(500)`, NOT NULL
  * `resource_type`: `VARCHAR(50)` ('video', 'article', 'interactive', 'course')
  * `estimated_hours`: `INT`

#### 7.2 `skill_gap_recommendations`
* **Purpose:** Cached or generated skill-gap analysis comparing a student to target opportunity requirements.
* **Classification:** **P2 (Optional / Dynamic View candidate)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `opportunity_id`: `UUID`, FOREIGN KEY REFERENCES `opportunities(id)` ON DELETE CASCADE
  * `missing_skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `recommended_resource_id`: `UUID`, FOREIGN KEY REFERENCES `learning_resources(id)` ON DELETE SET NULL
  * `generated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 8: COLLABORATION & PROGRAMS

#### 8.1 `programs`
* **Purpose:** Faculty Development Programs (FDPs), industry workshops, and student bootcamps.
* **Classification:** **P2 (Optional / Post-MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `title`: `VARCHAR(255)`, NOT NULL
  * `organized_by_user_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `users(id)`
  * `institution_id`: `UUID`, FOREIGN KEY REFERENCES `institutions(id)`
  * `start_date`: `DATE`, NOT NULL
  * `end_date`: `DATE`, NOT NULL
  * `mode`: `VARCHAR(50)` ('online', 'in_person')
  * `description`: `TEXT`

#### 8.2 `mentorships`
* **Purpose:** Formal teacher-to-student or industry-to-student mentorship agreements.
* **Classification:** **P2 (Optional / Post-MVP)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `mentor_user_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `users(id)`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `status`: `VARCHAR(50)`, DEFAULT `'active'` ('active', 'completed', 'terminated')
  * `started_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

### Domain 9: SYSTEM & COMPLIANCE

#### 9.1 `notifications`
* **Purpose:** In-app notification alerts for application updates, interview invites, and verifications.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `message`: `TEXT`, NOT NULL
  * `is_read`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `action_url`: `VARCHAR(500)`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 9.2 `feedback`
* **Purpose:** Structured feedback submitted after interviews or completed internships.
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `application_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `applications(id)` ON DELETE CASCADE
  * `submitted_by_user_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `users(id)`
  * `rating`: `SMALLINT`, NOT NULL (1 to 5 stars)
  * `technical_score`: `SMALLINT` (1 to 10)
  * `communication_score`: `SMALLINT` (1 to 10)
  * `strengths`: `TEXT`
  * `improvements`: `TEXT`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

#### 9.3 `audit_logs`
* **Purpose:** Regulatory append-only audit trail recording sensitive changes (role promotions, profile verifications, security logins).
* **Classification:** **P1 (Important)**
* **Proposed Attributes:**
  * `id`: `BIGSERIAL`, PRIMARY KEY
  * `user_id`: `UUID`, FOREIGN KEY REFERENCES `users(id)` ON DELETE SET NULL
  * `action`: `VARCHAR(100)`, NOT NULL (e.g. 'USER_LOGIN', 'VERIFY_COMPANY', 'CHANGE_ROLE')
  * `entity_name`: `VARCHAR(100)`, NOT NULL (e.g. 'company_profiles')
  * `entity_id`: `VARCHAR(100)`, NOT NULL
  * `ip_address`: `VARCHAR(45)`
  * `user_agent`: `TEXT`
  * `details`: `JSONB`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

## 3. Student Learning Corner: Entities and Keys

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is an Entity, a Primary Key (PK), and a Foreign Key (FK)?**
> - An **Entity** is an independent concept or object in your domain (like a Student, a Company, an Internship, or a Skill) that holds data.
> - A **Primary Key (PK)** is a unique identifier that guarantees every single row in a table can be uniquely addressed. In PostgreSQL, we often use `UUID` (Universally Unique Identifier) or `BIGSERIAL` (auto-incrementing integer).
> - A **Foreign Key (FK)** is a column in one table that references the Primary Key of another table, creating a relational link and enforcing referential integrity.
> 
> **WHY do we separate `users` from `student_profiles`, `company_profiles`, and `teacher_profiles`?**  
> Beginners often make the mistake of creating a single massive table called `users` with columns like `cgpa`, `semester`, `company_name`, `cin_number`, `faculty_designation`.
> What is wrong with that?
> 1. If a row is for a company, the `cgpa` and `semester` columns will be `NULL`.
> 2. If a row is for a student, the `company_name` and `cin_number` columns will be `NULL`.
> 3. Your table becomes filled with hundreds of empty `NULL` cells (sparse table), creating messy validation logic and security hazards.
> 
> By keeping a lean `users` table for credentials and linking 1-to-1 profile tables (`student_profiles`, `company_profiles`, `teacher_profiles`), each entity only stores columns relevant to its specific stakeholder role!
> 
> **HOW does it apply to this project?**  
> When a student logs in, the authentication system checks `users` with their email and password hash. Once authenticated, the app looks up `student_profiles` using `WHERE user_id = :authenticated_user_id` to render their dashboard.
