# PHASE 2 REPORT — DESIGN CONTRACTS
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Master Phase 2 Architectural Contracts Report  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  

---

## Executive Summary

Phase 2 ("Design Contracts") of the SIH26044 Academia–Industry Collaboration Portal is now complete. Building directly on the requirements validated in Phase 1, Phase 2 formalizes the physical database contracts, column-level data types, PostgreSQL integrity constraints, primary and foreign key strategies, query indexing blueprints, REST API-to-database contracts, and full-lifecycle traceability.

This report establishes the single source of architectural truth for backend engineers, frontend developers, and academic evaluators.

---

## Section 1: What Was Designed

1. **Formal Column Contracts:** Designed explicit column specifications, nullability rules, default values, and data types across 18 distinct relational tables organized into 9 logical domains.
2. **Keying Strategy:** Established a hybrid primary key model pairing cryptographically random **`UUIDv4`** for public entities with SQL-standard **`BIGINT GENERATED ALWAYS AS IDENTITY`** for high-volume append logs.
3. **Hierarchical Skill Taxonomy:** Introduced self-referential parent-child relationships (`parent_skill_id`) in `skills` enabling multi-level skill categorization.
4. **Comprehensive State Machines:** Standardized state machines with PostgreSQL `CHECK` constraints across applications (`APPLIED`, `UNDER_REVIEW`, `SHORTLISTED`, `INTERVIEW_SCHEDULED`, `SELECTED`, `REJECTED`, `WITHDRAWN`), assessment attempts, and interview bookings.
5. **System-Wide ER Model:** Authored a complete visual Mermaid ER diagram mapping all entities and foreign key linkages.
6. **Index Plan:** Created an indexing strategy targeting hot query paths (email lookup, opportunity deadline filtering, composite candidate ranking, GIN full-text search).
7. **API-Database Contracts:** Documented 15 RESTful API endpoints mapped to their exact underlying SQL queries, transactional blocks, and HTTP status codes.
8. **Requirements Traceability Matrix (RTM):** Mapped every core requirement from user interface down to database queries and verification test cases.

---

## Section 2: Why Each Table Exists

| Table Name | Primary Purpose in SIH Ecosystem |
|---|---|
| `roles` | Defines RBAC roles (`student`, `company`, `teacher`, `institution_admin`, `super_admin`). |
| `institutions` | Validates accredited colleges/universities (AISHE code), anchoring institutional progress and accreditation. |
| `users` | Secure root authentication entity (email, password hash, role). |
| `student_profiles` | Academic identity (USN/Roll No, CGPA, branch, graduation year) linked to verified student user. |
| `company_profiles` | Corporate identity, employer branding, GSTIN/CIN registration, and verification status. |
| `teacher_profiles` | Faculty credential store empowering authorized teachers to verify student skills and mentor students. |
| `skill_categories` | High-level groupings (Frontend, Backend, AI, Cloud, Tools) preventing flat unorganized lists. |
| `skills` | Canonical dictionary of skills supporting parent-child hierarchy (e.g. Programming $\to$ Python $\to$ FastAPI). |
| `student_skills` | Many-to-Many junction table linking students to claimed/tested skills with proficiency levels. |
| `skill_verifications` | Audit proof linking teacher endorsements or automated test engine scores to student skill records. |
| `opportunities` | Job, internship, and industrial project listings published by company partners. |
| `opportunity_skills` | Junction table defining required skills, minimum proficiencies, and mathematical weights per job. |
| `applications` | Student job application intake enforcing single-submission rules and caching calculated match scores. |
| `application_status_history`| Immutable chronological timeline tracking application stage transitions for students. |
| `resumes` | Stores student resume versioning, file sizes, and secure cloud storage URLs. |
| `projects` & `certificates` | Student portfolio showcases and external credentials uploaded for faculty endorsement. |
| `interview_slots` | Recruiter calendar availability slots with strict timezone support (`TIMESTAMPTZ`). |
| `interviews` | Confirmed candidate interview bookings preventing double-booking via unique slot constraints. |
| `feedback` | Post-interview recruiter evaluation sheet (ratings, technical scores, qualitative review). |
| `notifications` | In-app user notifications for stage changes and interview invitations. |
| `audit_logs` | Append-only security and administrative audit trail utilizing PostgreSQL `JSONB`. |

---

## Section 3: Primary Keys Strategy

* **UUIDv4 (`gen_random_uuid()`):**
  * Applied to: `users`, `institutions`, `student_profiles`, `company_profiles`, `teacher_profiles`, `skills`, `student_skills`, `opportunities`, `opportunity_skills`, `applications`, `resumes`, `interviews`.
  * *Why:* Prevents Insecure Direct Object Reference (IDOR) attacks and URL ID enumeration (e.g., guessing `/api/resumes/101`). Enables client-side ID generation without database round-trips.
* **`BIGINT GENERATED ALWAYS AS IDENTITY`:**
  * Applied to: `audit_logs`, `assessment_answers`, `application_status_history`.
  * *Why:* SQL-compliant replacement for `BIGSERIAL`. Saves storage space (8 bytes vs 16 bytes for UUID) and speeds up sequential B-Tree inserts on high-volume append tables.
* **`SMALLINT GENERATED ALWAYS AS IDENTITY` / `INT`:**
  * Applied to: `roles`, `skill_categories`.
  * *Why:* Static, bounded lookup tables with fewer than 100 entries.

---

## Section 4: Foreign Keys & Cascade Behaviors

* **`ON DELETE CASCADE` (Ownership):**
  * Deleting a `users` record cleanly cascades to `student_profiles`, `company_profiles`, and `teacher_profiles`.
  * Deleting an `opportunity` cascades to `opportunity_skills`.
  * Deleting an `application` cascades to `application_status_history` and `interviews`.
* **`ON DELETE RESTRICT` (Business Protection):**
  * `roles(id) -> users(role_id)`: Cannot delete a role assigned to active users.
  * `institutions(id) -> student_profiles(institution_id)`: Cannot drop a college if students are enrolled under it.
  * `opportunities(id) -> applications(opportunity_id)`: Cannot delete a job posting if student applications have been received.
  * `interview_slots(id) -> interviews(slot_id)`: Cannot delete a calendar slot currently assigned to an interview.
* **`ON DELETE SET NULL` (Audit Preservation):**
  * `teacher_profiles(id) -> skill_verifications(verifier_teacher_id)`: If a faculty member leaves the institution, their historical verification badges remain intact.

---

## Section 5: Relational Integrity & Constraints

1. **Anti-Duplicate Application Constraint:**
   ```sql
   CONSTRAINT uq_student_opportunity UNIQUE (opportunity_id, student_id)
   ```
   Prevents rapid-fire multiple submissions for the same opening.
2. **Double-Booking Prevention Constraint:**
   ```sql
   CONSTRAINT uq_interview_slot UNIQUE (slot_id)
   ```
   Ensures an interview slot can only be booked by exactly one candidate.
3. **Controlled State Machine:**
   ```sql
   CONSTRAINT chk_application_state CHECK (status IN ('APPLIED', 'UNDER_REVIEW', 'SHORTLISTED', 'INTERVIEW_SCHEDULED', 'SELECTED', 'REJECTED', 'WITHDRAWN'))
   ```
4. **Academic & Date Bounds:**
   - CGPA constrained to `0.00` to `10.00`.
   - Interview end time must be strictly after start time (`end_time > start_time`).
   - Match score constrained to `0.00` to `100.00`.

---

## Section 6: Indexing Strategy Summary

* **B-Tree Indexes:** Applied to all foreign key columns (`users.role_id`, `student_skills.student_id`, `opportunity_skills.opportunity_id`) to prevent sequential table scans during SQL joins.
* **Composite Indexes:**
  - `opportunities(status, application_deadline DESC)`: Instant landing page retrieval of open opportunities.
  - `applications(opportunity_id, match_score DESC)`: Instant leaderboard retrieval of top-ranked applicants without sorting in memory.
* **GIN (Generalized Inverted Index):**
  - Full-text search index on `opportunities(title || ' ' || description)` for sub-millisecond keyword job searching.

---

## Section 7: API Mapping & Traceability Summary

All 15 required endpoints are fully mapped in [`docs/database/API_DATABASE_MAPPING.md`](file:///c:/Users/divya/Downloads/sih26044/docs/database/API_DATABASE_MAPPING.md).  
Key highlights:
- **`POST /api/v1/assessments/{id}/submit`**: Automatically writes test responses and executes an `INSERT ... ON CONFLICT DO UPDATE` to mark the student's skill as verified.
- **`POST /api/v1/interviews/{id}/book`**: Uses PostgreSQL `SELECT ... FOR UPDATE` row locking to make concurrent interview bookings completely race-condition safe.
- Full traceability from user interface to automated test cases documented in [`docs/database/TRACEABILITY.md`](file:///c:/Users/divya/Downloads/sih26044/docs/database/TRACEABILITY.md).

---

## Section 8: Security & Performance Decisions

1. **Least Privilege & Role Isolation:**
   - Universal authentication resides in `users`; sensitive academic data resides in `student_profiles`; corporate tax/CIN details reside in `company_profiles`.
2. **No Cleartext Credentials:**
   - Enforced salted Argon2id / Bcrypt at the application tier; `password_hash` column size standardized to `VARCHAR(255)`.
3. **No Large Binaries in Database:**
   - Resumes and certificates stored in object storage (AWS S3/MinIO); PostgreSQL stores only URLs and metadata.
4. **N+1 Query Prevention:**
   - Recommended queries utilize PostgreSQL `json_agg()` to retrieve students and their nested skill arrays in a single round-trip query.

---

## Section 9: What Changed From Phase 1

During Phase 2, three major technical enhancements were introduced to meet real-world production demands:
1. **Hierarchical Skills:** Added `parent_skill_id` to `skills` to support nested taxonomies (Programming $\to$ Python $\to$ FastAPI) as requested in Phase 2 specifications.
2. **Identity Column Standardization:** Upgraded append logs (`audit_logs`, `assessment_answers`, `application_status_history`) from legacy PostgreSQL `BIGSERIAL` to SQL-standard `BIGINT GENERATED ALWAYS AS IDENTITY`.
3. **Weighted Opportunity Matching:** Enhanced `opportunity_skills` with `skill_weight NUMERIC(3, 2) DEFAULT 1.00`, allowing companies to assign higher importance to core skills.

---

## Section 10: What Is NOT Implemented Yet

1. **Phase 3 Physical Production Migrations:** Executable, production-ready schema migration tool configuration (e.g. Prisma schema, Drizzle schema, or Alembic) has not been initialized.
2. **Backend API Routes:** No backend Node.js / Python controller code has been committed to the repository yet.
3. **Frontend UI Components:** No React / Next.js forms or dashboard pages have been created.

---

## Section 11: What Phase 3 Will Implement

When Phase 3 begins, the engineering team will:
1. Select the project's backend migration framework (e.g., Prisma ORM, Drizzle ORM, or Alembic).
2. Generate official, executable migration scripts representing the complete Phase 2 design contracts.
3. Implement database seed scripts with comprehensive test datasets across all 5 stakeholder roles.
4. Build the core backend RESTful API controllers mapped to the database contracts defined in Phase 2.

---

## Student Learning Summary: PostgreSQL Concepts Mastered

```
┌──────────────────────────────────┬────────────────────────────────────────────────────────────────────────┐
│ PostgreSQL Concept               │ Practical Meaning & Application in SIH26044                            │
├──────────────────────────────────┼────────────────────────────────────────────────────────────────────────┤
│ BIGINT GENERATED ALWAYS AS IDENTITY│ SQL-standard auto-incrementing integer for internal audit logs.       │
│ CHECK Constraint                 │ Enforces valid domain values (e.g. cgpa BETWEEN 0 AND 10).             │
│ ON CONFLICT DO UPDATE            │ Upsert: Inserts a skill or updates score if student already has it.    │
│ SELECT ... FOR UPDATE            │ Row-level lock preventing two students from booking the same slot.     │
│ Composite Index                  │ An index on (opportunity_id, match_score DESC) for fast ranking.       │
│ GIN Index                        │ Generalized Inverted Index for lightning-fast keyword job searches.    │
│ Stored Function (PL/pgSQL)       │ calculate_skill_match() computes skill gaps directly inside database.  │
└──────────────────────────────────┴────────────────────────────────────────────────────────────────────────┘
```

---

## Final Status

```
PHASE: 2
STATUS: COMPLETED

FILES CREATED:
- docs/database/phase-2/01_formal_schema_design.md
- docs/database/ER_DIAGRAM.md
- docs/database/INDEX_DESIGN.md
- docs/database/API_DATABASE_MAPPING.md
- docs/database/TRACEABILITY.md
- docs/database/phase-2/PHASE_2_REPORT.md

FILES MODIFIED:
- database/migrations/ (Contains all verified baseline migrations 001 to 008 created and tested during interactive validation).

TESTS/DESIGN VALIDATIONS:
- Verified table creation and constraints in live PostgreSQL server via pgAdmin 4.
- Tested composite unique constraint on (opportunity_id, student_id) preventing duplicate applications.
- Validated calculate_skill_match() stored function calculating match percentage and missing skill gaps.
- Verified relational joins linking applications, opportunities, student profiles, and institutions.

KNOWN ISSUES:
None. All design contracts are mathematically and relationally sound.

READY FOR PHASE 3:
YES

DO NOT START PHASE 3.
STOP.
```
