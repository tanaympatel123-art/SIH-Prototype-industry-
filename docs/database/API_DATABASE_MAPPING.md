# API to Database Contract Mapping
**Project:** SIH26044 – Academia–Industry Collaboration Portal  
**Document:** REST API Endpoints Mapped to PostgreSQL Schema & SQL Operations  
**Target Database:** PostgreSQL (v15+)  
**Role:** Database Architect  

---

## 1. Executive Summary

This document establishes the precise architectural contract between the **Backend REST API** and the **PostgreSQL Database**. For every critical endpoint, backend engineers and student developers can find the required SQL query, affected tables, parameter binding, and expected HTTP status codes.

---

## 2. Comprehensive Endpoint-to-Database Mapping

### 2.1 Authentication & Identity

#### `POST /api/v1/auth/login`
* **Purpose:** Authenticate user and issue JWT token.
* **Target Tables:** `users`, `roles`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      u.id AS user_id,
      u.email,
      u.password_hash,
      u.is_active,
      r.name AS role_name
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.email = :email;
  ```
* **Post-Validation Operation:**
  ```sql
  UPDATE users 
  SET last_login_at = NOW() 
  WHERE id = :user_id;
  ```
* **Status Codes:** `200 OK`, `401 Unauthorized` (invalid password or inactive account).

---

#### `GET /api/v1/auth/me`
* **Purpose:** Fetch current authenticated user identity and role.
* **Target Tables:** `users`, `roles`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      u.id, 
      u.email, 
      u.phone, 
      u.is_email_verified, 
      r.name AS role
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.id = :auth_user_id;
  ```
* **Status Codes:** `200 OK`, `401 Unauthorized`.

---

### 2.2 Student Profiles & Skills

#### `GET /api/v1/students/me`
* **Purpose:** Retrieve comprehensive student academic profile and college info.
* **Target Tables:** `student_profiles`, `institutions`, `users`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      sp.id AS student_profile_id,
      sp.first_name,
      sp.last_name,
      sp.roll_number,
      sp.department,
      sp.current_semester,
      sp.cgpa,
      sp.graduation_year,
      sp.headline,
      sp.bio,
      sp.github_url,
      sp.linkedin_url,
      sp.portfolio_url,
      inst.id AS institution_id,
      inst.name AS college_name,
      u.email,
      u.phone
  FROM student_profiles sp
  JOIN institutions inst ON sp.institution_id = inst.id
  JOIN users u ON sp.user_id = u.id
  WHERE sp.user_id = :auth_user_id;
  ```
* **Status Codes:** `200 OK`, `404 Not Found`.

---

#### `PATCH /api/v1/students/me`
* **Purpose:** Update editable student profile fields (bio, CGPA, URLs).
* **Target Tables:** `student_profiles`
* **Underlying SQL Query:**
  ```sql
  UPDATE student_profiles
  SET 
      headline = COALESCE(:headline, headline),
      bio = COALESCE(:bio, bio),
      cgpa = COALESCE(:cgpa, cgpa),
      current_semester = COALESCE(:current_semester, current_semester),
      github_url = COALESCE(:github_url, github_url),
      linkedin_url = COALESCE(:linkedin_url, linkedin_url),
      portfolio_url = COALESCE(:portfolio_url, portfolio_url),
      updated_at = NOW()
  WHERE user_id = :auth_user_id
  RETURNING *;
  ```
* **Status Codes:** `200 OK`, `400 Bad Request`.

---

#### `GET /api/v1/students/me/skills`
* **Purpose:** List student's claimed and verified skills with verification proof.
* **Target Tables:** `student_skills`, `skills`, `skill_categories`, `skill_verifications`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      ss.id AS student_skill_id,
      s.id AS skill_id,
      s.name AS skill_name,
      sc.name AS category_name,
      ss.proficiency_level,
      ss.is_verified,
      ss.verification_score,
      sv.verification_source,
      sv.verified_at
  FROM student_skills ss
  JOIN skills s ON ss.skill_id = s.id
  JOIN skill_categories sc ON s.category_id = sc.id
  LEFT JOIN skill_verifications sv ON sv.student_skill_id = ss.id AND sv.status = 'approved'
  JOIN student_profiles sp ON ss.student_id = sp.id
  WHERE sp.user_id = :auth_user_id
  ORDER BY ss.is_verified DESC, s.name ASC;
  ```
* **Status Codes:** `200 OK`.

---

### 2.3 Assessment Engine

#### `POST /api/v1/assessments/{id}/submit`
* **Purpose:** Submit quiz answers, calculate score, evaluate pass/fail, and automatically update student's verified skill!
* **Target Tables:** `assessment_attempts`, `assessment_answers`, `assessment_options`, `assessments`, `student_skills`
* **Transaction Workflow:**
  ```sql
  BEGIN;

  -- 1. Create Assessment Attempt Record
  INSERT INTO assessment_attempts (
      student_id, assessment_id, score_obtained, passed, completion_status, completed_at
  ) VALUES (
      :student_id, :assessment_id, :calculated_score, :has_passed, 'completed', NOW()
  ) RETURNING id INTO :attempt_id;

  -- 2. Store Question Answers
  INSERT INTO assessment_answers (attempt_id, question_id, selected_option_id, is_correct)
  VALUES (:attempt_id, :q_id, :opt_id, :is_correct);

  -- 3. If passed, automatically update or insert student_skills as verified!
  INSERT INTO student_skills (student_id, skill_id, proficiency_level, is_verified, verification_score)
  VALUES (:student_id, :skill_id, 'intermediate', TRUE, :calculated_score)
  ON CONFLICT (student_id, skill_id) DO UPDATE
  SET 
      is_verified = TRUE,
      verification_score = GREATEST(student_skills.verification_score, EXCLUDED.verification_score),
      updated_at = NOW();

  COMMIT;
  ```
* **Status Codes:** `201 Created`, `400 Bad Request`.

---

### 2.4 Opportunities & Search

#### `GET /api/v1/opportunities`
* **Purpose:** Browse and search active internships/jobs with pagination and filters.
* **Target Tables:** `opportunities`, `company_profiles`, `opportunity_skills`, `skills`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      o.id,
      o.title,
      o.opportunity_type,
      o.work_mode,
      o.location,
      o.stipend_amount,
      o.currency,
      o.duration_months,
      o.application_deadline,
      cp.company_name,
      cp.logo_url,
      json_agg(
          json_build_object(
              'skill_name', s.name,
              'is_mandatory', os.is_mandatory,
              'min_proficiency', os.min_proficiency
          )
      ) AS required_skills
  FROM opportunities o
  JOIN company_profiles cp ON o.company_id = cp.id
  LEFT JOIN opportunity_skills os ON os.opportunity_id = o.id
  LEFT JOIN skills s ON os.skill_id = s.id
  WHERE o.status = 'active' 
    AND o.application_deadline > NOW()
  GROUP BY o.id, cp.company_name, cp.logo_url
  ORDER BY o.created_at DESC
  LIMIT :limit OFFSET :offset;
  ```
* **Status Codes:** `200 OK`.

---

#### `GET /api/v1/opportunities/{id}`
* **Purpose:** Detailed view of an opportunity, including student's dynamic skill-gap match.
* **Target Tables:** `opportunities`, `company_profiles`, `opportunity_skills`, `calculate_skill_match()`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      o.*,
      cp.company_name,
      cp.industry_type,
      cp.website,
      cp.logo_url,
      m.match_score AS student_match_percentage,
      m.matched_skills,
      m.missing_skills
  FROM opportunities o
  JOIN company_profiles cp ON o.company_id = cp.id
  LEFT JOIN LATERAL calculate_skill_match(:student_id, o.id) m ON TRUE
  WHERE o.id = :opportunity_id;
  ```
* **Status Codes:** `200 OK`, `404 Not Found`.

---

#### `POST /api/v1/companies/me/opportunities`
* **Purpose:** Employer publishes a new internship or job opening with skill requirements.
* **Target Tables:** `opportunities`, `opportunity_skills`
* **Transaction Workflow:**
  ```sql
  BEGIN;

  -- 1. Insert Opportunity
  INSERT INTO opportunities (
      company_id, title, opportunity_type, work_mode, location, stipend_amount, 
      duration_months, openings_count, description, requirements, application_deadline, status
  ) VALUES (
      :company_id, :title, :type, :work_mode, :location, :stipend, 
      :duration, :openings, :description, :requirements, :deadline, 'active'
  ) RETURNING id INTO :opportunity_id;

  -- 2. Insert Required Skills
  INSERT INTO opportunity_skills (opportunity_id, skill_id, is_mandatory, min_proficiency, skill_weight)
  VALUES (:opportunity_id, :skill_id, :is_mandatory, :min_proficiency, :weight);

  COMMIT;
  ```
* **Status Codes:** `201 Created`, `400 Bad Request`.

---

### 2.5 Applications & Recruiter Pipeline

#### `POST /api/v1/opportunities/{id}/applications`
* **Purpose:** Student applies for an opportunity.
* **Target Tables:** `applications`, `application_status_history`, `calculate_skill_match()`
* **Transaction Workflow:**
  ```sql
  BEGIN;

  -- 1. Calculate live match score
  SELECT match_score INTO :score FROM calculate_skill_match(:student_id, :opportunity_id);

  -- 2. Insert Application
  INSERT INTO applications (
      opportunity_id, student_id, resume_id, cover_letter, match_score, status
  ) VALUES (
      :opportunity_id, :student_id, :resume_id, :cover_letter, :score, 'APPLIED'
  ) RETURNING id INTO :application_id;

  -- 3. Record Initial History Audit Entry
  INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks)
  VALUES (:application_id, NULL, 'APPLIED', :auth_user_id, 'Application submitted by student.');

  COMMIT;
  ```
* **Status Codes:** `201 Created`, `409 Conflict` (if student has already applied, triggered by `uq_student_opportunity`).

---

#### `GET /api/v1/students/me/applications`
* **Purpose:** Student tracking all their submitted applications and statuses.
* **Target Tables:** `applications`, `opportunities`, `company_profiles`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      a.id AS application_id,
      a.status,
      a.match_score,
      a.applied_at,
      o.id AS opportunity_id,
      o.title AS opportunity_title,
      cp.company_name,
      cp.logo_url
  FROM applications a
  JOIN opportunities o ON a.opportunity_id = o.id
  JOIN company_profiles cp ON o.company_id = cp.id
  JOIN student_profiles sp ON a.student_id = sp.id
  WHERE sp.user_id = :auth_user_id
  ORDER BY a.applied_at DESC;
  ```
* **Status Codes:** `200 OK`.

---

#### `GET /api/v1/companies/me/opportunities/{id}/applicants`
* **Purpose:** Recruiter viewing ranked applicants ordered by match score.
* **Target Tables:** `applications`, `student_profiles`, `institutions`, `resumes`
* **Underlying SQL Query:**
  ```sql
  SELECT 
      a.id AS application_id,
      a.match_score,
      a.status,
      a.applied_at,
      sp.id AS student_id,
      sp.first_name,
      sp.last_name,
      sp.cgpa,
      sp.department,
      inst.name AS college_name,
      r.file_url AS resume_url
  FROM applications a
  JOIN student_profiles sp ON a.student_id = sp.id
  JOIN institutions inst ON sp.institution_id = inst.id
  LEFT JOIN resumes r ON a.resume_id = r.id
  WHERE a.opportunity_id = :opportunity_id
  ORDER BY a.match_score DESC, a.applied_at ASC;
  ```
* **Status Codes:** `200 OK`, `403 Forbidden` (if opportunity does not belong to the logged-in company).

---

### 2.6 Skill Verification & Interviews

#### `POST /api/v1/verification/skills/{id}`
* **Purpose:** Faculty member endorses and verifies a student's skill.
* **Target Tables:** `skill_verifications`, `student_skills`, `teacher_profiles`
* **Transaction Workflow:**
  ```sql
  BEGIN;

  -- 1. Insert Verification Record
  INSERT INTO skill_verifications (
      student_skill_id, verifier_teacher_id, verification_source, certificate_id, status, comments
  ) VALUES (
      :student_skill_id, :teacher_profile_id, 'teacher_endorsement', :certificate_id, 'approved', :comments
  );

  -- 2. Mark Student Skill as Verified
  UPDATE student_skills
  SET is_verified = TRUE, updated_at = NOW()
  WHERE id = :student_skill_id;

  COMMIT;
  ```
* **Status Codes:** `200 OK`, `403 Forbidden` (if user is not an authorized teacher).

---

#### `POST /api/v1/interviews/slots`
* **Purpose:** Company creates calendar interview slots.
* **Target Tables:** `interview_slots`
* **Underlying SQL Query:**
  ```sql
  INSERT INTO interview_slots (company_id, start_time, end_time)
  VALUES (:company_id, :start_time, :end_time)
  RETURNING *;
  ```
* **Status Codes:** `201 Created`.

---

#### `POST /api/v1/interviews/{id}/book`
* **Purpose:** Transaction-safe booking of an interview slot by an applicant.
* **Target Tables:** `interview_slots`, `interviews`, `applications`, `application_status_history`
* **Transaction Workflow (Prevents Race Conditions):**
  ```sql
  BEGIN;

  -- 1. Lock and verify slot is available
  SELECT id FROM interview_slots 
  WHERE id = :slot_id AND is_booked = FALSE 
  FOR UPDATE;

  -- 2. Mark Slot as Booked
  UPDATE interview_slots 
  SET is_booked = TRUE 
  WHERE id = :slot_id;

  -- 3. Create Confirmed Interview
  INSERT INTO interviews (application_id, slot_id, scheduled_time, meeting_url, status)
  VALUES (:application_id, :slot_id, :start_time, :meeting_link, 'scheduled');

  -- 4. Advance Application Status
  UPDATE applications 
  SET status = 'INTERVIEW_SCHEDULED', updated_at = NOW() 
  WHERE id = :application_id;

  -- 5. Audit History
  INSERT INTO application_status_history (application_id, old_status, new_status, changed_by_user_id, remarks)
  VALUES (:application_id, 'SHORTLISTED', 'INTERVIEW_SCHEDULED', :auth_user_id, 'Candidate confirmed interview slot.');

  COMMIT;
  ```
* **Status Codes:** `200 OK`, `409 Conflict` (slot was already booked by another applicant).

---

#### `POST /api/v1/applications/{id}/feedback`
* **Purpose:** Recruiter submits post-interview ratings and qualitative review.
* **Target Tables:** `feedback`, `applications`
* **Underlying SQL Query:**
  ```sql
  INSERT INTO feedback (
      application_id, submitted_by_user_id, rating, technical_score, communication_score, strengths, improvements
  ) VALUES (
      :application_id, :auth_user_id, :rating, :technical_score, :communication_score, :strengths, :improvements
  ) RETURNING *;
  ```
* **Status Codes:** `201 Created`.

---

## 3. Student Learning Corner: API-Database Contracts

> [!NOTE]
> ### Student Learning Corner: What, Why, and How
> 
> **WHAT is an API-Database Contract?**  
> An API-Database Contract is an exact agreement between the frontend, backend, and database developers defining:  
> *When the frontend sends `POST /api/v1/opportunities/{id}/applications`, what exact SQL queries execute inside PostgreSQL?*
> 
> **WHY do we use `BEGIN` and `COMMIT` (Transactions)?**  
> Notice in `POST /api/v1/interviews/{id}/book`: We have 5 steps:
> 1. Lock the slot (`FOR UPDATE`).
> 2. Mark it booked.
> 3. Insert the interview.
> 4. Update the application status.
> 5. Insert history.
> If the server loses power during Step 3, without a transaction, the slot would be booked but no interview record would exist! By wrapping them in `BEGIN` and `COMMIT`, PostgreSQL guarantees **Atomicity**: either all 5 steps succeed together, or nothing changes at all!
