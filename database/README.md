# SIH26044 — Database Foundation (Phase 1 & 2)
**Project:** Academia–Industry Collaboration Portal  
**Role:** M3 – Database Manager  
**Database Technology:** MySQL 8.x / MariaDB (XAMPP & phpMyAdmin compatible)  
**Storage Engine:** InnoDB | **Encoding:** `utf8mb4` | **Collation:** `utf8mb4_unicode_ci`  

---

## Phase 2 Stats

| Metric | Phase 1 | Phase 2 (Added) | Total |
|--------|---------|-----------------|-------|
| Students | 3 | 30 | 33 |
| Companies | 2 | 5 | 7 |
| Teachers | 2 | 3 | 5 |
| Opportunities | 2 | 15 | 17 |
| Skills | 15 | 15 | 30 |
| Applications | 5 | 45 | 50 |
| Stored Procedures | 0 | 2 | 2 |
| Compound Indexes | 0 | 5 | 5 |
| New Tables | 0 | 1 (`application_status_history`) | 12 |

---

## 1. Project Directory Structure

```text
database/
├── README.md                           # Master Database Documentation & Deployment Guide
├── schema/                             # Modular DDL Schema Definitions (MySQL 8.x)
│   ├── 01_create_database.sql          # Database initialization (utf8mb4)
│   ├── 02_roles.sql                    # System roles (RBAC master)
│   ├── 03_users.sql                    # Root authentication & user identity
│   ├── 04_profiles.sql                 # Student, Company, and Teacher profiles (1:1 with users)
│   ├── 05_skills.sql                   # Master skill taxonomy (with self-referencing parent)
│   ├── 06_student_skills.sql           # Student skills junction (with provenance & verification)
│   ├── 07_skill_verifications.sql      # Teacher verification audit trail
│   ├── 08_opportunities.sql            # Corporate internship and job postings
│   ├── 09_opportunity_skills.sql       # Opportunity skill requirements junction
│   ├── 10_applications.sql             # Student application submissions & ATS pipeline
│   └── all_in_one_phase1.sql           # Complete all-in-one schema runner (for 1-click import)
├── migrations/
│   ├── 001-013_*.sql                   # Legacy PostgreSQL prototypes (archival reference only)
│   ├── 014_phase2_stored_procedures.sql# Phase 2: sp_approve_skill_verification, sp_update_application_status
│   └── 015_phase2_indexes.sql          # Phase 2: 5 compound/covering indexes for MatchScore Engine
├── seeds/
│   ├── phase1_seed.sql                 # Phase 1: 3 students, 2 companies, 14 skills
│   └── phase2_expanded_seed.sql        # Phase 2: 30 students, 5 companies, 15 opps, 45 applications
├── queries/
│   ├── phase1_test_queries.sql         # Phase 1: Functional verification & analytics queries (8 queries)
│   └── phase2_benchmark_queries.sql    # Phase 2: EXPLAIN ANALYZE proofs for 4 query patterns
├── run_phase1_mysql.sql                # Phase 1: 1-click runner
├── run_phase2_mysql.sql                # Phase 2: 1-click runner
└── backups/                            # Reserved for mysqldump exports (.sql)
```

> **Note on Existing Legacy Migrations:**  
> The `database/migrations/` directory contains legacy prototypes written for PostgreSQL (utilizing PostgreSQL-specific extensions like `pgcrypto`, `gen_random_uuid()`, and `TIMESTAMPTZ`). These are retained for archival reference, while the **canonical, production-ready MySQL 8.x implementation** resides strictly in `database/schema/`.

---

## 2. Core Entities Implemented in Phase 1

| # | Entity Name | Table Type | Primary Key | Key Relationships |
|---|---|---|---|---|
| 1 | `roles` | Master / Lookup | `id` (TINYINT UNSIGNED) | Referenced by `users.role_id` |
| 2 | `users` | Root Auth | `id` (BIGINT UNSIGNED) | `roles(id)` |
| 3 | `student_profiles` | 1:1 Profile | `id` (BIGINT UNSIGNED) | `users(id)` (CASCADE) |
| 4 | `company_profiles` | 1:1 Profile | `id` (BIGINT UNSIGNED) | `users(id)` (CASCADE) |
| 5 | `teacher_profiles` | 1:1 Profile | `id` (BIGINT UNSIGNED) | `users(id)` (CASCADE) |
| 6 | `skills` | Master Taxonomy | `id` (INT UNSIGNED) | Self-reference `parent_skill_id` -> `skills(id)` |
| 7 | `student_skills` | M:N Junction | `id` (BIGINT UNSIGNED) | `student_profiles(id)`, `skills(id)` |
| 8 | `skill_verifications`| Audit Trail | `id` (BIGINT UNSIGNED) | `student_skills(id)`, `teacher_profiles(id)` |
| 9 | `opportunities` | Entity | `id` (BIGINT UNSIGNED) | `company_profiles(id)` |
| 10| `opportunity_skills`| M:N Junction | `id` (BIGINT UNSIGNED) | `opportunities(id)`, `skills(id)` |
| 11| `applications` | M:N Junction | `id` (BIGINT UNSIGNED) | `student_profiles(id)`, `opportunities(id)` |

---

## 3. Key Architectural Decisions

### A. Normalized Role Storage (`users.role_id`)
- **Decision:** A direct foreign key `role_id` on the `users` table was chosen rather than a separate `user_roles` junction table.
- **Rationale:** In the SIH portal ecosystem, an actor logs in under a single primary persona (Student, Company Recruiter, Teacher, or Admin). Each persona maps directly to exactly one specialized profile table. A normalized direct foreign key avoids role-switching ambiguity, eliminates JOIN overhead during JWT/session authentication, and ensures profile uniqueness.

### B. Hierarchical Master Skills Taxonomy (`parent_skill_id`)
- **Decision:** Implemented a self-referencing foreign key on `skills(parent_skill_id)`.
- **Rationale:** Skills in computer science and industry form semantic parent-child trees (e.g., `SQL` -> `MySQL`, `JavaScript` -> `React` / `Angular`, `Machine Learning` -> `Deep Learning`). A self-referencing relationship enables skill inheritance (knowing a specialized framework implies foundational knowledge) and category roll-ups.

### C. Integrity Rule: AI-Extracted vs. Teacher-Verified
- **Decision:** The `student_skills` table incorporates both a `source` ENUM (`'self_declared'`, `'quiz'`, `'project'`, `'certificate'`, `'teacher_verified'`, `'ai_extracted'`) and an `is_verified` boolean.
- **Rationale:** When an AI resume parser extracts skills, `source` is set to `'ai_extracted'` while `is_verified` remains strictly `FALSE`. Only an authorized faculty member can approve the skill via the `skill_verifications` table, transitioning `is_verified` to `TRUE`.

### D. Single Application Constraint
- **Decision:** Unique constraint on `applications(student_id, opportunity_id)`.
- **Rationale:** Guarantees that a student cannot submit duplicate applications to the same opportunity posting, preventing spam and maintaining clean ATS pipeline states.

---

## 4. Index Design & Rationale

| Table | Index Name | Indexed Column(s) | Architectural Rationale |
|---|---|---|---|
| `users` | `idx_users_email` | `email` | Primary authentication lookup key; guarantees O(1) login resolution. |
| `users` | `idx_users_role_id` | `role_id` | Efficient filtering of users by stakeholder role in administrative queries. |
| `student_profiles` | `idx_student_profiles_user_id` | `user_id` | Accelerates 1:1 join between authenticated session and student profile. |
| `student_profiles` | `idx_student_profiles_institution`| `institution` | Fast filtering for institutional cohort reporting and campus recruitment. |
| `company_profiles` | `idx_company_profiles_user_id` | `user_id` | Accelerates 1:1 join for company recruiter sessions. |
| `teacher_profiles` | `idx_teacher_profiles_user_id` | `user_id` | Accelerates 1:1 join for faculty portal sessions. |
| `skills` | `idx_skills_category` | `category` | Grouping and browsing skills by category in student profile editors. |
| `skills` | `idx_skills_parent_id` | `parent_skill_id` | Optimizes recursive taxonomy traversal queries. |
| `student_skills` | `idx_student_skills_student_id`| `student_id` | Instant retrieval of a student's entire skill portfolio. |
| `student_skills` | `idx_student_skills_skill_id` | `skill_id` | Powers search for students possessing a specific skill. |
| `student_skills` | `idx_student_skills_is_verified`| `is_verified` | Quickly isolates verified vs unverified claims for recruiter ranking. |
| `skill_verifications` | `idx_verifications_student_skill` | `student_skill_id` | Fetches verification history for a given student skill claim. |
| `skill_verifications` | `idx_verifications_teacher` | `verifier_teacher_id` | Powers the faculty dashboard to list tasks assigned to a teacher. |
| `skill_verifications` | `idx_verifications_status` | `verification_status` | Fast retrieval of the `pending` queue for faculty action. |
| `opportunities` | `idx_opportunities_company_id` | `company_id` | Powers company job posting management dashboard. |
| `opportunities` | `idx_opportunities_status` | `status` | Filters active (`published`) opportunities for the student job board. |
| `opportunities` | `idx_opportunities_deadline` | `application_deadline` | Allows sorting opportunities by upcoming application cutoffs. |
| `opportunity_skills` | `idx_opportunity_skills_opp_id` | `opportunity_id` | Fetches all required and optional skills for an opportunity. |
| `opportunity_skills` | `idx_opportunity_skills_skill_id` | `skill_id` | Enables candidate-opportunity matching engine. |
| `applications` | `idx_applications_student_id` | `student_id` | Powers the student "My Applications" dashboard. |
| `applications` | `idx_applications_opportunity_id`| `opportunity_id` | Powers the company ATS candidate screening pipeline. |
| `applications` | `idx_applications_status` | `application_status` | Quick filtering by application stage (`applied`, `shortlisted`, etc.). |

---

## 5. Deployment Instructions (XAMPP & phpMyAdmin)

### Option A: 1-Click Import via phpMyAdmin
1. Start **Apache** and **MySQL** in the **XAMPP Control Panel**.
2. Open your web browser and navigate to `http://localhost/phpmyadmin`.
3. In the top navigation bar, click **Import**.
4. Click **Choose File** and select:
   ```text
   database/schema/all_in_one_phase1.sql
   ```
5. Scroll to the bottom and click **Import** (or **Go**).
6. Next, repeat the import step with the demonstration seed file:
   ```text
   database/seeds/phase1_seed.sql
   ```
7. All 11 tables and sample records are now initialized and ready.

### Option B: Command Line via MySQL CLI
From PowerShell or Command Prompt:

```powershell
# 1. Navigate to project root
cd c:\Users\divya\Downloads\sih26044

# 2. Execute all-in-one schema
C:\xampp\mysql\bin\mysql.exe -u root < database\schema\all_in_one_phase1.sql

# 3. Execute seed data
C:\xampp\mysql\bin\mysql.exe -u root < database\seeds\phase1_seed.sql

# 4. Execute test verification queries
C:\xampp\mysql\bin\mysql.exe -u root < database\queries\phase1_test_queries.sql
```

---

## 6. Demonstration Seed Data Summary

- **Users & Credentials:** All sample accounts share the development password `password123` (stored as a secure bcrypt hash).
  - Students: `aarav.sharma@dtu.ac.in`, `priya.patel@dtu.ac.in`, `rohan.mehta@iitb.ac.in`
  - Companies: `recruitment@techcorp.in`, `talent@innovateai.com`
  - Teachers: `dr.verma@dtu.ac.in`, `ananya.roy@iitb.ac.in`
  - Admin: `admin@sih26044.gov.in`
- **Master Skills:** 14 skills covering Web, AI, Databases, and Core CS with hierarchical parent relationships.
- **Opportunities:**
  1. *Python Developer Intern* (TechCorp India, Remote, ₹25k/mo)
  2. *Web Developer Intern* (TechCorp India, Hybrid, ₹22k/mo)
  3. *Data Analyst Intern* (Innovate AI Systems, Onsite, ₹30k/mo)
- **Recruitment Applications:** 5 candidate applications across multiple recruitment stages (`applied`, `shortlisted`, `interview`, `selected`).
- **Teacher Endorsements:** Real audit entries illustrating `approved`, `pending`, and `rejected` statuses with teacher remarks and evidence links.

---

## 7. Phase 2 — Deployment Instructions

### Option A: 1-Click Runner (phpMyAdmin)
1. Ensure Phase 1 is already loaded (`all_in_one_phase1.sql` + `phase1_seed.sql`).
2. In phpMyAdmin, open the **SQL tab**.
3. Import `database/migrations/014_phase2_stored_procedures.sql`
4. Import `database/migrations/015_phase2_indexes.sql`
5. Import `database/seeds/phase2_expanded_seed.sql`
6. Import `database/queries/phase2_benchmark_queries.sql` to verify EXPLAIN output.

### Option B: MySQL CLI (recommended for full runner)
```powershell
# From project root — run after Phase 1 is loaded
C:\xampp\mysql\bin\mysql.exe -u root sih26044_db `
    < database/migrations/014_phase2_stored_procedures.sql

C:\xampp\mysql\bin\mysql.exe -u root sih26044_db `
    < database/migrations/015_phase2_indexes.sql

C:\xampp\mysql\bin\mysql.exe -u root sih26044_db `
    < database/seeds/phase2_expanded_seed.sql

C:\xampp\mysql\bin\mysql.exe -u root sih26044_db `
    < database/queries/phase2_benchmark_queries.sql
```

---

## 8. Using Stored Procedures

### `sp_approve_skill_verification` — Teacher approves a skill claim
```sql
-- Approve verification ID 1 by Teacher 1 (Dr. Rajesh Verma)
CALL sp_approve_skill_verification(1, 1, 'Excellent project submission. Verified.');
-- Returns: result_status, verification_id, student_id, skill_now_verified, updated_completion_pct
```

### `sp_update_application_status` — Move an application through the pipeline
```sql
-- Shortlist application ID 1 (recruiter user_id = 5)
CALL sp_update_application_status(1, 'shortlisted', 'Strong Python profile.', 5);

-- Schedule interview
CALL sp_update_application_status(1, 'interview', 'Technical round booked for 2025-08-10.', 5);

-- Final selection
CALL sp_update_application_status(1, 'selected', 'Offer extended.', 5);

-- Attempting invalid transition (selected → applied) will SIGNAL an error:
-- ERROR 1644: ERROR: Application is in a terminal state. No further transitions allowed.
```

**Valid State Transitions:**
```
applied  →  shortlisted | rejected | withdrawn
shortlisted  →  interview | rejected | withdrawn
interview  →  selected | rejected | withdrawn
selected / rejected / withdrawn  →  (TERMINAL — no further transitions)
```

---

## 9. Phase 2 Compound Indexes Summary

| Index Name | Table | Columns | Purpose |
|---|---|---|---|
| `idx_ss_student_verified_proficiency` | `student_skills` | `(student_id, is_verified, proficiency_level, skill_id)` | MatchScore: verified skills per student |
| `idx_os_opportunity_mandatory_skill` | `opportunity_skills` | `(opportunity_id, is_mandatory, skill_id, required_proficiency_level)` | MatchScore: mandatory skills per opportunity |
| `idx_app_opportunity_status_student` | `applications` | `(opportunity_id, application_status, student_id)` | Recruiter ATS pipeline sorted by stage |
| `idx_sv_teacher_status_skill` | `skill_verifications` | `(verifier_teacher_id, verification_status, student_skill_id)` | Teacher pending workqueue |
| `idx_opp_status_deadline_company` | `opportunities` | `(status, application_deadline, company_id)` | Student job board deadline-sorted discovery |
