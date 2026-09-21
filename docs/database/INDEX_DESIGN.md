# Formal Database Indexing Strategy & Plan
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Query Workload Analysis, Index Specifications & Performance Tuning  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  

---

## 1. Executive Indexing Philosophy

An unindexed database crawls under load; an over-indexed database chokes on write operations. In PostgreSQL:
* **Every index has a write cost:** Every `INSERT`, `UPDATE`, and `DELETE` must update both the physical table heap and all associated B-Tree index pages.
* **Foreign Keys are NOT automatically indexed:** PostgreSQL automatically creates a unique index on `PRIMARY KEY` and `UNIQUE` constraints, but leaves foreign keys unindexed unless explicitly defined.

Our index plan targets **hot query paths**: authentication, candidate matching, opportunity filtering, and applicant ranking.

---

## 2. Core Workload & Index Specifications

### 2.1 Identity & Authentication (`users`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `uq_users_email` | `users` | `email` | Unique B-Tree | `SELECT * FROM users WHERE email = :email;` | Enforces uniqueness of user login credentials and provides $O(\log N)$ instantaneous authentication lookup. |
| `idx_users_role_id`| `users` | `role_id` | B-Tree | `SELECT * FROM users WHERE role_id = :role_id;` | Filter queries for platform administrators viewing user rosters by role. |

---

### 2.2 Student & Institutional Queries (`student_profiles`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `idx_student_profiles_user_id` | `student_profiles` | `user_id` | Unique B-Tree | `SELECT * FROM student_profiles WHERE user_id = :auth_id;` | Hot path: Executed on every student login to load their profile dashboard. |
| `idx_student_profiles_inst` | `student_profiles` | `institution_id` | B-Tree | `SELECT * FROM student_profiles WHERE institution_id = :college_id;` | Supports institutional administration tracking student cohorts and NAAC accreditation metrics. |

---

### 2.3 Skill Matching Engine (`student_skills` & `opportunity_skills`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `idx_student_skills_student` | `student_skills` | `student_id` | B-Tree | `SELECT * FROM student_skills WHERE student_id = :student_id;` | High-frequency query loading student profile radar charts and evaluating job fit. |
| `idx_student_skills_skill` | `student_skills` | `skill_id` | B-Tree | `SELECT student_id FROM student_skills WHERE skill_id = :target_skill;` | Used by corporate recruiters searching for candidates with specific technical skills. |
| `idx_opp_skills_opp_id` | `opportunity_skills`| `opportunity_id`| B-Tree | `SELECT * FROM opportunity_skills WHERE opportunity_id = :opp_id;` | High frequency: Executed every time an internship details page is loaded. |
| `idx_opp_skills_skill_id` | `opportunity_skills`| `skill_id` | B-Tree | `SELECT opportunity_id FROM opportunity_skills WHERE skill_id = :skill_id;` | Used by students filtering job listings by their top skills. |

---

### 2.4 Opportunity Discovery & Filtering (`opportunities`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `idx_opps_company_id` | `opportunities` | `company_id` | B-Tree | `SELECT * FROM opportunities WHERE company_id = :company_id;` | Used on company dashboard to manage all published internship postings. |
| `idx_opps_active_deadline`| `opportunities` | `(status, application_deadline DESC)` | Composite B-Tree | `SELECT * FROM opportunities WHERE status = 'active' AND application_deadline > NOW() ORDER BY application_deadline;` | **Hot path for landing page & student browse:** Avoids sorting in memory by indexing status and deadline together. |
| `idx_opps_fulltext` | `opportunities` | `to_tsvector('english', title \|\| ' ' \|\| description)` | GIN (Generalized Inverted Index) | `SELECT * FROM opportunities WHERE to_tsvector('english', title \|\| ' ' \|\| description) @@ to_tsquery('english', :search_query);` | Provides sub-millisecond keyword search across job titles and descriptions without slow `LIKE '%...%'` wildcards. |

---

### 2.5 Application Intake & Candidate Ranking (`applications`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `idx_apps_student_id` | `applications` | `student_id` | B-Tree | `SELECT * FROM applications WHERE student_id = :student_id;` | Used on Student Dashboard: "My Applications" tab to display application status. |
| `idx_apps_opp_match` | `applications` | `(opportunity_id, match_score DESC)` | Composite B-Tree | `SELECT * FROM applications WHERE opportunity_id = :opp_id ORDER BY match_score DESC;` | **Hot path for Recruiter Leaderboard:** Instantly retrieves ranked applicants by skill match without sorting millions of rows. |
| `idx_apps_status` | `applications` | `(opportunity_id, status)` | Composite B-Tree | `SELECT * FROM applications WHERE opportunity_id = :opp_id AND status = 'SHORTLISTED';` | Recruiter filtering applicants by recruitment stage. |

---

### 2.6 Academic Verification (`skill_verifications`)

| Index Name | Table | Columns | Index Type | Query Pattern Optimized | Architectural Justification |
|---|---|---|---|---|---|
| `idx_verif_student_skill`| `skill_verifications` | `student_skill_id` | B-Tree | `SELECT * FROM skill_verifications WHERE student_skill_id = :skill_id;` | Displays badge history and verification certificates on student profile. |
| `idx_verif_teacher_id` | `skill_verifications` | `verifier_teacher_id` | B-Tree | `SELECT * FROM skill_verifications WHERE verifier_teacher_id = :teacher_id;` | Faculty dashboard: "My Verified Students" view for institutional credit and reporting. |

---

## 3. Indexes NOT Created (Anti-Patterns Avoided)

1. **No Index on Low-Cardinality Booleans:** We do **not** create a standalone B-Tree index on `is_verified` or `is_active` alone. When a column only has two possible values (`TRUE`/`FALSE`), PostgreSQL's query planner will ignore the index and perform a table scan anyway.
2. **No Unbounded Text Indexes:** We do **not** create B-Tree indexes on large `TEXT` columns like `description` or `cover_letter`. For text search, we use PostgreSQL **GIN** full-text indexes.
3. **No Duplicate Single-Column Indexes when Composite Exists:** Because `idx_apps_opp_match` covers `(opportunity_id, match_score DESC)`, PostgreSQL can use the leading column (`opportunity_id`) for single-column searches, eliminating the need for a separate index on `opportunity_id` alone!

---

## 4. Student Learning Corner: B-Tree vs Composite vs GIN

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is a Composite Index and the "Leftmost Prefix" Rule?**  
> A Composite Index is an index on **two or more columns**, e.g., `(opportunity_id, match_score DESC)`.
> PostgreSQL creates a tree sorted first by `opportunity_id`, and then within each opportunity, sorted by `match_score` descending.
> Because `opportunity_id` is on the **left**, any query filtering by `WHERE opportunity_id = '...'` will automatically use this index! You do not need to create two separate indexes.
> 
> **WHY do we use a GIN index instead of `LIKE '%developer%'`?**  
> When you write `WHERE title LIKE '%developer%'`, PostgreSQL must examine every single character of every single job title in your database (a full table scan).  
> A **GIN (Generalized Inverted Index)** breaks your text into distinct words ("developer", "python", "backend") and creates a direct dictionary pointer. Searching 1,000,000 opportunities takes under 2 milliseconds!
