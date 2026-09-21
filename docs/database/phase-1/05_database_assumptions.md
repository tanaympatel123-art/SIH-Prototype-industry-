# 05. Database Architectural Assumptions & Design Decisions
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Baseline Architectural Assumptions, Standards, and Constraints  
**Target Database:** PostgreSQL (v15+)  
**Author:** Database Architect & Engineer Team  
**Audience:** Development Team & Student Learners  

---

## 1. Technical & Environmental Assumptions

### 1.1 Target RDBMS & Version
* **Assumption:** The production and development database is **PostgreSQL v15 or higher**.
* **Reasoning:** PostgreSQL 15+ provides native support for `gen_random_uuid()` without requiring external extensions (`uuid-ossp`), robust JSONB query performance, advanced window functions, and declarative partitioning should scaling become necessary.

### 1.2 Multi-Tenancy Architecture
* **Assumption:** We adopt a **Logical Shared Database, Multi-Tenant Model** with Role-Based Access Control (RBAC).
* **Reasoning:** All colleges, students, and companies share the same PostgreSQL database schema. Tenant boundaries (e.g. separating students belonging to College A from College B) are enforced via foreign keys (`institution_id`) and application-layer authorization checks (or PostgreSQL Row-Level Security / RLS). Separate physical databases per college would introduce unnecessary operational complexity for this portal.

### 1.3 Primary Key Strategy
* **Assumption:** All core entities use **UUIDv4** as their Primary Key (e.g., `gen_random_uuid()`), except for lookup/reference tables like `roles` and `skill_categories` which use standard auto-incrementing integers (`SERIAL`/`SMALLSERIAL`).
* **Reasoning:** UUIDs prevent ID enumeration attacks (where an attacker guesses `https://api.portal.com/students/101` then changes the URL to `/students/102`). They also allow distributed ID generation on the application server without database round-trips.

---

## 2. Data Storage & File Management Assumptions

### 2.1 File & Document Storage Strategy
* **Assumption:** **PostgreSQL does NOT store file binaries or raw PDFs (BLOB/`bytea`).**
* **Standard:** All resumes, certificate scans, company logos, and assignment submissions are stored in an external Object Storage service (e.g., AWS S3, Cloudflare R2, MinIO, or local file system storage in development).
* **Database Role:** The database stores only the verified file metadata: `file_url`, `file_name`, `file_size_bytes`, `mime_type`, and `uploaded_at`.

### 2.2 Timezone & Timestamp Standard
* **Assumption:** Every datetime column in PostgreSQL must be defined as **`TIMESTAMPTZ` (timestamp with time zone)** and stored in **UTC**.
* **Standard:** The database never assumes local Indian Standard Time (IST) internally. The backend writes UTC timestamps (`NOW() AT TIME ZONE 'UTC'`), and the frontend converts UTC to the user's local timezone (IST) for display.

### 2.3 Currency and Financial Data
* **Assumption:** Stipends and compensation amounts are stored using **`NUMERIC(10, 2)`** with a companion ISO currency code column (defaulting to `'INR'`).
* **Reasoning:** Never use `FLOAT` or `REAL` for financial figures because binary floating-point representation causes rounding errors (e.g. `0.1 + 0.2 = 0.30000000000000004`).

---

## 3. Business Logic & Processing Assumptions

### 3.1 Skill Gap Evaluation Logic
* **Assumption:** Skill gaps are determined dynamically by calculating the relative complement (set difference) between an opportunity's required skills and a student's verified skills.
* **Implementation Formula:**
  $$\text{Missing Skills} = \text{Skills Required by Opportunity} \setminus \text{Skills Possessed by Student}$$
* **Match Score:**
  $$\text{Match Score (\%)} = \left(\frac{|\text{Possessed Mandatory Skills}|}{|\text{Total Mandatory Skills}|}\right) \times 100$$
* **Storage Implication:** Because this can be calculated dynamically, we do not need to store millions of pre-computed rows in `skill_gap_recommendations` for MVP.

### 3.2 Assessment Engine Logic
* **Assumption:** Quizzes are objective (Multiple Choice Questions with single or multiple correct answers).
* **Scoring:** The scoring calculation is performed synchronously upon test submission or via a lightweight backend service, directly comparing student selections against `assessment_options.is_correct`.

### 3.3 Deletion Policy (Soft Deletes vs Hard Deletes)
* **Assumption:** Core business assets (applications, opportunities, user accounts) use **soft deletion** (`is_active = FALSE` or `deleted_at TIMESTAMPTZ NULL`), while transient junction records or temporary sessions may be hard deleted.
* **Reasoning:** Academic and recruitment records are legally sensitive and subject to audits. Accidental or malicious hard deletion of student application histories must be prevented.

---

## 4. Student Learning Corner: Why Document Assumptions?

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is an Architectural Assumption?**  
> An architectural assumption is a conscious engineering decision made before writing code that sets ground rules for how data, time, security, and storage will be handled across the entire project.
> 
> **WHY do assumptions cause failures if left unwritten?**  
> If developer A assumes that student resumes should be stored directly in PostgreSQL as 5-megabyte binary blobs (`bytea`), and developer B assumes resumes will be stored in Amazon S3 as URLs:
> 1. The database table will crash or bloat to hundreds of gigabytes within weeks.
> 2. Backups and database restore operations will take hours instead of seconds.
> 3. The frontend will break because developer A expects a byte stream while developer B returns a link!
> 
> **HOW does it apply to this project?**  
> Consider timestamps: If a company in Bengaluru schedules an interview at 3:00 PM IST, and your database stores `TIMESTAMP WITHOUT TIME ZONE`, PostgreSQL might interpret that time as UTC (which would mean 8:30 PM IST). The student would miss their interview! By defining the rule `TIMESTAMPTZ in UTC` from Day 1, all time-zone bugs are eliminated.
