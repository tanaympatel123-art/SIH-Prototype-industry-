# 04. Database Priority Classification (P0 to P3)
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** Entity Prioritization, MVP Scoping & Engineering Trade-offs  
**Target Database:** PostgreSQL (v15+)  
**Author:** Database Architect & Engineer Team  
**Audience:** Development Team & Student Learners  

---

## 1. Prioritization Framework

In hackathons and real-world product engineering, trying to build 30 database tables all at once is a recipe for failure: migrations break, relationships tangle, and you run out of time before the core user experience works.

We divide database entities into four strict priority tiers:

* **P0 — Essential MVP (Minimum Viable Product):** The absolute core schema required to deliver an end-to-end working demo of the primary SIH problem statement (Student registration, profile, posting opportunities, skill matching, and applying).
* **P1 — Important (Near-Term Core):** Features that turn the MVP into an impressive, functional platform (skill assessment quizzes, teacher verification, interview scheduling, notifications, status audit trails).
* **P2 — Optional (Post-MVP Enhancements):** Richer features that enhance the portal but aren't strictly necessary for a winning baseline demo (detailed answer-level quiz analytics, curated learning resources, student project showcases).
* **P3 — Future (Phase 3 & Production Expansion):** Enterprise-scale capabilities, formal joint research projects, multi-college consortiums, and automated AI scrapers.

---

## 2. Entity Priority Breakdown & Architectural Justification

| Priority | Entity Name | Domain | Justification for Classification |
|---|---|---|---|
| **P0** | `roles` | CORE | Fundamental for RBAC (Role-Based Access Control) to separate Students, Companies, and Teachers. |
| **P0** | `institutions` | CORE | The SIH theme is "Academia-Industry Collaboration". Institutional identity is mandatory. |
| **P0** | `users` | CORE | Central table for login, authentication, password hash, and session integrity. |
| **P0** | `student_profiles` | CORE | Stores student academic data (Roll No, CGPA, Branch) needed by recruiters. |
| **P0** | `company_profiles` | CORE | Stores employer identity and verification status. |
| **P0** | `teacher_profiles` | CORE | Identifies faculty members eligible to verify skills and mentor students. |
| **P0** | `skill_categories` | SKILLS | Prevents an unorganized flat list of skills; organizes skills by domain. |
| **P0** | `skills` | SKILLS | Master taxonomy needed to match candidates with job postings. |
| **P0** | `student_skills` | SKILLS | Junction table representing the student's claimed and demonstrated skill set. |
| **P0** | `opportunities` | OPPORTUNITIES | Core entity for posting internships, jobs, and industrial projects. |
| **P0** | `opportunity_skills` | OPPORTUNITIES | Defines the required skills and minimum proficiencies for each posting. |
| **P0** | `applications` | OPPORTUNITIES | Records student job applications, preventing duplicate applications. |
| **P0** | `resumes` | PORTFOLIO | Stores the student's uploaded CV/resume URL for employer review. |
| **P1** | `assessments` | ASSESSMENT | Enables the platform's automated skill testing and quiz engine. |
| **P1** | `assessment_questions` | ASSESSMENT | Stores question bank for objective skill evaluation. |
| **P1** | `assessment_options` | ASSESSMENT | Stores options and correct answer flags for MCQ testing. |
| **P1** | `assessment_attempts` | ASSESSMENT | Tracks student test scores, timestamps, and pass/fail status. |
| **P1** | `skill_verifications` | SKILLS | Records faculty endorsements and proof verification for student skills. |
| **P1** | `application_status_history` | OPPORTUNITIES | Immutable timeline of application progression (Applied -> Shortlisted -> Offered). |
| **P1** | `interview_slots` | INTERVIEWS | Allows employers to propose available interview dates/times. |
| **P1** | `interviews` | INTERVIEWS | Connects applicant, employer, and video meeting links. |
| **P1** | `feedback` | SYSTEM | Recruiter rating and qualitative feedback post-interview. |
| **P1** | `notifications` | SYSTEM | Real-time and persistent alerts when application status changes. |
| **P1** | `audit_logs` | SYSTEM | Compliance audit trail for administrative changes and security events. |
| **P2** | `projects` | PORTFOLIO | Student GitHub/live project showcases linked to their profile. |
| **P2** | `certificates` | PORTFOLIO | External certificates (AWS, Coursera, NPTEL) uploaded for review. |
| **P2** | `learning_resources` | LEARNING | Curated courses and tutorials suggested based on skill-gap analysis. |
| **P2** | `skill_gap_recommendations`| LEARNING | Cached recommendations mapping missing skills to learning resources. |
| **P2** | `assessment_answers` | ASSESSMENT | Granular per-question answer logs for detailed diagnostic reports. |
| **P2** | `programs` | COLLABORATION | Faculty Development Programs (FDPs) and corporate training workshops. |
| **P2** | `mentorships` | COLLABORATION | Formal tracking of mentor-mentee relationships. |
| **P3** | `consultancy_projects` | COLLABORATION | Commercial industrial consulting projects contracted between companies and faculty. |
| **P3** | `alumni_networks` | SYSTEM | Tracking placed alumni who return as industry mentors. |
| **P3** | `ai_resume_embeddings` | SEARCH | Vector embeddings (pgvector) for semantic resume-to-job matching. |

---

## 3. Implementation Phasing Strategy

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1 (Current)                                           │
│ Validate, Analyze, Prioritize & Document Database Design   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2 (Next Immediate Step)                               │
│ Schema DDL & Migrations for P0 Entities                     │
│ 13 Tables: roles, institutions, users, student/company/     │
│ teacher profiles, skills, student/opp skills, opportunities, │
│ applications, resumes                                       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3 (Functional Enrichment)                             │
│ Migrations for P1 Entities                                  │
│ Assessment Quizzes, Verification Log, Interviews, History   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4 (Advanced Features & Optimization)                  │
│ P2 & P3 Entities, Performance Indexing, Analytics Views     │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Student Learning Corner: Prioritization & Scope Management

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is MVP Scoping and Priority Classification?**  
> MVP (Minimum Viable Product) is the smallest set of features that delivers actual value to users and proves the platform solves the core problem. P0, P1, P2, and P3 classifications establish the exact order in which tables must be designed, created, and tested.
> 
> **WHY do we avoid building P2/P3 tables during early development?**  
> 1. **Schema Fragility:** If you build all 30 tables at once, changing one column in `users` might require rewriting 15 foreign keys across unneeded tables like `consultancy_projects`.
> 2. **Cognitive Overload:** As a learner, testing a system with 30 tables, 50 foreign keys, and 100 constraints makes debugging SQL errors overwhelming.
> 3. **Validation First:** If the core flow (Student applies to Internship with verified skills) does not work seamlessly, having a fancy `mentorships` table has zero value to judges or users.
> 
> **HOW does it apply to this project?**  
> Notice that `student_skills` is **P0**, but `skill_gap_recommendations` is **P2**. Why?
> Because the skill gap (the difference between what skills a job requires and what skills a student possesses) can initially be calculated on-the-fly with a simple SQL `EXCEPT` or `NOT IN` query! We do NOT need a dedicated persistent table just to display missing skills in the MVP. That saves time and keeps the database clean.
