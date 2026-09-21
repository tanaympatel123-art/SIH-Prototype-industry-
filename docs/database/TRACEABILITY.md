# Requirements Traceability Matrix (RTM)
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** End-to-End Requirement Traceability from UI to Database and Tests  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  

---

## 1. Traceability Methodology

The Requirements Traceability Matrix guarantees that every functional requirement of the SIH portal is tied directly to:
$$\text{Requirement} \longrightarrow \text{User Interface (UI)} \longrightarrow \text{REST API} \longrightarrow \text{Database Tables} \longrightarrow \text{Underlying SQL Query} \longrightarrow \text{Validation Test}$$

This ensures zero dead tables and zero unfulfilled user requirements.

---

## 2. Comprehensive Traceability Matrix

### 2.1 Student Journey

| # | Requirement | User Interface (UI) | REST API Endpoint | Database Table(s) | Primary SQL Operation | Validation Test Case |
|---|---|---|---|---|---|---|
| **REQ-ST-01** | Student registers account with college domain | Registration Page | `POST /api/v1/auth/register` | `users`, `roles`, `institutions` | `INSERT INTO users (email, password_hash, role_id) ...` | `test_student_registration_unique_email()` |
| **REQ-ST-02** | Student fills academic profile (CGPA, USN, branch) | Profile Setup Form | `PATCH /api/v1/students/me` | `student_profiles` | `INSERT INTO student_profiles (user_id, roll_number, cgpa, ...) ...` | `test_profile_academic_range_constraints()` |
| **REQ-ST-03** | Student completes skill assessment quiz | Timed MCQ Quiz Modal | `POST /api/v1/assessments/{id}/submit` | `assessments`, `assessment_attempts`, `assessment_answers`, `student_skills` | `INSERT INTO assessment_attempts ...; UPDATE student_skills SET is_verified = TRUE ...` | `test_quiz_auto_scoring_and_skill_verification()` |
| **REQ-ST-04** | Student views skill radar & gap against market | Skill Profile Dashboard | `GET /api/v1/students/me/skills` | `student_skills`, `skills`, `skill_categories` | `SELECT s.name, ss.proficiency_level, ss.is_verified FROM student_skills ss ...` | `test_student_skill_radar_retrieval()` |
| **REQ-ST-05** | Student browses and filters active internships | Internship Directory | `GET /api/v1/opportunities` | `opportunities`, `company_profiles`, `opportunity_skills` | `SELECT * FROM opportunities WHERE status = 'active' AND application_deadline > NOW() ...` | `test_browse_active_opportunities_pagination()` |
| **REQ-ST-06** | Student inspects job & views automated skill fit | Internship Detail View | `GET /api/v1/opportunities/{id}` | `opportunities`, `calculate_skill_match()` | `SELECT * FROM calculate_skill_match(:student_id, :opp_id);` | `test_skill_gap_set_difference_calculation()` |
| **REQ-ST-07** | Student submits application with resume | Job Details "Apply" Modal | `POST /api/v1/opportunities/{id}/applications` | `applications`, `resumes`, `application_status_history` | `INSERT INTO applications (opportunity_id, student_id, resume_id, match_score) ...` | `test_prevent_duplicate_application_constraint()` |
| **REQ-ST-08** | Student tracks status progression over time | "My Applications" Tab | `GET /api/v1/students/me/applications` | `applications`, `application_status_history` | `SELECT a.status, h.old_status, h.new_status, h.changed_at FROM applications a ...` | `test_application_status_history_timeline()` |
| **REQ-ST-09** | Student selects and confirms an interview slot | Interview Booking Calendar | `POST /api/v1/interviews/{id}/book` | `interview_slots`, `interviews`, `applications` | `UPDATE interview_slots SET is_booked = TRUE ... FOR UPDATE; INSERT INTO interviews ...` | `test_concurrent_interview_double_booking_prevention()` |

---

### 2.2 Company / Employer Journey

| # | Requirement | User Interface (UI) | REST API Endpoint | Database Table(s) | Primary SQL Operation | Validation Test Case |
|---|---|---|---|---|---|---|
| **REQ-CO-01** | Company completes corporate onboarding | Company Profile Form | `PATCH /api/v1/companies/me` | `company_profiles` | `INSERT INTO company_profiles (user_id, company_name, industry_type, ...) ...` | `test_company_registration_verification_default()` |
| **REQ-CO-02** | Company posts internship with weighted skills | "Create Posting" Form | `POST /api/v1/companies/me/opportunities` | `opportunities`, `opportunity_skills` | `INSERT INTO opportunities ...; INSERT INTO opportunity_skills (opportunity_id, skill_id, skill_weight) ...` | `test_opportunity_skill_weight_positive_constraint()` |
| **REQ-CO-03** | Company views candidate leaderboard sorted by match score | Applicant Review Dashboard | `GET /api/v1/companies/me/opportunities/{id}/applicants` | `applications`, `student_profiles`, `institutions` | `SELECT * FROM applications WHERE opportunity_id = :id ORDER BY match_score DESC;` | `test_applicant_ranking_index_performance()` |
| **REQ-CO-04** | Company opens available interview calendar slots | Recruiter Availability Manager | `POST /api/v1/interviews/slots` | `interview_slots` | `INSERT INTO interview_slots (company_id, start_time, end_time) ...` | `test_interview_slot_end_after_start_constraint()` |
| **REQ-CO-05** | Company submits technical rating & post-interview feedback | Candidate Evaluation Sheet | `POST /api/v1/applications/{id}/feedback` | `feedback`, `applications` | `INSERT INTO feedback (application_id, rating, technical_score, ...) ...` | `test_feedback_rating_range_check()` |

---

### 2.3 Teacher / Faculty Journey

| # | Requirement | User Interface (UI) | REST API Endpoint | Database Table(s) | Primary SQL Operation | Validation Test Case |
|---|---|---|---|---|---|---|
| **REQ-TE-01** | Faculty verifies student skill claim & project proof | Student Skill Endorsement Desk | `POST /api/v1/verification/skills/{id}` | `skill_verifications`, `student_skills`, `teacher_profiles` | `INSERT INTO skill_verifications ...; UPDATE student_skills SET is_verified = TRUE ...` | `test_teacher_skill_endorsement_authorization()` |
| **REQ-TE-02** | Faculty audits student certificate authenticity | Certificate Approval View | `POST /api/v1/verification/certificates/{id}` | `certificates`, `teacher_profiles` | `UPDATE certificates SET is_verified = TRUE, verified_by_teacher_id = :tid ...` | `test_certificate_verification_linkage()` |
| **REQ-TE-03** | Faculty reviews departmental job readiness analytics | Department Head Dashboard | `GET /api/v1/institutions/me/analytics` | `student_profiles`, `student_skills`, `applications` | `SELECT department, COUNT(DISTINCT student_id), AVG(cgpa) FROM student_profiles ... GROUP BY department;` | `test_department_cohort_aggregation_query()` |

---

## 3. Student Learning Corner: Why Traceability Prevents Project Failure

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is Requirements Traceability?**  
> Traceability is the thread connecting every single user requirement to a piece of UI, a backend route, a database table, an exact SQL query, and a test script.
> 
> **WHY do software projects fail without Traceability?**  
> In hackathons and industry projects:
> 1. Teams build tables that **no API ever uses** (wasted time).
> 2. Teams design fancy UI buttons that have **no database table to save the data** (broken features).
> 3. Traceability guarantees that every table exists for a clear, verified purpose and can be demonstrated during evaluation!
> 
> **HOW does it apply to this project?**  
> Look at **REQ-ST-07**: When a student clicks "Apply" on the UI, the database doesn't just insert into `applications`—it triggers a lookup in `calculate_skill_match()` and writes an entry into `application_status_history`. Traceability ensures that the frontend, backend, and database work together as one cohesive unit!
