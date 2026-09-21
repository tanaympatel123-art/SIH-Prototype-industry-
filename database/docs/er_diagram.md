# SIH26044: Entity-Relationship (ER) Diagram & Schema Documentation
**Project:** Academia–Industry Collaboration Portal  
**Phase:** Phase 1 — Core Database Foundation  
**Database Engine:** MySQL 8.x (InnoDB, utf8mb4)  
**Environment:** XAMPP / phpMyAdmin / VS Code  

---

## 1. Visual Mermaid ER Diagram

```mermaid
erDiagram
    ROLES ||--o{ USERS : "assigned to"
    USERS ||--o| STUDENT_PROFILES : "owns (1:1)"
    USERS ||--o| COMPANY_PROFILES : "owns (1:1)"
    USERS ||--o| TEACHER_PROFILES : "owns (1:1)"

    STUDENT_PROFILES ||--o{ STUDENT_SKILLS : "possesses"
    SKILLS ||--o{ STUDENT_SKILLS : "cataloged in"
    SKILLS ||--o{ SKILLS : "hierarchical parent of"

    STUDENT_SKILLS ||--o{ SKILL_VERIFICATIONS : "validated via"
    TEACHER_PROFILES ||--o{ SKILL_VERIFICATIONS : "authorizes"

    COMPANY_PROFILES ||--o{ OPPORTUNITIES : "publishes"
    OPPORTUNITIES ||--o{ OPPORTUNITY_SKILLS : "mandates"
    SKILLS ||--o{ OPPORTUNITY_SKILLS : "required by"

    STUDENT_PROFILES ||--o{ APPLICATIONS : "submits"
    OPPORTUNITIES ||--o{ APPLICATIONS : "receives"

    ROLES {
        tinyint_unsigned id PK
        varchar_50 name UK
        varchar_255 description
        timestamp created_at
        timestamp updated_at
    }

    USERS {
        bigint_unsigned id PK
        tinyint_unsigned role_id FK
        varchar_255 email UK
        varchar_255 password_hash
        varchar_20 phone
        boolean is_active
        timestamp last_login_at
        timestamp created_at
        timestamp updated_at
    }

    STUDENT_PROFILES {
        bigint_unsigned id PK
        bigint_unsigned user_id FK,UK
        varchar_50 student_identifier UK
        varchar_100 first_name
        varchar_100 last_name
        varchar_255 institution
        varchar_100 department
        varchar_100 course_program
        tinyint_unsigned current_semester
        year graduation_year
        decimal cgpa
        text bio
        varchar_150 location
        varchar_500 profile_photo_url
        timestamp created_at
        timestamp updated_at
    }

    COMPANY_PROFILES {
        bigint_unsigned id PK
        bigint_unsigned user_id FK,UK
        varchar_255 company_name
        varchar_100 industry
        text company_description
        varchar_255 website
        varchar_150 location
        varchar_50 company_size
        timestamp created_at
        timestamp updated_at
    }

    TEACHER_PROFILES {
        bigint_unsigned id PK
        bigint_unsigned user_id FK,UK
        varchar_50 employee_identifier UK
        varchar_100 first_name
        varchar_100 last_name
        varchar_255 institution
        varchar_100 department
        varchar_100 designation
        varchar_255 specialization
        text bio
        timestamp created_at
        timestamp updated_at
    }

    SKILLS {
        int_unsigned id PK
        varchar_100 skill_name UK
        varchar_100 category
        text description
        int_unsigned parent_skill_id FK
        timestamp created_at
        timestamp updated_at
    }

    STUDENT_SKILLS {
        bigint_unsigned id PK
        bigint_unsigned student_id FK
        int_unsigned skill_id FK
        enum proficiency_level
        decimal proficiency_score
        enum source
        boolean is_verified
        timestamp created_at
        timestamp updated_at
    }

    SKILL_VERIFICATIONS {
        bigint_unsigned id PK
        bigint_unsigned student_skill_id FK
        bigint_unsigned verifier_teacher_id FK
        enum verification_status
        enum evidence_type
        varchar_500 evidence_reference
        decimal confidence_score
        text remarks
        timestamp verified_at
        timestamp created_at
        timestamp updated_at
    }

    OPPORTUNITIES {
        bigint_unsigned id PK
        bigint_unsigned company_id FK
        varchar_255 title
        text description
        enum opportunity_type
        varchar_150 location
        enum work_mode
        varchar_100 stipend_salary
        int_unsigned openings
        date application_deadline
        enum status
        timestamp created_at
        timestamp updated_at
    }

    OPPORTUNITY_SKILLS {
        bigint_unsigned id PK
        bigint_unsigned opportunity_id FK
        int_unsigned skill_id FK
        enum required_proficiency_level
        boolean is_mandatory
        timestamp created_at
    }

    APPLICATIONS {
        bigint_unsigned id PK
        bigint_unsigned opportunity_id FK
        bigint_unsigned student_id FK
        enum application_status
        timestamp applied_at
        varchar_500 resume_reference
        text cover_note
        text company_notes
        timestamp updated_at
    }
```

---

## 2. Core Relational Architecture

### 1. User & Identity Layer
- **`roles`**: System master table with fixed roles: `student`, `company`, `teacher`, `admin`.
- **`users`**: Universal authentication root. Stores email, hashed password (bcrypt), activity status, and direct foreign key `role_id`.
  - **Decision Rationale:** A direct `role_id` foreign key on `users` was chosen over a separate `user_roles` junction table because each account possesses a distinct primary stakeholder identity in Phase 1. This prevents role-switching anomalies, reduces JOIN overhead on login lookups, and simplifies authorization middleware.

### 2. Stakeholder Profiles (1:1 with Users)
- **`student_profiles`**: Linked via `UNIQUE(user_id)`. Contains enrollment identifiers, academic institution, program, semester, graduation year, and CGPA. Does not duplicate authentication data.
- **`company_profiles`**: Linked via `UNIQUE(user_id)`. Stores corporate name, industry vertical, description, website, size, and headquarters.
- **`teacher_profiles`**: Linked via `UNIQUE(user_id)`. Stores faculty identifier, institution, department, academic designation, and domain specialization.

### 3. Skill Master Taxonomy & Provenance
- **`skills`**: Canonical skill directory. Prevents duplicate definitions using `UNIQUE(skill_name)`. Includes a self-referencing foreign key `parent_skill_id` enabling hierarchical ontology modeling (e.g. `SQL` -> `MySQL`, `JavaScript` -> `React`).
- **`student_skills`**: Resolves many-to-many relationship between students and skills. Enforces `UNIQUE(student_id, skill_id)`.
  - **AI Provenance Integrity Rule:** When `source = 'ai_extracted'`, `is_verified` remains `FALSE`. Official verification requires explicit authorization via `skill_verifications`.
- **`skill_verifications`**: Links `student_skills` to `teacher_profiles`. Teachers serve as the final human authority for skill credentialing. Supports `pending`, `approved`, and `rejected` statuses.

### 4. Opportunity & Recruitment Pipeline
- **`opportunities`**: Internship and employment postings created by corporate partners (`company_id`). Captures work mode, location, remuneration, openings, and application deadlines.
- **`opportunity_skills`**: Junction table binding opportunities to required skills. Enforces `UNIQUE(opportunity_id, skill_id)` and records minimum proficiency and mandatory/optional flags.
- **`applications`**: Tracks candidate lifecycle (`applied`, `shortlisted`, `interview`, `selected`, `rejected`, `withdrawn`). Enforces `UNIQUE(student_id, opportunity_id)` so a candidate can apply only once per posting.
