# 01. Formal Database Schema Design Contracts
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Formal PostgreSQL Physical Schema Design & Column Contracts  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  
**Audience:** Backend Engineers, Database Administrators & Student Learners  

---

## 1. Design Principles & Standards

In Phase 2, we formalize the database design contracts. Every table, column, constraint, and index is specified with strict mathematical and relational rigor.

### Key Architectural Standards:
1. **Primary Key Strategy:**
   - **`UUID` (v4):** Used for all public-facing and security-sensitive entities (`users`, `student_profiles`, `company_profiles`, `teacher_profiles`, `opportunities`, `applications`, `resumes`, `interviews`) to prevent Insecure Direct Object Reference (IDOR) attacks and ID enumeration.
   - **`BIGINT GENERATED ALWAYS AS IDENTITY`:** Used for high-volume append-only audit tables and granular transaction logs (`audit_logs`, `assessment_answers`, `application_status_history`). This standard PostgreSQL syntax replaces legacy `BIGSERIAL` with SQL-compliant identity columns.
   - **`SMALLINT GENERATED ALWAYS AS IDENTITY` / `INT`:** Used for bounded static lookup tables (`roles`, `skill_categories`).
2. **Temporal Standard:**
   - All timestamp columns use **`TIMESTAMP WITH TIME ZONE` (`TIMESTAMPTZ`)** and default to **`NOW()`** in UTC.
3. **Controlled Vocabularies & State Machines:**
   - All state columns (`status`, `proficiency_level`, `work_mode`) are governed by explicit PostgreSQL **`CHECK` constraints** to eliminate invalid strings.
4. **Referential Integrity & Delete Cascades:**
   - `ON DELETE CASCADE` is applied strictly to tight 1:1 profile extensions and dependent child records (e.g. deleting a student account cascades to their profile and resumes).
   - `ON DELETE RESTRICT` is applied to business transactions (e.g. an opportunity with applications cannot be deleted; a role with active users cannot be removed).
   - `ON DELETE SET NULL` is applied to audit linkages (e.g. if a verifying teacher leaves the institution, the verification badge remains with `verifier_id = NULL`).

---

## 2. Core Domain Contracts

### 2.1 `roles`
* **Purpose:** System-level RBAC role definitions.
* **Columns:**
  * `id`: `SMALLINT GENERATED ALWAYS AS IDENTITY`, PRIMARY KEY
  * `name`: `VARCHAR(50)`, NOT NULL, UNIQUE (e.g. `'student'`, `'company'`, `'teacher'`, `'institution_admin'`, `'super_admin'`)
  * `description`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:** `uq_roles_name UNIQUE (name)`

### 2.2 `institutions`
* **Purpose:** Accredited universities and colleges hosting students and faculty.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `name`: `VARCHAR(255)`, NOT NULL
  * `code`: `VARCHAR(50)`, NOT NULL, UNIQUE (AISHE or statutory registration code)
  * `website`: `VARCHAR(255)`, NULL
  * `city`: `VARCHAR(100)`, NOT NULL
  * `state`: `VARCHAR(100)`, NOT NULL
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:** `uq_institutions_code UNIQUE (code)`

### 2.3 `users`
* **Purpose:** Root authentication and credential entity.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `email`: `VARCHAR(255)`, NOT NULL, UNIQUE
  * `password_hash`: `VARCHAR(255)`, NOT NULL (Bcrypt or Argon2id hash only)
  * `role_id`: `SMALLINT`, NOT NULL, FOREIGN KEY REFERENCES `roles(id)` ON DELETE RESTRICT
  * `phone`: `VARCHAR(20)`, NULL
  * `is_active`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `is_email_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `last_login_at`: `TIMESTAMPTZ`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:** `uq_users_email UNIQUE (email)`

### 2.4 `student_profiles`
* **Purpose:** Extended academic and demographic attributes for student users.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, NOT NULL, UNIQUE, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `institution_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `institutions(id)` ON DELETE RESTRICT
  * `first_name`: `VARCHAR(100)`, NOT NULL
  * `last_name`: `VARCHAR(100)`, NOT NULL
  * `roll_number`: `VARCHAR(50)`, NOT NULL
  * `department`: `VARCHAR(100)`, NOT NULL
  * `current_semester`: `SMALLINT`, NOT NULL, CHECK (`current_semester BETWEEN 1 AND 12`)
  * `cgpa`: `NUMERIC(4, 2)`, NULL, CHECK (`cgpa >= 0.00 AND cgpa <= 10.00`)
  * `graduation_year`: `INT`, NOT NULL, CHECK (`graduation_year >= 2020 AND graduation_year <= 2040`)
  * `headline`: `VARCHAR(255)`, NULL
  * `bio`: `TEXT`, NULL
  * `github_url`: `VARCHAR(255)`, NULL
  * `linkedin_url`: `VARCHAR(255)`, NULL
  * `portfolio_url`: `VARCHAR(255)`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_student_profiles_user UNIQUE (user_id)`
  * `uq_student_roll_institution UNIQUE (institution_id, roll_number)`

### 2.5 `company_profiles`
* **Purpose:** Corporate credentials, employer branding, and statutory business registration.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, NOT NULL, UNIQUE, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `company_name`: `VARCHAR(255)`, NOT NULL
  * `industry_type`: `VARCHAR(100)`, NOT NULL
  * `website`: `VARCHAR(255)`, NULL
  * `registration_number`: `VARCHAR(100)`, NULL (CIN / GSTIN)
  * `company_size`: `VARCHAR(50)`, NULL
  * `headquarters`: `VARCHAR(255)`, NULL
  * `description`: `TEXT`, NULL
  * `logo_url`: `VARCHAR(500)`, NULL
  * `verification_status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'pending'`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_company_profiles_user UNIQUE (user_id)`
  * `chk_company_verification CHECK (verification_status IN ('pending', 'verified', 'rejected'))`

### 2.6 `teacher_profiles`
* **Purpose:** Faculty profile, academic department, and skill verification authority.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `user_id`: `UUID`, NOT NULL, UNIQUE, FOREIGN KEY REFERENCES `users(id)` ON DELETE CASCADE
  * `institution_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `institutions(id)` ON DELETE RESTRICT
  * `first_name`: `VARCHAR(100)`, NOT NULL
  * `last_name`: `VARCHAR(100)`, NOT NULL
  * `faculty_id`: `VARCHAR(50)`, NULL (Employee code)
  * `designation`: `VARCHAR(100)`, NOT NULL (e.g. Professor, Assistant Professor, HOD)
  * `department`: `VARCHAR(100)`, NOT NULL
  * `specialization`: `VARCHAR(255)`, NULL
  * `bio`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_teacher_profiles_user UNIQUE (user_id)`
  * `uq_teacher_faculty_institution UNIQUE (institution_id, faculty_id)`

---

## 3. Skill Domain Contracts (Hierarchical Taxonomy)

### 3.1 `skill_categories`
* **Purpose:** High-level domain groupings (e.g. Programming, Tools, Cloud, Soft Skills).
* **Columns:**
  * `id`: `INT GENERATED ALWAYS AS IDENTITY`, PRIMARY KEY
  * `name`: `VARCHAR(100)`, NOT NULL, UNIQUE
  * `description`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:** `uq_skill_categories_name UNIQUE (name)`

### 3.2 `skills` (Supports Parent Hierarchy)
* **Purpose:** Standardized skill catalog with self-referencing hierarchical support (`parent_skill_id`).
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `category_id`: `INT`, NOT NULL, FOREIGN KEY REFERENCES `skill_categories(id)` ON DELETE RESTRICT
  * `parent_skill_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE SET NULL
  * `name`: `VARCHAR(100)`, NOT NULL, UNIQUE
  * `description`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Hierarchy Design Decision:**
  * E.g.: `Programming (Category)` $\to$ `Python (Skill, parent=NULL)` $\to$ `FastAPI (Sub-skill, parent=Python)`.
  * Allows recruiters to search broadly ("Python") or specifically ("FastAPI").
* **Integrity Constraints:** `uq_skills_name UNIQUE (name)`

### 3.3 `student_skills`
* **Purpose:** Junction table linking student to their claimed and tested skills.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `proficiency_level`: `VARCHAR(50)`, NOT NULL, DEFAULT `'beginner'`
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `verification_score`: `NUMERIC(5, 2)`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_student_skill UNIQUE (student_id, skill_id)`
  * `chk_student_skill_prof CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced', 'expert'))`

### 3.4 `skill_verifications`
* **Purpose:** Verifiable proof trail recording endorsements by faculty, quizzes, or industry internships.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_skills(id)` ON DELETE CASCADE
  * `verifier_teacher_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `teacher_profiles(id)` ON DELETE SET NULL
  * `verification_source`: `VARCHAR(50)`, NOT NULL DEFAULT `'quiz'`
  * `certificate_id`: `UUID`, NULL -- Linked to certificates table
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'approved'`
  * `comments`: `TEXT`, NULL
  * `verified_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `chk_verif_source CHECK (verification_source IN ('quiz', 'teacher_endorsement', 'company_internship', 'external_certificate'))`
  * `chk_verif_status CHECK (status IN ('pending', 'approved', 'rejected'))`

---

## 4. Assessment Domain Contracts (Quiz Engine)

### 4.1 `assessments`
* **Purpose:** Versioned evaluation tests tied to specific skills.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `title`: `VARCHAR(255)`, NOT NULL
  * `description`: `TEXT`, NULL
  * `quiz_version`: `INT`, NOT NULL, DEFAULT `1`
  * `scoring_version`: `INT`, NOT NULL, DEFAULT `1`
  * `duration_minutes`: `INT`, NOT NULL, DEFAULT `30`
  * `pass_percentage`: `NUMERIC(5, 2)`, NOT NULL, DEFAULT `70.00`
  * `total_questions`: `INT`, NOT NULL, DEFAULT `10`
  * `is_active`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

### 4.2 `assessment_questions`
* **Purpose:** Question repository for assessments.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `assessment_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessments(id)` ON DELETE CASCADE
  * `question_text`: `TEXT`, NOT NULL
  * `question_type`: `VARCHAR(50)`, NOT NULL, DEFAULT `'multiple_choice'`
  * `difficulty`: `VARCHAR(50)`, NOT NULL, DEFAULT `'medium'`
  * `marks`: `INT`, NOT NULL, DEFAULT `1`
  * `explanation`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `chk_question_difficulty CHECK (difficulty IN ('easy', 'medium', 'hard'))`
  * `chk_question_type CHECK (question_type IN ('multiple_choice', 'single_choice', 'true_false'))`

### 4.3 `assessment_options`
* **Purpose:** Answer choices with correctness indicator.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `question_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_questions(id)` ON DELETE CASCADE
  * `option_text`: `TEXT`, NOT NULL
  * `is_correct`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`

### 4.4 `assessment_attempts`
* **Purpose:** Student test execution session with versioning and completion state.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `assessment_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessments(id)` ON DELETE RESTRICT
  * `attempt_number`: `INT`, NOT NULL, DEFAULT `1`
  * `quiz_version`: `INT`, NOT NULL, DEFAULT `1`
  * `scoring_version`: `INT`, NOT NULL, DEFAULT `1`
  * `score_obtained`: `NUMERIC(5, 2)`, NOT NULL, DEFAULT `0.00`
  * `passed`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `completion_status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'in_progress'`
  * `started_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `submitted_at`: `TIMESTAMPTZ`, NULL
  * `completed_at`: `TIMESTAMPTZ`, NULL
* **Integrity Constraints:**
  * `chk_attempt_status CHECK (completion_status IN ('in_progress', 'completed', 'timed_out', 'abandoned'))`

### 4.5 `assessment_answers`
* **Purpose:** Granular question-by-question audit responses.
* **Columns:**
  * `id`: `BIGINT GENERATED ALWAYS AS IDENTITY`, PRIMARY KEY
  * `attempt_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_attempts(id)` ON DELETE CASCADE
  * `question_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `assessment_questions(id)` ON DELETE RESTRICT
  * `selected_option_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `assessment_options(id)` ON DELETE SET NULL
  * `is_correct`: `BOOLEAN`, NOT NULL
  * `answered_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

## 5. Opportunity & Application Domain Contracts

### 5.1 `opportunities`
* **Purpose:** Internships, full-time jobs, and research project postings.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `company_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `company_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `opportunity_type`: `VARCHAR(50)`, NOT NULL, DEFAULT `'internship'`
  * `work_mode`: `VARCHAR(50)`, NOT NULL, DEFAULT `'remote'`
  * `location`: `VARCHAR(255)`, NULL
  * `stipend_amount`: `NUMERIC(10, 2)`, NOT NULL, DEFAULT `0.00`
  * `currency`: `VARCHAR(10)`, NOT NULL, DEFAULT `'INR'`
  * `duration_months`: `INT`, NULL, DEFAULT `6`
  * `openings_count`: `INT`, NOT NULL, DEFAULT `1`, CHECK (`openings_count >= 1`)
  * `description`: `TEXT`, NOT NULL
  * `requirements`: `TEXT`, NULL
  * `application_deadline`: `TIMESTAMPTZ`, NOT NULL
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'active'`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `chk_opp_type CHECK (opportunity_type IN ('internship', 'full_time', 'project', 'apprentice'))`
  * `chk_opp_work_mode CHECK (work_mode IN ('remote', 'hybrid', 'on_site'))`
  * `chk_opp_status CHECK (status IN ('draft', 'active', 'closed', 'cancelled'))`

### 5.2 `opportunity_skills`
* **Purpose:** Granular skill requirements with proficiency thresholds and mathematical weights.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `opportunity_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `opportunities(id)` ON DELETE CASCADE
  * `skill_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `skills(id)` ON DELETE RESTRICT
  * `is_mandatory`: `BOOLEAN`, NOT NULL, DEFAULT `TRUE`
  * `min_proficiency`: `VARCHAR(50)`, NOT NULL, DEFAULT `'intermediate'`
  * `skill_weight`: `NUMERIC(3, 2)`, NOT NULL, DEFAULT `1.00`, CHECK (`skill_weight > 0.00`)
* **Integrity Constraints:**
  * `uq_opportunity_skill UNIQUE (opportunity_id, skill_id)`
  * `chk_opp_skill_prof CHECK (min_proficiency IN ('beginner', 'intermediate', 'advanced', 'expert'))`

### 5.3 `applications`
* **Purpose:** Student application intake with unique guardrails and calculated match scores.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `opportunity_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `opportunities(id)` ON DELETE RESTRICT
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `resume_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `resumes(id)` ON DELETE SET NULL
  * `cover_letter`: `TEXT`, NULL
  * `match_score`: `NUMERIC(5, 2)`, NULL, CHECK (`match_score >= 0.00 AND match_score <= 100.00`)
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'APPLIED'`
  * `applied_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
  * `updated_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_student_opportunity UNIQUE (opportunity_id, student_id)`
  * `chk_application_state CHECK (status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))`

### 5.4 `application_status_history`
* **Purpose:** Immutable audit timeline for every status transition.
* **Columns:**
  * `id`: `BIGINT GENERATED ALWAYS AS IDENTITY`, PRIMARY KEY
  * `application_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `applications(id)` ON DELETE CASCADE
  * `old_status`: `VARCHAR(50)`, NULL
  * `new_status`: `VARCHAR(50)`, NOT NULL
  * `changed_by_user_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `users(id)` ON DELETE SET NULL
  * `remarks`: `TEXT`, NULL
  * `changed_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `chk_hist_new_status CHECK (new_status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))`

---

## 6. Portfolio & Verification Contracts

### 6.1 `resumes`
* **Purpose:** Student resumes supporting versioning and primary CV flagging.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `file_name`: `VARCHAR(255)`, NOT NULL
  * `file_url`: `VARCHAR(500)`, NOT NULL
  * `file_size_bytes`: `BIGINT`, NOT NULL
  * `version_number`: `INT`, NOT NULL, DEFAULT `1`
  * `is_primary`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

### 6.2 `projects`
* **Purpose:** Showcase of academic capstones, hackathons, and personal software projects.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `description`: `TEXT`, NOT NULL
  * `project_url`: `VARCHAR(500)`, NULL
  * `github_url`: `VARCHAR(500)`, NULL
  * `start_date`: `DATE`, NULL
  * `end_date`: `DATE`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

### 6.3 `certificates`
* **Purpose:** External credentials (NPTEL, AWS, Coursera) with verification URL preventing AI hallucination.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `title`: `VARCHAR(255)`, NOT NULL
  * `issuing_organization`: `VARCHAR(255)`, NOT NULL
  * `issue_date`: `DATE`, NOT NULL
  * `credential_id`: `VARCHAR(255)`, NULL
  * `credential_url`: `VARCHAR(500)`, NULL
  * `file_url`: `VARCHAR(500)`, NULL
  * `is_verified`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `verified_by_teacher_id`: `UUID`, NULL, FOREIGN KEY REFERENCES `teacher_profiles(id)` ON DELETE SET NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

### 6.4 `portfolio_items`
* **Purpose:** Generic portfolio entries (e.g. design link, blog post, published paper).
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `student_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `student_profiles(id)` ON DELETE CASCADE
  * `item_type`: `VARCHAR(50)`, NOT NULL, DEFAULT `'link'`
  * `title`: `VARCHAR(255)`, NOT NULL
  * `url`: `VARCHAR(500)`, NOT NULL
  * `description`: `TEXT`, NULL
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

---

## 7. Interview Domain Contracts (Transaction-Safe)

### 7.1 `interview_slots`
* **Purpose:** Recruiter calendar slots with strict timezone support.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `company_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `company_profiles(id)` ON DELETE CASCADE
  * `start_time`: `TIMESTAMPTZ`, NOT NULL
  * `end_time`: `TIMESTAMPTZ`, NOT NULL, CHECK (`end_time > start_time`)
  * `is_booked`: `BOOLEAN`, NOT NULL, DEFAULT `FALSE`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`

### 7.2 `interviews`
* **Purpose:** Confirmed bookings with double-booking prevention.
* **Columns:**
  * `id`: `UUID`, PRIMARY KEY, DEFAULT `gen_random_uuid()`
  * `application_id`: `UUID`, NOT NULL, FOREIGN KEY REFERENCES `applications(id)` ON DELETE CASCADE
  * `slot_id`: `UUID`, NOT NULL, UNIQUE, FOREIGN KEY REFERENCES `interview_slots(id)` ON DELETE RESTRICT
  * `scheduled_time`: `TIMESTAMPTZ`, NOT NULL
  * `meeting_url`: `VARCHAR(500)`, NULL
  * `status`: `VARCHAR(50)`, NOT NULL, DEFAULT `'scheduled'`
  * `created_at`: `TIMESTAMPTZ`, NOT NULL, DEFAULT `NOW()`
* **Integrity Constraints:**
  * `uq_interview_slot UNIQUE (slot_id)` -- Prevents double booking the same slot
  * `chk_interview_status CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled'))`

---

## 8. Supporting Systems Contracts

### 8.1 `feedback`
* **Columns:** `id UUID`, `application_id UUID`, `submitted_by_user_id UUID`, `rating SMALLINT (1-5)`, `technical_score SMALLINT (1-10)`, `communication_score SMALLINT (1-10)`, `strengths TEXT`, `improvements TEXT`, `created_at TIMESTAMPTZ`.
### 8.2 `notifications`
* **Columns:** `id UUID`, `user_id UUID`, `title VARCHAR(255)`, `message TEXT`, `is_read BOOLEAN DEFAULT FALSE`, `action_url VARCHAR(500)`, `created_at TIMESTAMPTZ`.
### 8.3 `audit_logs`
* **Columns:** `id BIGINT GENERATED ALWAYS AS IDENTITY`, `user_id UUID`, `action VARCHAR(100)`, `entity_name VARCHAR(100)`, `entity_id VARCHAR(100)`, `ip_address VARCHAR(45)`, `user_agent TEXT`, `details JSONB`, `created_at TIMESTAMPTZ`.

---

## 9. Student Learning Corner: Phase 2 Design Decisions

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is `BIGINT GENERATED ALWAYS AS IDENTITY` vs `UUID`?**  
> - We use **`UUID`** for records that are visible in browser URLs (`/api/applications/550e8400-e29b-41d4-a716-446655440000`). If we used simple numbers like `1`, `2`, `3`, an unauthorized user could easily guess the URL of another applicant's resume.
> - We use **`BIGINT GENERATED ALWAYS AS IDENTITY`** for internal audit trails like `application_status_history` and `audit_logs`. Why? Because audit logs are never exposed directly by ID, and integers require 8 bytes of storage (versus 16 bytes for UUID) and index faster during sequential bulk inserts.
> 
> **WHY do we store `parent_skill_id` in `skills`?**  
> In the real world, skills have hierarchy:
> `Programming` $\to$ `Python` $\to$ `FastAPI`.
> By adding `parent_skill_id UUID REFERENCES skills(id)`, a single table can represent trees of skills of any depth without needing separate tables for categories, sub-categories, and sub-sub-categories!
> 
> **HOW do we guarantee transaction-safe interview booking?**  
> If two students try to click "Book Slot 2:00 PM" at the exact same millisecond:
> 1. In SQL, we set `UNIQUE(slot_id)` on `interviews`.
> 2. In the backend API, the booking query uses:
>    ```sql
>    BEGIN;
>    SELECT * FROM interview_slots WHERE id = :slot_id AND is_booked = FALSE FOR UPDATE;
>    -- If available:
>    UPDATE interview_slots SET is_booked = TRUE WHERE id = :slot_id;
>    INSERT INTO interviews (application_id, slot_id, scheduled_time) VALUES (...);
>    COMMIT;
>    ```
> The `FOR UPDATE` lock forces PostgreSQL to pause the second student until the first transaction finishes, making double-booking physically impossible!
