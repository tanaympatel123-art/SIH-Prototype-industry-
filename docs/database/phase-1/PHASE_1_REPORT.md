# PHASE 1 REPORT — VALIDATE AND DEFINE
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Master Phase 1 Deliverable Report  
**Role:** Database Architect & Database Engineer  
**Database Target:** PostgreSQL (v15+)  

---

## Executive Summary

Phase 1 ("Validate and Define") for the SIH26044 Academia–Industry Collaboration Portal database architecture is now complete. During this phase, we completed an in-depth repository inspection, functional and technical requirement mapping across all five stakeholder groups (Students, Companies, Teachers, Institutions, Administrators), comprehensive entity cataloging, entity-relationship modeling, priority classification (P0–P3), risk assessment, security blueprinting, performance analysis, and a structured migration strategy.

No production tables or destructive migrations were executed, strictly preserving architectural integrity while laying a robust, student-friendly foundation for Phase 2.

---

## Section A: What Was Completed

1. **Repository Inspection:** Comprehensive inspection of the project workspace (`c:\Users\divya\Downloads\sih26044`) to identify existing code, models, ORM configs, or database scripts.
2. **End-to-End Workflow Mapping:** Systematically mapped all steps of the Student, Company, Teacher, and Institutional workflows to database operations and candidate entities.
3. **Entity Identification & Attribute Definition:** Evaluated 25+ database entities across 9 logical domains (Core, Skills, Assessment, Opportunities, Portfolio, Interviews, Learning, Collaboration, System) with detailed proposed attributes, primary keys, and data types.
4. **Relational Modeling & Cardinality:** Specified cardinality (1:1, 1:N, M:N), junction tables, foreign key constraints, and cascade behaviors (`CASCADE`, `RESTRICT`, `SET NULL`) with visual Mermaid diagrams.
5. **Priority Scoping (P0–P3):** Categorized all entities into strict delivery tiers to guarantee an agile, achievable Minimum Viable Product (MVP) for SIH.
6. **Architectural Assumptions:** Formulated standards for UUID primary keys, object storage for file uploads, UTC timestamps with timezone, currency representation, and soft deletes.
7. **Risk & Mitigation Assessment:** Documented security risks (IDOR, plaintext passwords, PII leakage), data integrity risks (uncontrolled cascades, status inconsistencies), and performance bottlenecks (N+1 queries, unindexed foreign keys).
8. **Migration Execution Plan:** Structured a 20-step migration sequence ordered according to a Directed Acyclic Graph (DAG) of foreign key dependencies.
9. **Documentation Suite Created:** Authored 7 dedicated architectural reference documents in `docs/database/phase-1/`.

---

## Section B: What Was Discovered

1. **Clean Greenfield Workspace:** Inspection confirmed that the current workspace `sih26044` is completely empty. There are no legacy SQL files, no existing ORM models (Prisma/Drizzle/TypeORM/SQLAlchemy), no Docker configs, and no pre-existing database migrations.
2. **Zero Conflicts:** Because there are no pre-existing schemas or conflicting database drivers, we have total freedom to implement clean, industry-standard PostgreSQL conventions from the ground up.
3. **Dynamic vs. Persistent Data Opportunities:** Requirements analysis revealed that certain features (such as "Skill Gap Analysis") do not require bloated persistent tables in the MVP; they can be computed dynamically through SQL set operations (`EXCEPT`, joins), drastically simplifying the early database footprint.
4. **Strict Integrity Needs for Hackathon Evaluation:** Recruiters and academic evaluators expect verified credentials. The relationship between `skills`, `student_skills`, and `skill_verifications` forms the core intellectual property of this SIH portal.

---

## Section C: What Database Entities Were Identified

The portal requires entities grouped across 9 functional domains:

* **CORE:**
  * `roles`: Role definitions for Role-Based Access Control (RBAC).
  * `institutions`: Accredited colleges, universities, and polytechnics.
  * `users`: Primary authentication accounts (email, password hash, role).
  * `student_profiles`: Academic and biographical data for students.
  * `company_profiles`: Corporate identity and employer verification details.
  * `teacher_profiles`: Faculty profile, department, and institutional designation.
* **SKILLS:**
  * `skill_categories`: Domains/categories of skills (e.g., Web, Data, AI, Soft Skills).
  * `skills`: Master canonical skill dictionary.
  * `student_skills`: Junction table linking students to skills with proficiency ratings.
  * `skill_verifications`: Audit trail of skill endorsements by faculty or test engines.
* **ASSESSMENT:**
  * `assessments`: Tests and quizzes for skill benchmarking.
  * `assessment_questions`: Question bank entries.
  * `assessment_options`: Multiple-choice options with correctness flags.
  * `assessment_attempts`: Student test sessions and scores.
  * `assessment_answers`: Recorded question-by-question student responses.
* **OPPORTUNITIES:**
  * `opportunities`: Job, internship, and project postings.
  * `opportunity_skills`: Required skills and minimum proficiencies per posting.
  * `applications`: Student job application submissions.
  * `application_status_history`: Historical log of application stage transitions.
* **PORTFOLIO:**
  * `resumes`: Metadata and URLs for uploaded student resumes.
  * `projects`: Academic, personal, and open-source projects showcased by students.
  * `certificates`: External course credentials uploaded for faculty endorsement.
* **INTERVIEWS:**
  * `interview_slots`: Recruiter calendar availability.
  * `interviews`: Scheduled candidate appointments with meeting links.
* **LEARNING:**
  * `learning_resources`: Curated tutorials and courses to bridge skill gaps.
  * `skill_gap_recommendations`: Cached mapping between gaps and resources.
* **COLLABORATION:**
  * `programs`: Faculty Development Programs (FDPs) and student workshops.
  * `mentorships`: Formal faculty-student mentorship tracking.
* **SYSTEM:**
  * `notifications`: Real-time and persistent alerts.
  * `feedback`: Post-interview ratings and qualitative feedback.
  * `audit_logs`: Security and administrative compliance trail.

---

## Section D: Why Each Major Entity Is Needed

1. **`users` vs. Profiles (`student_profiles`, `company_profiles`, `teacher_profiles`):**  
   Segregates universal authentication data from role-specific attributes. Avoids a single bloated table with dozens of empty `NULL` columns for irrelevant roles.
2. **`institutions`:**  
   Colleges are the anchor of academia-industry collaboration. All students and teachers must belong to an institution to enable NIRF/NAAC cohort analytics.
3. **`skills` & `skill_categories`:**  
   Standardizes skill names. Without this, one student writes "ReactJS", another writes "React.js", and an employer writes "React", breaking automated skill matching.
4. **`student_skills`:**  
   Resolves the Many-to-Many relationship between students and skills, storing the student's proficiency level and verified status.
5. **`opportunities` & `opportunity_skills`:**  
   Allows employers to define granular requirements (e.g., Python: Intermediate, PostgreSQL: Advanced) needed for candidate ranking.
6. **`applications`:**  
   Tracks candidate submissions, prevents duplicate applications via unique constraints, and caches computed match scores.
7. **`application_status_history`:**  
   Provides a transparent timeline for students to track their progress from "Applied" to "Interviewing" to "Offered".
8. **`skill_verifications`:**  
   Ensures academic integrity by logging which faculty member or automated quiz verified a student's claimed competence.

---

## Section E: How The Relationships Work

The architecture relies on strict relational modeling:

* **One-to-One (1:1):**
  * `users (1) <---> (1) student_profiles` (via `student_profiles.user_id UNIQUE`)
  * `users (1) <---> (1) company_profiles` (via `company_profiles.user_id UNIQUE`)
  * `users (1) <---> (1) teacher_profiles` (via `teacher_profiles.user_id UNIQUE`)
  * `applications (1) <---> (1) interviews`
* **One-to-Many (1:N):**
  * `roles (1) ----> (N) users`
  * `institutions (1) ----> (N) student_profiles`
  * `institutions (1) ----> (N) teacher_profiles`
  * `company_profiles (1) ----> (N) opportunities`
  * `opportunities (1) ----> (N) applications`
  * `student_profiles (1) ----> (N) applications`
  * `applications (1) ----> (N) application_status_history`
  * `student_skills (1) ----> (N) skill_verifications`
* **Many-to-Many (M:N) via Junction Tables:**
  * `student_profiles (M) <---> (N) skills` resolved via `student_skills`
  * `opportunities (M) <---> (N) skills` resolved via `opportunity_skills`

---

## Section F: Entity Prioritization (P0 / P1 / P2 / P3)

* **P0 (Essential MVP - 13 Tables):**  
  `roles`, `institutions`, `users`, `student_profiles`, `company_profiles`, `teacher_profiles`, `skill_categories`, `skills`, `student_skills`, `opportunities`, `opportunity_skills`, `applications`, `resumes`.  
  *Delivers the entire core user journey: signup, profile creation, job posting, skill matching, and application submission.*
* **P1 (Important - 9 Tables):**  
  `assessments`, `assessment_questions`, `assessment_options`, `assessment_attempts`, `skill_verifications`, `application_status_history`, `interview_slots`, `interviews`, `feedback`, `notifications`, `audit_logs`.  
  *Adds automated quizzes, faculty verification, interview scheduling, and notifications.*
* **P2 (Optional / Post-MVP - 6 Tables):**  
  `projects`, `certificates`, `learning_resources`, `skill_gap_recommendations`, `assessment_answers`, `programs`, `mentorships`.  
  *Provides portfolio showcases, curated learning modules, and formal mentorship tracking.*
* **P3 (Future Expansion):**  
  `consultancy_projects`, `alumni_networks`, `ai_resume_embeddings`.  
  *Enterprise scaling, vector search for AI matching, and commercial research partnerships.*

---

## Section G: What Migration Order Was Chosen

The 20-step migration sequence follows a strict **Directed Acyclic Graph (DAG)** where no child table is created before its parent foreign keys exist:

1. `001_init_extensions_and_enums.sql` (UUID extensions, status ENUMs)
2. `002_create_roles_and_institutions.sql` (Independent lookup tables)
3. `003_create_users.sql` (Depends on roles)
4. `004_create_student_profiles.sql` (Depends on users, institutions)
5. `005_create_company_profiles.sql` (Depends on users)
6. `006_create_teacher_profiles.sql` (Depends on users, institutions)
7. `007_create_skill_categories.sql` (Independent taxonomy headers)
8. `008_create_skills.sql` (Depends on skill_categories)
9. `009_create_student_skills.sql` (Depends on student_profiles, skills)
10. `010_create_skill_verifications.sql` (Depends on student_skills, teacher_profiles)
11. `011_create_opportunities.sql` (Depends on company_profiles)
12. `012_create_opportunity_skills.sql` (Depends on opportunities, skills)
13. `013_create_resumes_and_portfolio.sql` (Depends on student_profiles)
14. `014_create_applications.sql` (Depends on student_profiles, opportunities, resumes)
15. `015_create_application_status_history.sql` (Depends on applications)
16. `016_create_interview_slots.sql` (Depends on company_profiles)
17. `017_create_interviews.sql` (Depends on applications, interview_slots)
18. `018_create_assessments_and_questions.sql` (Depends on skills)
19. `019_create_assessment_attempts.sql` (Depends on student_profiles, assessments)
20. `020_create_notifications_and_audit_logs.sql` (Depends on users)

---

## Section H: What Security Issues Were Identified

1. **Password Protection:** Plaintext passwords are prohibited. Must use salted Argon2id or Bcrypt with work factor $\ge 12$.
2. **IDOR (Insecure Direct Object Reference):** Sequential integer IDs in public APIs expose candidate data. All student and application records will use cryptographically generated UUIDv4.
3. **Private Document Exposure:** Student resumes and transcripts must not be stored in publicly accessible folders. The database stores signed URLs or identifiers linking to protected cloud storage buckets.
4. **Company Verification:** Unverified companies must not be allowed to publish active job postings without admin verification (`verification_status = 'verified'`) to protect students from recruitment fraud.
5. **Audit Logging:** Administrative actions (changing roles, manually verifying skills) must be recorded in an immutable `audit_logs` table.

---

## Section I: What Performance Issues Were Identified

1. **Missing Foreign Key Indexes:** PostgreSQL does not automatically index foreign keys. Without explicit indexes on `student_skills(student_id)`, `opportunity_skills(opportunity_id)`, and `applications(opportunity_id)`, join operations will trigger costly full-table scans.
2. **N+1 Query Bottlenecks:** Displaying 100 applicants on a company dashboard could trigger 200+ separate SQL queries if poorly implemented in an ORM. Relational joins with PostgreSQL `json_agg()` will be used to fetch candidates and their skills in a single round-trip.
3. **High-Frequency Candidate Ranking:** Composite indexes on `(opportunity_id, match_score DESC)` are planned to allow instant rendering of ranked applicant leaderboards.
4. **Full-Text Job Search:** Standard `LIKE '%query%'` queries will degrade under high traffic. PostgreSQL GIN (Generalized Inverted Index) full-text search is recommended for opportunity searching.

---

## Section J: What Assumptions Were Made

1. **Engine:** PostgreSQL 15+ running with UTC time standard (`TIMESTAMPTZ`).
2. **File Storage:** PostgreSQL stores only file metadata and URLs; actual files (PDFs, images) live in external object storage (AWS S3, MinIO, Cloudflare R2).
3. **Multi-Tenancy:** Single shared database with logical multi-tenancy enforced by foreign keys (`institution_id`) and application-level RBAC.
4. **Currencies:** Stored as `NUMERIC(10, 2)` defaulting to `'INR'`.
5. **Deletion Policy:** Soft deletion for applications, opportunities, and user accounts to prevent loss of audit history.

---

## Section K: What Files Were Created

All documentation has been organized into `docs/database/phase-1/`:

1. [01_database_requirements.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/01_database_requirements.md) — Workflow-to-database requirement mappings and student concept explanations.
2. [02_database_entities.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/02_database_entities.md) — Complete 25+ entity catalog, attributes, types, constraints, and keys.
3. [03_database_relationships.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/03_database_relationships.md) — Cardinality specifications, cascade behaviors, and Mermaid ER diagrams.
4. [04_database_priorities.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/04_database_priorities.md) — Entity classification into P0, P1, P2, P3 with architectural justifications.
5. [05_database_assumptions.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/05_database_assumptions.md) — Technical, storage, timezone, and business assumptions.
6. [06_database_risks.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/06_database_risks.md) — Security, integrity, scalability, and logic risk matrix with mitigations.
7. [07_database_implementation_plan.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/07_database_implementation_plan.md) — 20-step migration order, DAG explanation, naming conventions, and indexing roadmap.
8. [PHASE_1_REPORT.md](file:///c:/Users/divya/Downloads/sih26044/docs/database/phase-1/PHASE_1_REPORT.md) — This master phase summary report.

---

## Section L: What Existing Files Were Inspected

* Inspected root directory `c:\Users\divya\Downloads\sih26044`.
* Inspected recursive file patterns matching backend, frontend, SQL, migrations, ORM, and environment variables.
* **Finding:** Directory is currently empty (greenfield initialization). No existing files were modified or deleted.

---

## Section M: What Was NOT Implemented

In strict compliance with Phase 1 instructions:
1. **No production tables were created:** No `CREATE TABLE` DDL was executed against a live PostgreSQL server.
2. **No migration files were generated:** Proposed migration files were outlined and ordered, but raw `.sql` or ORM migration scripts were not generated.
3. **No application code was written:** No backend controllers, API routes, or frontend components were added.
4. **No mock data was inserted:** No seed data was generated.

---

## Section N: What Phase 2 Will Do

When authorized by the user, **Phase 2 (Schema Design & Baseline DDL Implementation)** will:
1. Initialize the project's ORM or migration framework (e.g., Prisma, Drizzle, or raw SQL migrations).
2. Generate executable, idempotent DDL scripts for all **P0 entities** (`roles`, `institutions`, `users`, `student_profiles`, `company_profiles`, `teacher_profiles`, `skill_categories`, `skills`, `student_skills`, `opportunities`, `opportunity_skills`, `applications`, `resumes`).
3. Define exact column types, check constraints, foreign keys, and indexes in code.
4. Create initial seed scripts for master lookup data (`roles`, `institutions`, `skill_categories`, `skills`).
5. Verify schema generation against a live or containerized PostgreSQL instance.

---

## Student Learning Summary: Essential Database Concepts

For our student learner, here is the quick-reference breakdown of key concepts mastered in this phase:

```
┌─────────────────────────┬────────────────────────────────────────────────────────────────────────────┐
│ Concept                 │ Practical Meaning & Application in SIH26044                                │
├─────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
│ Entity                  │ A real-world object we store data about (e.g. Student, Company, Skill).    │
│ Primary Key (PK)        │ Unique ID (UUID) ensuring no two records collide.                         │
│ Foreign Key (FK)        │ A column referencing another table's PK to create a relational link.       │
│ Cardinality             │ The numerical relationship between tables (1:1, 1:N, or M:N).             │
│ Junction Table          │ Middle table needed to connect Many-to-Many entities (e.g. student_skills).│
│ Cascade Rules           │ Rules deciding what happens to child records when a parent record is cut.  │
│ Directed Acyclic Graph  │ The parent-first order required so foreign keys don't fail during migration│
│ Index                   │ A lookup tree (B-Tree) that prevents slow full-table scans during search.  │
│ Soft Delete             │ Setting is_active = FALSE instead of deleting rows, preserving history.   │
└─────────────────────────┴────────────────────────────────────────────────────────────────────────────┘
```

---

## Final Status

```
PHASE: 1
STATUS: COMPLETED

FILES CREATED:
- docs/database/phase-1/01_database_requirements.md
- docs/database/phase-1/02_database_entities.md
- docs/database/phase-1/03_database_relationships.md
- docs/database/phase-1/04_database_priorities.md
- docs/database/phase-1/05_database_assumptions.md
- docs/database/phase-1/06_database_risks.md
- docs/database/phase-1/07_database_implementation_plan.md
- docs/database/phase-1/PHASE_1_REPORT.md

FILES MODIFIED:
None (workspace was inspected and confirmed empty; greenfield project).

IMPORTANT DECISIONS:
1. Target database standardized on PostgreSQL 15+ with UTC TIMESTAMPTZ and UUIDv4 primary keys.
2. Segregated universal authentication (users) from role-specific profiles (student_profiles, company_profiles, teacher_profiles).
3. Classified entities into P0 (13 tables for MVP), P1 (important), P2 (optional), and P3 (future).
4. Standardized on external object storage for files (resumes, certificates) with database storing URLs and metadata only.
5. Established a strict 20-step migration DAG ensuring foreign key dependencies are never violated.

KNOWN ISSUES:
None.

READY FOR PHASE 2:
YES

DO NOT START PHASE 2.
STOP.
```
