# Comprehensive Entity-Relationship (ER) Diagram
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** System-Wide Relational Architecture Model  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  

---

## 1. Complete System Architecture Model

This diagram captures the complete data topology across all 5 core stakeholder flows: Students, Companies, Teachers, Institutions, and Platform Admins.

```mermaid
erDiagram
    %% CORE AUTH & PROFILES
    roles ||--o{ users : "governs permissions"
    institutions ||--o{ student_profiles : "enrolls"
    institutions ||--o{ teacher_profiles : "employs"
    users ||--|| student_profiles : "1-to-1 profile"
    users ||--|| company_profiles : "1-to-1 profile"
    users ||--|| teacher_profiles : "1-to-1 profile"

    %% SKILL TAXONOMY & VERIFICATION
    skill_categories ||--o{ skills : "groups"
    skills ||--o{ skills : "parent hierarchy"
    student_profiles ||--o{ student_skills : "claims & tests"
    skills ||--o{ student_skills : "referenced by"
    student_skills ||--o{ skill_verifications : "verified via"
    teacher_profiles ||--o{ skill_verifications : "attests proof"

    %% OPPORTUNITIES & APPLICATIONS
    company_profiles ||--o{ opportunities : "publishes"
    opportunities ||--o{ opportunity_skills : "specifies requirements"
    skills ||--o{ opportunity_skills : "required by"
    student_profiles ||--o{ applications : "submits"
    opportunities ||--o{ applications : "receives"
    student_profiles ||--o{ resumes : "uploads"
    resumes ||--o{ applications : "attached to"
    applications ||--o{ application_status_history : "transition timeline"

    %% ASSESSMENT QUIZ ENGINE
    skills ||--o{ assessments : "tests"
    assessments ||--o{ assessment_questions : "contains"
    assessment_questions ||--o{ assessment_options : "offers choices"
    student_profiles ||--o{ assessment_attempts : "attempts"
    assessments ||--o{ assessment_attempts : "evaluated under"
    assessment_attempts ||--o{ assessment_answers : "records responses"
    assessment_questions ||--o{ assessment_answers : "question answered"

    %% INTERVIEWS & HIRING
    company_profiles ||--o{ interview_slots : "schedules slots"
    applications ||--|| interviews : "scheduled for"
    interview_slots ||--|| interviews : "books"
    applications ||--o{ feedback : "evaluated by"
    users ||--o{ feedback : "submitted by"

    %% ENTITY ATTRIBUTE DEFINITIONS
    roles {
        smallint id PK
        string name UK
        text description
    }

    institutions {
        uuid id PK
        string code UK
        string name
        string city
        string state
        boolean is_verified
    }

    users {
        uuid id PK
        string email UK
        string password_hash
        smallint role_id FK
        boolean is_active
        boolean is_email_verified
    }

    student_profiles {
        uuid id PK
        uuid user_id FK,UK
        uuid institution_id FK
        string roll_number
        string department
        smallint current_semester
        numeric cgpa
        int graduation_year
    }

    company_profiles {
        uuid id PK
        uuid user_id FK,UK
        string company_name
        string industry_type
        string registration_number
        string verification_status
    }

    teacher_profiles {
        uuid id PK
        uuid user_id FK,UK
        uuid institution_id FK
        string faculty_id
        string designation
        string department
    }

    skills {
        uuid id PK
        int category_id FK
        uuid parent_skill_id FK
        string name UK
    }

    student_skills {
        uuid id PK
        uuid student_id FK
        uuid skill_id FK
        string proficiency_level
        boolean is_verified
        numeric verification_score
    }

    opportunities {
        uuid id PK
        uuid company_id FK
        string title
        string opportunity_type
        string work_mode
        numeric stipend_amount
        string status
        timestamptz application_deadline
    }

    opportunity_skills {
        uuid id PK
        uuid opportunity_id FK
        uuid skill_id FK
        boolean is_mandatory
        string min_proficiency
        numeric skill_weight
    }

    applications {
        uuid id PK
        uuid opportunity_id FK
        uuid student_id FK
        uuid resume_id FK
        numeric match_score
        string status
        timestamptz applied_at
    }

    application_status_history {
        bigint id PK
        uuid application_id FK
        string old_status
        string new_status
        uuid changed_by_user_id FK
        timestamptz changed_at
    }

    assessments {
        uuid id PK
        uuid skill_id FK
        string title
        int quiz_version
        int duration_minutes
        numeric pass_percentage
    }

    assessment_questions {
        uuid id PK
        uuid assessment_id FK
        text question_text
        string difficulty
        int marks
    }

    assessment_attempts {
        uuid id PK
        uuid student_id FK
        uuid assessment_id FK
        int attempt_number
        numeric score_obtained
        boolean passed
        string completion_status
    }

    interview_slots {
        uuid id PK
        uuid company_id FK
        timestamptz start_time
        timestamptz end_time
        boolean is_booked
    }

    interviews {
        uuid id PK
        uuid application_id FK,UK
        uuid slot_id FK,UK
        timestamptz scheduled_time
        string meeting_url
        string status
    }
```

---

## 2. Key Cardinality Rules Visualized

### 2.1 The Closed-Loop Verification Triangle

```
        [Institutions]
         /          \
      (1:N)        (1:N)
       /              \
[student_profiles]   [teacher_profiles]
       \              /
      (M:N)        (Attests)
         \          /
       [student_skills] <── [skill_verifications]
```

### 2.2 The Hiring & Application Pipeline

```
[company_profiles] ──(1:N)──> [opportunities] ──(1:N)──> [applications] <──(1:N)── [student_profiles]
                                    │                           │
                                  (M:N)                       (1:1)
                                    │                           │
                                 [skills]                  [interviews]
                                                                │
                                                              (1:1)
                                                                │
                                                         [interview_slots]
```

---

## 3. Student Learning Corner: Reading ER Diagrams

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT are the symbols in Mermaid ER Diagrams?**
> - `||--||`: **One-to-One** (Exactly one record links to exactly one record, e.g. `users` to `student_profiles`).
> - `||--o{`: **One-to-Many** (One parent record has zero, one, or multiple children, e.g. `company_profiles` to `opportunities`).
> - `PK`: Primary Key (Unique row identity).
> - `FK`: Foreign Key (Link to a primary key in another table).
> - `UK`: Unique Key constraint (Prevents duplicate values).
> 
> **WHY do we create this diagram before writing APIs?**  
> When a frontend developer asks: *"How do I get the company name for an interview?"*, the ER diagram shows the path in 3 seconds:  
> `interviews` $\to$ `applications` $\to$ `opportunities` $\to$ `company_profiles.company_name`.  
> The diagram is your architectural roadmap!
