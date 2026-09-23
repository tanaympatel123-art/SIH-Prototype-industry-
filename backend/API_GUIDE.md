# SIH26044 Backend – API Reference Guide

Base URL: `http://localhost:5000/api/v1`

---

## Quick Start

```bash
# 1. Copy and configure env
cp .env.example .env

# 2. Install dependencies
npm install

# 3. Start dev server (requires XAMPP MySQL running with sih26044_db imported)
npm run dev
```

---

## Authentication

All protected routes require `Authorization: Bearer <token>` header.

### Register

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Alice Student",
    "email": "alice@college.edu",
    "password": "password123",
    "role_name": "student",
    "department": "Computer Science",
    "year_of_study": 3
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "eyJhbGci...",
  "user": { "id": 9, "full_name": "Alice Student", "email": "alice@college.edu", "role": "student" }
}
```

### Login (Seed Data)

All Phase 1 seed users have password: `password123`

```bash
# Student login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "alice@college.edu", "password": "password123" }'

# Teacher login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "teacher@college.edu", "password": "password123" }'

# Company login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "hr@techcorp.com", "password": "password123" }'
```

---

## Student Portal Endpoints

> Requires: `Authorization: Bearer <student_token>`

### Get Dashboard
```bash
curl http://localhost:5000/api/v1/student/dashboard \
  -H "Authorization: Bearer <TOKEN>"
```
**Response:**
```json
{
  "success": true,
  "dashboard": {
    "total_skills": 7,
    "verified_skills": 3,
    "total_applications": 2,
    "open_opportunities": 14
  }
}
```

### Add a Skill (Self-Declared)
```bash
curl -X POST http://localhost:5000/api/v1/student/skills \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "skill_id": 3, "proficiency_level": 3 }'
```

### Generate AI Quiz
```bash
curl "http://localhost:5000/api/v1/student/quiz/generate?skill_id=3&difficulty=intermediate" \
  -H "Authorization: Bearer <TOKEN>"
```

### Submit Quiz
```bash
curl -X POST http://localhost:5000/api/v1/student/quiz/submit \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "skill_id": 3, "score": 75, "total_questions": 10, "correct_answers": 7 }'
```

### Generate AI Resume
```bash
curl -X POST http://localhost:5000/api/v1/student/resume/generate \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "target_role": "Backend Developer" }'
```
**Response (AI online):**
```json
{
  "success": true,
  "resume": {
    "source": "ai",
    "professional_summary": "Motivated Backend Developer with verified expertise...",
    "bullet_points": ["Engineered RESTful APIs using Node.js..."]
  }
}
```
**Response (AI offline – fallback):**
```json
{
  "success": true,
  "resume": {
    "source": "fallback",
    "professional_summary": "Alice Student – Backend Developer candidate...",
    "bullet_points": ["Proficient in Node.js (quiz-verified).", "Proficient in MySQL (quiz-verified)."],
    "skills": ["Node.js", "MySQL", "JavaScript"]
  }
}
```

### Skill Gap Analysis
```bash
curl "http://localhost:5000/api/v1/student/skill-gap?target_role=backend+developer" \
  -H "Authorization: Bearer <TOKEN>"
```

### Browse Opportunities
```bash
# All active
curl http://localhost:5000/api/v1/opportunities

# Filter by type and search
curl "http://localhost:5000/api/v1/opportunities?type=internship&search=react&page=1&limit=10"
```

### Apply to Opportunity
```bash
curl -X POST http://localhost:5000/api/v1/applications \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "opportunity_id": 1,
    "cover_note": "I am excited to apply for this role..."
  }'
```
**Response includes MatchScore:**
```json
{
  "success": true,
  "message": "Application submitted successfully",
  "match_info": {
    "match_percentage": 72,
    "match_breakdown": {
      "matched_skills": ["JavaScript", "React.js"],
      "missing_skills": ["TypeScript"],
      "explanation": "Good match: covers most requirements. Missing: TypeScript."
    }
  }
}
```

---

## Company Portal Endpoints

> Requires: `Authorization: Bearer <company_token>`

### Post an Opportunity
```bash
curl -X POST http://localhost:5000/api/v1/company/opportunities \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "React.js Intern",
    "description": "Build UI components for our SaaS product.",
    "type": "internship",
    "location": "Remote",
    "stipend": "15000",
    "duration": "3 months",
    "application_deadline": "2026-10-31",
    "required_skills": [1, 3],
    "optional_skills": [7]
  }'
```

### Get Applicants with Match Scores (Ranked)
```bash
curl http://localhost:5000/api/v1/company/opportunities/1/applicants \
  -H "Authorization: Bearer <TOKEN>"
```
**Response:**
```json
{
  "success": true,
  "applicants": [
    {
      "application_id": 5,
      "full_name": "Bob Student",
      "match_percentage": 88,
      "match_breakdown": {
        "matched_skills": ["React.js", "JavaScript", "Git"],
        "missing_skills": ["TypeScript"],
        "scores": { "skills_score": 85, "quiz_score": 80, "verified_bonus": 100 },
        "explanation": "Excellent match: 3 required skills present with 2 verified credentials."
      }
    }
  ]
}
```

### Update Application Pipeline Status
```bash
curl -X PUT http://localhost:5000/api/v1/company/applications/5/status \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "status": "shortlisted" }'
```

---

## Teacher Portal Endpoints

> Requires: `Authorization: Bearer <teacher_token>`

### Get Pending Verifications Queue
```bash
curl http://localhost:5000/api/v1/teacher/verifications/pending \
  -H "Authorization: Bearer <TOKEN>"
```

### Approve a Verification
```bash
curl -X POST http://localhost:5000/api/v1/teacher/verifications/1/approve \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "notes": "Certificate verified against Coursera records. Approved." }'
```

### Reject a Verification
```bash
curl -X POST http://localhost:5000/api/v1/teacher/verifications/2/reject \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "notes": "Certificate appears altered. Name does not match enrollment records." }'
```

### Get Institution Analytics
```bash
curl http://localhost:5000/api/v1/teacher/analytics \
  -H "Authorization: Bearer <TOKEN>"
```
**Response:**
```json
{
  "analytics": {
    "verificationStats": [
      { "status": "approved", "count": 12 },
      { "status": "pending", "count": 5 },
      { "status": "rejected", "count": 2 }
    ],
    "atRiskStudents": 8,
    "departmentStats": [...]
  }
}
```

---

## AI Service Endpoints

### Check AI Service Status
```bash
curl http://localhost:5000/api/v1/ai/status \
  -H "Authorization: Bearer <TOKEN>"
```
**Response when AI is offline (system still fully functional):**
```json
{ "success": true, "ai_service": { "status": "offline", "failures": 3 } }
```

---

## MatchScore Formula Reference

```
MatchScore = 0.50 × S_skills
           + 0.20 × S_eligibility   (default 1.0 until eligibility fields added)
           + 0.15 × S_quiz          (from quiz-sourced proficiency_level)
           + 0.10 × S_experience    (project/certificate skills)
           + 0.05 × S_verified_bonus (teacher-approved skills)
```

---

## Error Response Format

All errors follow this format:
```json
{
  "success": false,
  "message": "Human-readable error description",
  "errors": [{ "field": "email", "message": "Invalid email address" }]
}
```

| Status | Meaning |
|--------|---------|
| 400 | Bad request / business rule violation |
| 401 | Unauthenticated (no/invalid token) |
| 403 | Unauthorized (wrong role) |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 422 | Validation failed |
| 500 | Internal server error |
