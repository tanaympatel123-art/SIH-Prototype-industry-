# 06. Database Risk Assessment & Mitigation Strategies
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Database Security, Integrity, Scalability, and Logic Risks  
**Target Database:** PostgreSQL (v15+)  
**Author:** Database Architect & Engineer Team  
**Audience:** Development Team & Student Learners  

---

## 1. Risk Matrix Overview

In database engineering, bugs caught during planning cost \$1 to fix; bugs caught in production cost \$1,000+ and can lead to leaked student credentials, corrupted records, or legal penalties.

| Risk Category | Identified Risk | Impact Level | Likelihood | Primary Mitigation Strategy |
|---|---|---|---|---|
| **Security** | Plaintext password storage or weak hashing | **CRITICAL** | Low | Enforce Bcrypt / Argon2id at application level; zero plaintext columns. |
| **Security** | Insecure Direct Object References (IDOR) | **HIGH** | Medium | Use UUIDs instead of sequential IDs; enforce ownership queries (`WHERE user_id = :auth_id`). |
| **Security** | PII (Personally Identifiable Information) exposure | **HIGH** | Medium | Exclude phone, email, roll numbers from public API queries; implement Row-Level Security. |
| **Data Integrity** | Accidental cascading deletion of application history | **HIGH** | Low | Use `ON DELETE RESTRICT` on `opportunities -> applications`; use soft deletes. |
| **Data Integrity** | String inconsistency in status & proficiencies | **MEDIUM** | High | Use PostgreSQL `CHECK` constraints or native `ENUM` types for controlled vocabularies. |
| **Data Integrity** | Duplicate application submissions | **MEDIUM** | High | Unique composite index `UNIQUE(opportunity_id, student_id)`. |
| **Performance** | Missing indexes on foreign keys & filter columns | **HIGH** | High | Define explicit B-Tree indexes on all foreign key columns and active status flags. |
| **Performance** | N+1 query problem during candidate ranking | **HIGH** | High | Design normalized queries utilizing SQL `JOIN`s, aggregations, or database views. |
| **Business Logic** | Fraudulent companies posting fake internships | **HIGH** | Medium | Require admin verification flag (`verification_status = 'verified'`) before listings go public. |
| **Business Logic** | Fake skill endorsements / self-verification | **HIGH** | High | Restrict verification origin to authorized `teacher_profiles` or automated test engine. |

---

## 2. In-Depth Risk Analysis & Engineering Mitigations

### 2.1 Security & Access Control Risks

#### Risk SEC-01: Plaintext Passwords or Insecure Hashes
* **Vulnerability:** Storing passwords in cleartext or using outdated algorithms (MD5, SHA1, SHA256 without salt).
* **Impact:** A database backup leak compromises every user account on the portal.
* **Mitigation:**
  1. The `users.password_hash` column must strictly store salted hashes generated via **Argon2id** or **Bcrypt (cost factor $\ge 12$)**.
  2. The database user credentials used by the web server must possess least privilege (never connect as PostgreSQL `postgres` superuser in production).

#### Risk SEC-02: Insecure Direct Object Reference (IDOR)
* **Vulnerability:** If student resumes or applications use auto-incrementing integer IDs (`/api/resumes/12`), a malicious actor can write a script to scrape `/api/resumes/13`, `/api/resumes/14`, downloading every student's private resume.
* **Mitigation:**
  1. All public-facing entities (`users`, `student_profiles`, `resumes`, `applications`) use cryptographically random **UUIDv4** (`gen_random_uuid()`).
  2. All API queries must verify authorization context:
     ```sql
     -- Safe query: verifies ownership before returning resume
     SELECT * FROM resumes 
     WHERE id = :requested_resume_id 
       AND (student_id = :authenticated_student_id OR :is_company_recruiter = TRUE);
     ```

---

### 2.2 Data Integrity & Consistency Risks

#### Risk INT-01: Uncontrolled Cascading Deletes
* **Vulnerability:** Setting `ON DELETE CASCADE` across all foreign keys without analyzing business consequences.
* **Impact:** If a company recruiter deletes a draft opportunity, all student applications, interview records, and historical submissions linked to that opportunity could be erased instantly.
* **Mitigation:**
  1. Enforce `ON DELETE RESTRICT` on critical transaction tables:
     ```sql
     ALTER TABLE applications 
     ADD CONSTRAINT fk_applications_opportunity 
     FOREIGN KEY (opportunity_id) REFERENCES opportunities(id) ON DELETE RESTRICT;
     ```
  2. If a company wants to close an opportunity, update `status = 'closed'` instead of issuing a `DELETE` command.

#### Risk INT-02: Uncontrolled State Strings (String Typos)
* **Vulnerability:** Allowing freeform text in columns like `status` or `proficiency_level`. One developer writes `'shortlisted'`, another writes `'Shortlisted'`, another writes `'short_listed'`.
* **Impact:** Analytics, filters, and notification queries will fail or return incomplete results.
* **Mitigation:**
  Apply PostgreSQL `CHECK` constraints on all status columns:
  ```sql
  ALTER TABLE applications 
  ADD CONSTRAINT chk_application_status 
  CHECK (status IN ('applied', 'reviewing', 'shortlisted', 'interview_scheduled', 'offered', 'rejected', 'withdrawn'));
  ```

---

### 2.3 Performance & Scalability Risks

#### Risk PERF-01: The N+1 Query Problem in Applicant Lists
* **Vulnerability:** When a company views 100 applicants for an internship, an unoptimized ORM might run 1 query to fetch applicants, then 100 separate queries to fetch each student's profile, and another 100 queries to fetch each student's skills (Total = 201 queries).
* **Impact:** The database server's CPU spikes to 100%, and the dashboard takes 8 seconds to load.
* **Mitigation:**
  1. Use relational `JOIN` queries with JSON aggregation in PostgreSQL:
     ```sql
     SELECT 
       a.id AS application_id,
       a.match_score,
       sp.first_name,
       sp.last_name,
       sp.cgpa,
       json_agg(json_build_object('skill', s.name, 'level', ss.proficiency_level)) AS skills
     FROM applications a
     JOIN student_profiles sp ON a.student_id = sp.id
     JOIN student_skills ss ON ss.student_id = sp.id
     JOIN skills s ON s.id = ss.skill_id
     WHERE a.opportunity_id = :target_opportunity_id
     GROUP BY a.id, sp.first_name, sp.last_name, sp.cgpa;
     ```

#### Risk PERF-02: Missing Foreign Key Indexes
* **Vulnerability:** By default, PostgreSQL automatically creates indexes for **Primary Keys**, but does **NOT** automatically index **Foreign Key** columns!
* **Impact:** Every time PostgreSQL validates a foreign key or joins `student_skills` with `skills`, it must perform a sequential full-table scan.
* **Mitigation:**
  Create explicit B-Tree indexes on all foreign key columns and frequently filtered columns during the schema implementation phase.

---

## 3. Student Learning Corner: Preventing Architectural Failure

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is a Database Risk Assessment?**  
> A risk assessment is a pre-flight inspection where database architects predict every way data could be leaked, corrupted, deleted, or slowed down before writing any code.
> 
> **WHY do foreign keys need manual indexes in PostgreSQL?**  
> This is one of the most common surprises for junior developers:
> When you declare `PRIMARY KEY (id)`, PostgreSQL automatically creates a unique B-Tree index on `id`.
> But when you declare `FOREIGN KEY (user_id) REFERENCES users(id)`, PostgreSQL does **not** index `user_id`!
> If your `student_skills` table grows to 50,000 rows, running `SELECT * FROM student_skills WHERE student_id = '...'` will scan all 50,000 rows one by one unless you explicitly create:
> `CREATE INDEX idx_student_skills_student_id ON student_skills(student_id);`
> 
> **HOW does it apply to this project?**  
> Because our portal will display thousands of student applications and test scores, we will index all junction tables (`student_skills`, `opportunity_skills`, `applications`) in Phase 2 to ensure instant page loading for recruiters and students.
