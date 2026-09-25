# SIH 26044: Centralized Academia–Industry Collaboration Portal
## Production-Grade Enterprise Functional & Technical System Architecture
### Problem Statement ID: 26044 | Ministry of Ayush & AIIA / Multi-Disciplinary Framework

---

## EXECUTIVE ARCHITECTURAL SUMMARY

This document defines the production software architecture for **SIH 26044 — Academia–Industry Collaboration Portal for Skill Mapping, Internships, and Placement**. 

The system bridges academia (students, researchers, faculty) and industry (corporate recruiters, clinical/manufacturing partners, startups) through automated skill benchmarking, teacher-verified credentials, AI-driven applicant ranking, and dynamic skill-gap remediation mapped directly to national curricula (NPTEL / SWAYAM / AYUSH repositories).

```
+---------------------------------------------------------------------------------------------------+
|                                       PRESENTATION TIER                                            |
|   React 18 SPA + TypeScript + Vite + Tailwind CSS + Shadcn UI + Lucide Icons + TanStack Query     |
+---------------------------------------------------------------------------------------------------+
                                                 │  HTTPS / REST (JSON) + Pre-signed URLs
                                                 ▼
+---------------------------------------------------------------------------------------------------+
|                                     API & SECURITY GATEWAY                                        |
|   Reverse Proxy (NGINX / Vercel Edge) | Helmet Security Headers | CORS | Token Bucket Rate Limit  |
+---------------------------------------------------------------------------------------------------+
                                                 │
                                                 ▼
+---------------------------------------------------------------------------------------------------+
|                                     CORE BACKEND SERVICES                                         |
|   Node.js v20 LTS + Express.js + TypeScript                                                        |
|   • Auth & RBAC (JWT + bcrypt)            • Application Pipeline (State Machine)                  |
|   • Portfolio & Verification Engine       • Interview Scheduler & ICS Generator                    |
|   • Cloudinary File Ingestion Service     • Resume PDF Generator (Puppeteer/HTML5)                |
+---------------------------------------------------------------------------------------------------+
                         │                                           │
       Prisma ORM (SQL)  │                                           │ Internal REST (mTLS / HMAC)
                         ▼                                           ▼
+------------------------------------+      +-------------------------------------------------------+
|          DATABASE TIER             |      |                     AI / ML TIER                      |
|   PostgreSQL 16 Relational Engine  |      |   Python 3.11 + FastAPI + Uvicorn                     |
|   • Strict ACID Transactions       |      |   • SentenceTransformers (all-MiniLM-L6-v2)           |
|   • Prisma Migration & Type Safety |      |   • Scikit-learn Multi-Factor Applicant Ranking       |
|   • Relational Integrity & Cascades|      |   • Resume Skill Extraction (spaCy NLP + Regex)       |
|   • B-Tree & Compound Indexing     |      |   • NPTEL/SWAYAM Vector Skill Gap Recommendation     |
+------------------------------------+      +-------------------------------------------------------+
                         ▲                                           │
                         │                                           │
                         +───────────────────────────────────────────+
                                Caching & Vector Cache (Redis)
```

---

# SECTION 1 — Complete Technical Architecture

### 1.1 Layered Architecture: Database → AI/ML → Backend → Frontend → Testing

```mermaid
flowchart TD
    subgraph Data_Layer ["1. Persistence Layer (Database)"]
        PG[(PostgreSQL 16)]
        PrismaClient["Prisma ORM Client (Type-Safe Query Builder)"]
        PG <--> PrismaClient
    end

    subgraph AI_Layer ["2. Intelligence Tier (FastAPI AI Microservice)"]
        FastAPIApp["FastAPI Engine (Port 8000)"]
        NLP_Model["Sentence-Transformers (all-MiniLM-L6-v2)"]
        Scikit_Rank["Scikit-Learn Multi-Attribute Ranker"]
        Gap_Engine["NPTEL / SWAYAM Skill Gap Matcher"]
        FastAPIApp --> NLP_Model
        FastAPIApp --> Scikit_Rank
        FastAPIApp --> Gap_Engine
    end

    subgraph Backend_Layer ["3. Business Logic Tier (Node.js + Express)"]
        ExpressApp["Express API Server (Port 5000)"]
        AuthMiddleware["JWT RBAC Guard"]
        Controllers["Controller Layer"]
        Services["Service Layer"]
        CloudinaryService["Cloudinary Media Client"]
        
        ExpressApp --> AuthMiddleware
        AuthMiddleware --> Controllers
        Controllers --> Services
        Services <--> PrismaClient
        Services <--> CloudinaryService
    end

    subgraph Comm_Channel ["Internal Inter-Service Protocol"]
        Services <== "HTTP/2 REST (HMAC Auth / JSON Payload)" ==> FastAPIApp
    end

    subgraph Frontend_Layer ["4. Presentation Tier (React + Vite SPA)"]
        Router["React Router v6"]
        AuthContext["Auth / Role Context (Zustand)"]
        QueryClient["TanStack Query Cache"]
        AxiosClient["Axios Interceptor Instance"]
        UI_Components["Shadcn UI + Tailwind Pages"]

        Router --> AuthContext
        AuthContext --> QueryClient
        QueryClient --> AxiosClient
        AxiosClient <== "HTTPS / Bearer Token" ==> ExpressApp
        QueryClient --> UI_Components
    end

    subgraph Testing_Layer ["5. Quality & Verification Tier"]
        UnitTests["Vitest + Pytest"]
        IntegrationTests["Supertest API Contract Tests"]
        E2ETests["Playwright Browser Workflows"]
        CICD["GitHub Actions Gatekeeper"]
        
        UnitTests -.-> Frontend_Layer
        UnitTests -.-> Backend_Layer
        UnitTests -.-> AI_Layer
        IntegrationTests -.-> ExpressApp
        IntegrationTests -.-> FastAPIApp
        E2ETests -.-> UI_Components
        CICD ==> MainBranch["Protected 'main' Branch"]
    end
```

#### Detailed Layer Traversal Explanation

1. **How Data Starts from the Database:**
   - PostgreSQL 16 serves as the single source of operational truth. Tables are defined with strict foreign key constraints, composite unique indexes (e.g., `[student_id, skill_id]`), check constraints, and enum types (`Role`, `ApplicationStatus`, `VerificationStatus`).
   - Every read and write transaction is mediated through Prisma ORM v5, which generates type-safe TypeScript interfaces from `schema.prisma`. Prepared statements guard against SQL injection, and read replicas handle high-throughput query spikes.

2. **How the Backend Accesses It:**
   - Node.js (v20 LTS) with Express.js accesses the database through a dedicated `prisma.service.ts` singleton maintaining an active connection pool (min: 5, max: 20 connections).
   - Domain operations are isolated within service modules (`InternshipService`, `ApplicationService`, `VerificationService`). Transactions requiring atomic updates (e.g., submitting an application and incrementing applicant counts) use `prisma.$transaction([ ... ])` at the `READ COMMITTED` isolation level.

3. **How AI Consumes Data:**
   - The AI layer is decoupled as a high-performance Python 3.11 FastAPI microservice running on port 8000.
   - When an event requires machine intelligence (e.g., calculating applicant rankings, generating skill gap recommendations), the Express service executes an internal authenticated HTTP request (`POST /ai/rank-applicants`, `POST /ai/skill-gap`) sending sanitized JSON payloads.
   - The AI service loads pre-computed vector embeddings (`SentenceTransformers: all-MiniLM-L6-v2`) in memory, executes Cosine Similarity and MinMax normalization, and returns deterministic ranking structures within sub-120ms latency.

4. **How Frontend Receives APIs:**
   - The React 18 single-page application consumes backend routes via an Axios client configured with an automatic request/response interceptor (`src/services/api/client.ts`).
   - TanStack Query v5 manages client-side caching, background revalidation, stale-time thresholds, and optimistic updates.
   - Responses are strictly typed using shared TypeScript schemas. Dynamic notifications (such as status updates or interview schedules) trigger cache invalidations via `queryClient.invalidateQueries()`.

5. **How Testing Validates the Entire Flow:**
   - **Unit Testing:** Vitest verifies React hooks and utility functions; Jest/Vitest tests Node.js controller logic and Zod validation schemas; Pytest tests FastAPI endpoints and similarity math.
   - **Integration Testing:** Supertest spins up ephemeral Express instances connected to a test PostgreSQL container to test authenticated API routes.
   - **E2E Testing:** Playwright tests complete browser workflows (Registration → Profile Builder → Quiz Completion → Application → Recruiter Ranking → Interview Schedule).
   - All tests run automatically in GitHub Actions CI prior to merge approval.

---

### 1.2 Comprehensive Request-Response Lifecycles

```
+----------------------------------------------------------------------------------------------------+
| SERVICE INTERCONNECTION MATRIX                                                                     |
+------------------------+------------------------+------------------+-------------------------------+
| Source Service         | Target Service         | Protocol / Port  | Authentication / Security     |
+------------------------+------------------------+------------------+-------------------------------+
| Client (Browser)       | Reverse Proxy / Edge   | HTTPS / 443      | TLS 1.3, HSTS                 |
| Reverse Proxy          | Express Backend        | HTTP/1.1 / 5000  | Header Forwarding, IP-Whitel. |
| Express Backend        | PostgreSQL DB          | TCP / 5432       | SCRAM-SHA-256, SSL Encrypted  |
| Express Backend        | FastAPI AI Microserv.  | HTTP/2 / 8000    | Internal Token / HMAC Secret  |
| Express Backend        | Cloudinary CDN         | HTTPS / 443      | API Key & Secret Signature    |
| Express Backend        | SMTP / Webhook Server  | TLS / 587        | SMTP Auth / OAuth2            |
+------------------------+------------------------+------------------+-------------------------------+
```

#### Flow 1: Authentication & Token Lifecycle
1. **Client** dispatches `POST /api/v1/auth/login` with `{ email, password }`.
2. **Express Auth Controller** runs Zod validation schema.
3. **Auth Service** queries PostgreSQL through Prisma for `User` by unique `email`.
4. Password hash evaluated against `password_hash` via `bcrypt.compare()` (cost factor 12).
5. On match, Auth Service issues dual tokens:
   - **Access Token:** Short-lived JWT (15-minute expiration) containing `{ userId, role, email }` in the payload, signed with `JWT_SECRET` (RS256/HS256).
   - **Refresh Token:** Long-lived cryptographically random UUID (7-day expiration) stored hashed in the DB `RefreshTokens` table and set in an `httpOnly`, `Secure`, `SameSite=Strict` cookie.
6. **Frontend** stores access token in memory/Zustand state; Axios interceptor injects `Authorization: Bearer <token>` into all subsequent outbound requests.

#### Flow 2: Internship Posting Lifecycle
1. **Company Recruiter** fills internship form on `/company/post-internship` (title, role description, stipend, required skills, eligibility CGPA, location, mode).
2. React dispatches `POST /api/v1/internships`.
3. Express verifies `Role === 'COMPANY'` via `authorize(['COMPANY'])` middleware.
4. Payload passed to `InternshipService.create()`:
   - Matches raw skill strings against master `Skills` table; creates missing skills dynamically or maps to canonical taxonomy.
   - Persists `Internship` record and relational `InternshipSkills` join records within a Prisma atomic transaction.
5. Returns `201 Created` with full internship object.
6. Background hook dispatches internship text to FastAPI `/ai/embed-internship` to pre-calculate and cache the semantic requirement vector in Redis.

#### Flow 3: Student Application Lifecycle
1. **Student** views listing on `/student/internships/:id` and clicks **"One-Click Apply"**.
2. React dispatches `POST /api/v1/applications` with `{ internshipId }`.
3. Express checks student eligibility:
   - Verifies profile completion percentage $\ge 70\%$.
   - Confirms student CGPA meets `Internship.minCgpa`.
   - Prevents duplicate applications via unique constraint `[internship_id, student_id]`.
4. Application created with status `APPLIED`.
5. Express fires an asynchronous event to the AI service to recalculate ranking for that specific internship candidate pool.
6. Returns `201 Created` with application reference and live tracking status.

#### Flow 4: AI Ranking Lifecycle
1. **Company** opens `/company/internships/:id/applicants`.
2. Express checks cached rankings in Redis. If stale or absent:
   - Fetches candidate dataset: `[Student Profile, CGPA, Verified Badges, Quiz Scores, Resume Text]`.
   - Fetches internship requirements: `[Required Skills, Domain, Minimum CGPA, Scope]`.
   - Calls FastAPI `POST /ai/rank-applicants` with batch payload.
3. **FastAPI Engine**:
   - Computes Cosine Similarity between candidate embedding and job description embedding ($S_{semantic}$).
   - Computes Verified Skill Match Ratio ($S_{skill}$).
   - Computes Assessment Score Index ($S_{quiz}$).
   - Computes Academic Normalization Score ($S_{cgpa}$).
   - Executes Composite Formula:
     $$\text{Final Score} = (0.40 \times S_{semantic}) + (0.25 \times S_{skill}) + (0.20 \times S_{quiz}) + (0.15 \times S_{cgpa})$$
   - Returns ranked array of `{ studentId, matchPercentage, breakdown }`.
4. Express saves `ai_match_score` into `applications` table and returns sorted results to Company UI.

#### Flow 5: Interview Scheduling Lifecycle
1. **Company** selects shortlisted applicant and submits `POST /api/v1/interviews/schedule` with `{ applicationId, scheduledTime, durationMins, meetingLink, notes }`.
2. Express validates time collision: checks if student or company interviewer already has an `INTERVIEW` scheduled in that window.
3. Database transaction:
   - Inserts row into `interviews` table with status `SCHEDULED`.
   - Updates `applications.status` to `INTERVIEW_SCHEDULED`.
4. Express fires calendar generator utility (`ics`) and dispatches transactional confirmation emails to both student and recruiter with Google Calendar / Outlook `.ics` attachments.
5. Real-time notification dispatched to student dashboard.

#### Flow 6: Teacher Skill & Certificate Verification Lifecycle
1. **Student** completes an external certification (e.g., Coursera, NPTEL) or requests manual verification of a specialized skill; uploads PDF/image proof to `/student/portfolio/upload`.
2. Frontend sends multipart form to Express; `CloudinaryService` streams file directly to secure storage and returns signed URL.
3. Express writes to `certificates` table with status `PENDING`.
4. **Teacher** logs in, visits `/teacher/verifications`, and views pending student submissions from their department.
5. Teacher inspects uploaded credential document via pre-signed Cloudinary viewer and clicks **"Approve & Badge"**.
6. Express dispatches `PATCH /api/v1/teachers/verifications/:id` with `{ action: 'APPROVE', badgeLevel: 'INTERMEDIATE' }`:
   - Updates `certificates.verification_status` to `VERIFIED`.
   - Creates a record in `verified_skills` table (`verified_by_type = 'TEACHER'`, `verified_by_id = teacherId`).
   - Increments student's `profile_completion_pct`.
7. Student dashboard instantly renders verified skill badge with cryptographic/teacher verification watermark.

---

# SECTION 2 — System Flow Diagrams

### Diagram 1: Overall System Architecture

```mermaid
flowchart TB
    subgraph Clients ["Client Layer (Web Browsers)"]
        S_UI["Student Web Portal"]
        C_UI["Company Web Portal"]
        T_UI["Teacher Web Portal"]
    end

    subgraph CDN_Edge ["Edge Delivery & Security Layer"]
        VercelCDN["Vercel Global Edge CDN"]
        ReverseProxy["NGINX / Edge Gateway<br/>(Rate Limiting | SSL Offloading | CORS)"]
    end

    subgraph App_Server ["Core Backend Application (Node.js / Express)"]
        API_Router["Express API Gateway Router (/api/v1)"]
        Auth_Mod["Auth & RBAC Subsystem"]
        Student_Mod["Student & Portfolio Subsystem"]
        Intern_Mod["Internship & ATS Subsystem"]
        Teacher_Mod["Teacher Verification Subsystem"]
        Media_Mod["Cloudinary Ingestion Subsystem"]
    end

    subgraph AI_Server ["Machine Learning Microservice (FastAPI / Python)"]
        AI_Gateway["FastAPI ASGI App"]
        SBERT_Worker["Sentence-BERT Embeddings Engine"]
        Matcher_Worker["Vector Cosine Similarity & Ranker"]
        Gap_Worker["NPTEL/SWAYAM Recommendation Engine"]
        Resume_Worker["NLP Resume Parsing Engine"]
    end

    subgraph Data_Storage ["Enterprise Persistence Layer"]
        PostgreSQL[("PostgreSQL 16 Database<br/>(Users, Profiles, Applications, Quizzes)")]
        RedisCache[("Redis 7 In-Memory Cache<br/>(Sessions, Cached Embeddings, Job Queues)")]
        CloudinaryVault[("Cloudinary Media Cloud<br/>(Certificates, PDF Resumes, Profile Avatars)")]
    end

    S_UI & C_UI & T_UI --> VercelCDN
    VercelCDN --> ReverseProxy
    ReverseProxy --> API_Router

    API_Router --> Auth_Mod
    API_Router --> Student_Mod
    API_Router --> Intern_Mod
    API_Router --> Teacher_Mod
    API_Router --> Media_Mod

    Auth_Mod & Student_Mod & Intern_Mod & Teacher_Mod <--> PostgreSQL
    Intern_Mod & Student_Mod <--> RedisCache
    Media_Mod <--> CloudinaryVault

    Intern_Mod & Student_Mod <== "Internal REST / JSON" ==> AI_Gateway
    AI_Gateway --> SBERT_Worker
    AI_Gateway --> Matcher_Worker
    AI_Gateway --> Gap_Worker
    AI_Gateway --> Resume_Worker
```

---

### Diagram 2: Authentication Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as User (Student/Company/Teacher)
    participant UI as React Frontend
    participant API as Express Auth Router
    participant AuthServ as AuthService
    participant DB as PostgreSQL (Users Table)
    participant Cookie as Browser Cookie Vault

    User->>UI: Enters Email & Password
    UI->>API: POST /api/v1/auth/login { email, password }
    API->>AuthServ: validateCredentials(email, password)
    AuthServ->>DB: findUnique({ where: { email } })
    DB-->>AuthServ: User record (with password_hash, role, is_verified)
    
    alt User Not Found or Inactive
        AuthServ-->>API: Throw InvalidCredentialsException
        API-->>UI: 401 Unauthorized { message: "Invalid credentials" }
        UI-->>User: Displays error alert
    else Password Match Verified
        AuthServ->>AuthServ: bcrypt.compare(password, password_hash)
        AuthServ->>AuthServ: generateAccessToken(payload, '15m')
        AuthServ->>AuthServ: generateRefreshToken(payload, '7d')
        AuthServ->>DB: storeHashedRefreshToken(userId, token)
        AuthServ-->>API: { accessToken, refreshToken, userProfile }
        API->>Cookie: Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict
        API-->>UI: 200 OK { accessToken, user: { id, email, role, name } }
        UI->>UI: Store accessToken in Zustand Memory State
        UI->>User: Redirects to Role-Specific Dashboard
    end
```

---

### Diagram 3: AI Matching Flow

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant UI as Student Portal
    participant NodeAPI as Express Backend
    participant DB as PostgreSQL
    participant AI as FastAPI Matching Engine
    participant Redis as Redis Cache

    Student->>UI: Navigates to Recommended Internships
    UI->>NodeAPI: GET /api/v1/students/recommended-internships
    NodeAPI->>Redis: Check cached recommendations (Key: recs:studentId)
    
    alt Cache Hit
        Redis-->>NodeAPI: Cached Internship IDs & Scores
        NodeAPI->>DB: Fetch internship metadata for IDs
        DB-->>NodeAPI: Hydrated internship objects
        NodeAPI-->>UI: 200 OK [ Recommended Internships ]
    else Cache Miss
        NodeAPI->>DB: Fetch Student Skills, Quiz Results, Bio & Target Roles
        DB-->>NodeAPI: Student Vector Features
        NodeAPI->>DB: Fetch Active Internships & Required Skills
        DB-->>NodeAPI: Active Job Pool
        NodeAPI->>AI: POST /ai/match-internships { studentProfile, jobPool }
        AI->>AI: S-BERT Vectorize(Student Profile)
        AI->>AI: S-BERT Vectorize(Job Requirements)
        AI->>AI: Compute Batch Cosine Similarities
        AI->>AI: Filter by Minimum Threshold (e.g. >= 50%)
        AI-->>NodeAPI: Sorted [{ internshipId, matchScore, matchedSkills, missingSkills }]
        NodeAPI->>Redis: Store in Redis (TTL: 3600s)
        NodeAPI-->>UI: 200 OK [ Recommended Internships with Match % ]
    end
    UI-->>Student: Displays ranked list with AI Compatibility Badges
```

---

### Diagram 4: Internship Application Flow

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant UI as Student Portal
    participant API as Express API
    participant DB as PostgreSQL
    participant AI as FastAPI Ranking Engine
    actor Recruiter as Company Recruiter

    Student->>UI: Clicks "Apply Now" on Internship
    UI->>API: POST /api/v1/applications { internshipId }
    API->>DB: Query Student Profile (CGPA, Badges, Profile %)
    DB-->>API: Student Data
    API->>API: Validate Eligibility (CGPA >= MinCriteria && Profile >= 70%)
    
    alt Ineligible
        API-->>UI: 403 Forbidden { reason: "CGPA below requirements or incomplete profile" }
        UI-->>Student: Shows eligibility guidance modal
    else Eligible
        API->>DB: INSERT INTO applications (status: 'APPLIED', student_id, internship_id)
        DB-->>API: Application Created (ID: app_101)
        API-->>UI: 201 Created { message: "Application submitted successfully", applicationId: "app_101" }
        UI-->>Student: Shows application tracking status
        
        Note over API,AI: Asynchronous Background Re-ranking
        API->>AI: POST /ai/rank-applicants { internshipId, newApplicantId }
        AI->>AI: Recalculate applicant pool percentiles
        AI-->>API: Updated applicant scores
        API->>DB: Batch update ai_match_score in applications table
        API->>Recruiter: Dispatches Webhook / Email Notification: "New Qualified Applicant"
    end
```

---

### Diagram 5: Interview Scheduling Flow

```mermaid
sequenceDiagram
    autonumber
    actor Recruiter as Company Recruiter
    participant C_UI as Company Portal
    participant API as Express API
    participant DB as PostgreSQL
    participant Mailer as Email & Calendar Engine
    actor Student
    participant S_UI as Student Portal

    Recruiter->>C_UI: Selects Candidate -> Clicks "Schedule Interview"
    Recruiter->>C_UI: Selects Date, Time, Duration & Enters Meeting Link
    C_UI->>API: POST /api/v1/interviews/schedule { applicationId, scheduledTime, duration, meetingLink }
    API->>DB: Check for interview collisions (Student & Recruiter schedule)
    
    alt Schedule Conflict Exists
        DB-->>API: Conflicting Interview Found
        API-->>C_UI: 409 Conflict { message: "Selected time slot collides with existing booking" }
    else Slot Free
        API->>DB: BEGIN TRANSACTION
        API->>DB: INSERT INTO interviews (application_id, scheduled_time, meeting_link, status: 'SCHEDULED')
        API->>DB: UPDATE applications SET status = 'INTERVIEW_SCHEDULED' WHERE id = applicationId
        API->>DB: COMMIT TRANSACTION
        DB-->>API: Transaction Confirmed
        
        API->>Mailer: generateICS(meetingTitle, scheduledTime, meetingLink)
        Mailer->>Student: Send Confirmation Email + .ics Calendar Invite
        Mailer->>Recruiter: Send Confirmation Email + .ics Calendar Invite
        API-->>C_UI: 201 Created { interviewId, status: 'SCHEDULED' }
        API->>S_UI: WebSocket / Push Event: "New Interview Scheduled"
        S_UI-->>Student: Renders Interview Banner with direct Join Link
    end
```

---

### Diagram 6: Teacher Verification Flow

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant S_UI as Student Portal
    participant API as Express API
    participant Cloudinary as Cloudinary CDN
    participant DB as PostgreSQL
    actor Teacher
    participant T_UI as Teacher Portal

    Student->>S_UI: Uploads NPTEL/Industry Certificate (PDF/Image)
    S_UI->>API: POST /api/v1/students/certificates (Multipart Form)
    API->>Cloudinary: Upload Document Stream
    Cloudinary-->>API: Secure Asset URL (https://res.cloudinary.com/...)
    API->>DB: INSERT INTO certificates (student_id, title, file_url, verification_status: 'PENDING')
    DB-->>API: Certificate Recorded
    API-->>S_UI: 201 Created { status: 'PENDING_VERIFICATION' }

    Teacher->>T_UI: Opens "Pending Student Verifications"
    T_UI->>API: GET /api/v1/teachers/verifications/pending
    API->>DB: Query Certificates WHERE verification_status = 'PENDING' AND student.department = teacher.department
    DB-->>API: List of pending certificates + student details
    API-->>T_UI: 200 OK [ Pending Certifications ]

    Teacher->>T_UI: Reviews document preview & clicks "Verify & Award Badge"
    T_UI->>API: PATCH /api/v1/teachers/verifications/:id { action: 'APPROVE', badgeLevel: 'ADVANCED' }
    API->>DB: BEGIN TRANSACTION
    API->>DB: UPDATE certificates SET verification_status = 'VERIFIED', verified_by = teacherId
    API->>DB: INSERT INTO verified_skills (student_id, skill_id, badge_level, verified_by_type: 'TEACHER')
    API->>DB: UPDATE students SET profile_completion_pct = profile_completion_pct + 10
    API->>DB: COMMIT TRANSACTION
    API-->>T_UI: 200 OK { message: "Badge successfully awarded" }
    API-->>Student: Real-time alert: "Skill Badge Awarded by Prof. X"
```

---

### Diagram 7: Resume Generation Flow

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant UI as Student Portal
    participant API as Express API
    participant DB as PostgreSQL
    participant HTMLtoPDF as Headless PDF Renderer (Puppeteer)
    participant Cloudinary as Cloudinary CDN

    Student->>UI: Selects Template (Modern/Academic/Technical) -> Clicks "Generate Resume"
    UI->>API: POST /api/v1/students/resume/generate { templateId: 'modern-ats' }
    API->>DB: Fetch Aggregated Data:
    Note over API,DB: Student Profile + Verified Skills + Quiz Scores + Completed Projects + Verified Certificates
    DB-->>API: Comprehensive Student Dossier
    
    API->>API: Populate Server-Side HTML5/Handlebars Template with Sanitized Data
    API->>HTMLtoPDF: Render Virtual DOM & Print to PDF Buffer (A4, Print CSS, Embed Watermark QR)
    HTMLtoPDF-->>API: Binary PDF Buffer
    
    API->>Cloudinary: Stream Buffer to Private Cloud Storage
    Cloudinary-->>API: Stored PDF URL (https://res.cloudinary.com/.../resume_101.pdf)
    API->>DB: UPSERT INTO resumes (student_id, template_id, pdf_url, raw_json)
    DB-->>API: Record Persisted
    API-->>UI: 200 OK { pdfUrl: "https://...", downloadUrl: "https://..." }
    UI-->>Student: Displays In-Browser Interactive PDF Preview + Download Button
```

---

# SECTION 3 — Technical Stack

| Tier | Technology | Selected Version | Architectural Justification |
| :--- | :--- | :--- | :--- |
| **Frontend UI** | **React** | `18.3+` | Declarative component model, Concurrent React capabilities, wide ecosystem compatibility, high render performance via Virtual DOM. |
| **Language (Web)** | **TypeScript** | `5.4+` | Strict static type safety across client and server prevents runtime type errors, guarantees API contract adherence, and boosts developer velocity. |
| **Styling** | **Tailwind CSS** | `3.4+` | Utility-first CSS eliminates bloated style sheets, enforces design token consistency, and enables rapid creation of responsive dashboards. |
| **Component Library** | **Shadcn UI + Radix UI** | Latest | Accessible, unstyled, fully customizable primitives that reside inside our codebase without proprietary runtime lock-in. |
| **Client Routing** | **React Router** | `v6.23+` | Declarative nested routing, client-side route guards, data loaders, and fine-grained URL synchronization for deep linking. |
| **Server State & Cache**| **TanStack Query (React Query)** | `v5.35+` | Eliminates manual `useEffect` fetching boilerplate; provides stale-while-revalidate caching, automatic deduplication, and optimistic mutations. |
| **Backend Runtime** | **Node.js** | `v20 LTS (Iron)` | High-performance asynchronous non-blocking event-driven runtime ideal for high-concurrency I/O operations and API mediation. |
| **Web Framework** | **Express.js** | `4.19+` | Minimalist, unopinionated, battle-tested HTTP layer allowing precise middleware composition for logging, rate limiting, validation, and RBAC. |
| **Authentication** | **JWT + bcryptjs** | `9.0+ / 2.4+` | Stateless access tokens for horizontal scale, paired with secure `httpOnly` refresh token rotation; bcryptjs with salt factor 12 prevents brute-force. |
| **Database** | **PostgreSQL** | `16.2` | Enterprise ACID compliance, robust relational integrity, JSONB support for unstructured quiz schemas, and mature indexing capabilities. |
| **ORM** | **Prisma ORM** | `5.13+` | Next-generation declarative schema management, automated migrations, auto-generated TypeScript client, and protection against SQL injection. |
| **AI Runtime** | **Python** | `3.11+` | Industry standard for machine learning, linear algebra operations, and NLP libraries with native C-extensions. |
| **AI Web Server** | **FastAPI** | `0.111+` | Asynchronous ASGI framework built on Starlette and Pydantic; sub-millisecond route dispatching, automated OpenAPI documentation, high concurrency. |
| **Vector Embeddings** | **Sentence-Transformers** | `all-MiniLM-L6-v2` | Ultra-lightweight (80MB), fast inference (14,200 sentences/sec on CPU), produces 384-dimensional dense semantic vectors optimized for text matching. |
| **Ranking & Math** | **Scikit-learn + NumPy** | `1.4+ / 1.26+` | Battle-tested implementations of Cosine Similarity, MinMax Normalization, TF-IDF vectorization, and deterministic composite ranking. |
| **Media / File Storage**| **Cloudinary** | REST API v2 | Enterprise-grade digital asset management, on-the-fly document watermarking, secure pre-signed delivery URLs, and automatic CDN optimization. |
| **PDF Generation** | **Puppeteer Core** | `22.6+` | Pixel-perfect headless Chrome PDF rendering ensures generated resumes exactly match CSS print specifications and embed verified QR codes. |
| **VCS & CI/CD** | **GitHub Actions** | Native | Centralized source control, branch protection enforcement, automated matrix testing on pull requests, and semantic release tagging. |
| **Frontend Hosting** | **Vercel** | Edge Network | Instant continuous deployment from Git, edge CDN caching, SSL automation, and optimal global latency for static React assets. |
| **Backend / AI Hosting**| **Render / Railway** | Containerized | Managed Docker runtime, environment variable secrets management, zero-downtime rolling deploys, and automated health check probes. |
| **Managed Database** | **Supabase / Neon / Render PG** | Cloud PG 16 | Serverless connection pooling (PgBouncer), automated daily backups, point-in-time recovery (PITR), and high-availability failover. |

---

# SECTION 4 — Database Design

### 4.1 PostgreSQL Complete Schema via Prisma (`schema.prisma`)

```prisma
// datasource and generator configuration
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

// ---------------------------------------------------------
// ENUMS
// ---------------------------------------------------------

enum Role {
  STUDENT
  COMPANY
  TEACHER
  ADMIN
}

enum ApplicationStatus {
  APPLIED
  SHORTLISTED
  INTERVIEW_SCHEDULED
  OFFERED
  REJECTED
  WITHDRAWN
}

enum VerificationStatus {
  PENDING
  VERIFIED
  REJECTED
}

enum WorkMode {
  REMOTE
  HYBRID
  ONSITE
}

enum BadgeLevel {
  BEGINNER
  INTERMEDIATE
  ADVANCED
  EXPERT
}

enum VerifierType {
  QUIZ
  TEACHER
  CERTIFICATE
}

enum InterviewStatus {
  SCHEDULED
  COMPLETED
  CANCELLED
  RESCHEDULED
}

enum ReviewerType {
  COMPANY
  STUDENT
}

// ---------------------------------------------------------
// CORE USER & ROLE MODELS
// ---------------------------------------------------------

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String    @map("password_hash")
  role          Role      @default(STUDENT)
  isVerified    Boolean   @default(false) @map("is_verified")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")

  // One-to-one relations by role
  studentProfile Student?
  companyProfile Company?
  teacherProfile Teacher?

  // Refresh token tracking
  refreshTokens  RefreshToken[]

  @@map("users")
}

model RefreshToken {
  id        String   @id @default(uuid())
  tokenHash String   @unique @map("token_hash")
  userId    String   @map("user_id")
  expiresAt DateTime @map("expires_at")
  createdAt DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("refresh_tokens")
}

model Student {
  id                   String   @id @default(uuid())
  userId               String   @unique @map("user_id")
  firstName            String   @map("first_name")
  lastName             String   @map("last_name")
  rollNumber           String   @unique @map("roll_number")
  collegeName          String   @map("college_name")
  branch               String
  graduationYear       Int      @map("graduation_year")
  cgpa                 Float
  bio                  String?  @db.Text
  avatarUrl            String?  @map("avatar_url")
  profileCompletionPct Int      @default(30) @map("profile_completion_pct")
  resumeUrl            String?  @map("resume_url")
  createdAt            DateTime @default(now()) @map("created_at")
  updatedAt            DateTime @updatedAt @map("updated_at")

  user                 User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // Relational mappings
  quizAttempts         QuizAttempt[]
  certificates         Certificate[]
  verifiedSkills       VerifiedSkill[]
  applications         Application[]
  resumes              Resume[]
  interviews           Interview[]
  feedbackGiven        Feedback[]

  @@index([collegeName, branch])
  @@map("students")
}

model Company {
  id                 String   @id @default(uuid())
  userId             String   @unique @map("user_id")
  companyName        String   @map("company_name")
  industry           String
  website            String?
  description        String?  @db.Text
  logoUrl            String?  @map("logo_url")
  location           String
  verificationStatus VerificationStatus @default(PENDING) @map("verification_status")
  createdAt          DateTime @default(now()) @map("created_at")
  updatedAt          DateTime @updatedAt @map("updated_at")

  user               User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  internships        Internship[]
  interviews         Interview[]

  @@map("companies")
}

model Teacher {
  id              String   @id @default(uuid())
  userId          String   @unique @map("user_id")
  firstName       String   @map("first_name")
  lastName        String   @map("last_name")
  department      String
  designation     String
  employeeId      String   @unique @map("employee_id")
  institutionName String   @map("institution_name")
  isApproved      Boolean  @default(false) @map("is_approved")
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  verifiedCertificates Certificate[]

  @@index([institutionName, department])
  @@map("teachers")
}

// ---------------------------------------------------------
// SKILL & ASSESSMENT MODELS
// ---------------------------------------------------------

model Skill {
  id          String   @id @default(uuid())
  name        String   @unique
  category    String   // e.g. "AYUSH_PHARMA", "WEB_DEV", "MACHINE_LEARNING", "DATA_ANALYSIS"
  description String?  @db.Text
  createdAt   DateTime @default(now()) @map("created_at")

  skillQuizzes      SkillQuiz[]
  verifiedSkills    VerifiedSkill[]
  internshipSkills  InternshipSkill[]
  learningResources LearningResource[]

  @@index([category])
  @@map("skills")
}

model SkillQuiz {
  id             String   @id @default(uuid())
  title          String
  skillId        String   @map("skill_id")
  totalMarks     Int      @default(100) @map("total_marks")
  passMarks      Int      @default(60) @map("pass_marks")
  timeLimitMins  Int      @default(30) @map("time_limit_mins")
  questionsJson  Json     @map("questions_json") // Array of { id, question, options, correctIndex }
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")

  skill          Skill    @relation(fields: [skillId], references: [id], onDelete: Cascade)
  attempts       QuizAttempt[]

  @@map("skill_quizzes")
}

model QuizAttempt {
  id          String    @id @default(uuid())
  studentId   String    @map("student_id")
  quizId      String    @map("quiz_id")
  score       Float
  percentage  Float
  passed      Boolean
  attemptedAt DateTime  @default(now()) @map("attempted_at")

  student     Student   @relation(fields: [studentId], references: [id], onDelete: Cascade)
  quiz        SkillQuiz @relation(fields: [quizId], references: [id], onDelete: Cascade)

  @@index([studentId, quizId])
  @@map("quiz_attempts")
}

model Certificate {
  id                 String             @id @default(uuid())
  studentId          String             @map("student_id")
  title              String
  issuingOrg         String             @map("issuing_org")
  issueDate          DateTime           @map("issue_date")
  credentialUrl      String?            @map("credential_url")
  fileUrl            String             @map("file_url")
  verificationStatus VerificationStatus @default(PENDING) @map("verification_status")
  verifiedByTeacherId String?           @map("verified_by_teacher_id")
  verifiedAt         DateTime?          @map("verified_at")
  createdAt          DateTime           @default(now()) @map("created_at")

  student            Student            @relation(fields: [studentId], references: [id], onDelete: Cascade)
  verifiedByTeacher  Teacher?           @relation(fields: [verifiedByTeacherId], references: [id])

  @@index([studentId])
  @@map("certificates")
}

model VerifiedSkill {
  id             String       @id @default(uuid())
  studentId      String       @map("student_id")
  skillId        String       @map("skill_id")
  badgeLevel     BadgeLevel   @default(BEGINNER) @map("badge_level")
  verifiedByType VerifierType @map("verified_by_type")
  verifiedById   String?      @map("verified_by_id") // Reference ID (Quiz ID or Teacher ID)
  badgeIconUrl   String?      @map("badge_icon_url")
  awardedAt      DateTime     @default(now()) @map("awarded_at")

  student        Student      @relation(fields: [studentId], references: [id], onDelete: Cascade)
  skill          Skill        @relation(fields: [skillId], references: [id], onDelete: Cascade)

  @@unique([studentId, skillId])
  @@map("verified_skills")
}

// ---------------------------------------------------------
// INTERNSHIP, APPLICATION & ATS MODELS
// ---------------------------------------------------------

model Internship {
  id             String     @id @default(uuid())
  companyId      String     @map("company_id")
  title          String
  description    String     @db.Text
  requirements   String     @db.Text
  stipendMonthly Int        @default(0) @map("stipend_monthly")
  durationWeeks  Int        @map("duration_weeks")
  location       String
  mode           WorkMode   @default(HYBRID)
  minCgpa        Float      @default(6.0) @map("min_cgpa")
  deadline       DateTime
  isActive       Boolean    @default(true) @map("is_active")
  createdAt      DateTime   @default(now()) @map("created_at")
  updatedAt      DateTime   @updatedAt @map("updated_at")

  company        Company    @relation(fields: [companyId], references: [id], onDelete: Cascade)
  skills         InternshipSkill[]
  applications   Application[]

  @@index([companyId, isActive])
  @@map("internships")
}

model InternshipSkill {
  id           String     @id @default(uuid())
  internshipId String     @map("internship_id")
  skillId      String     @map("skill_id")
  isRequired   Boolean    @default(true) @map("is_required")

  internship   Internship @relation(fields: [internshipId], references: [id], onDelete: Cascade)
  skill        Skill      @relation(fields: [skillId], references: [id], onDelete: Cascade)

  @@unique([internshipId, skillId])
  @@map("internship_skills")
}

model Application {
  id           String            @id @default(uuid())
  internshipId String            @map("internship_id")
  studentId    String            @map("student_id")
  status       ApplicationStatus @default(APPLIED)
  aiMatchScore Float?            @map("ai_match_score") // 0.00 to 100.00%
  appliedAt    DateTime          @default(now()) @map("applied_at")
  updatedAt    DateTime          @updatedAt @map("updated_at")

  internship   Internship        @relation(fields: [internshipId], references: [id], onDelete: Cascade)
  student      Student           @relation(fields: [studentId], references: [id], onDelete: Cascade)
  interviews   Interview[]
  feedbacks    Feedback[]

  @@unique([internshipId, studentId])
  @@index([internshipId, aiMatchScore])
  @@map("applications")
}

model Interview {
  id            String          @id @default(uuid())
  applicationId String          @map("application_id")
  companyId     String          @map("company_id")
  studentId     String          @map("student_id")
  scheduledTime DateTime        @map("scheduled_time")
  durationMins  Int             @default(45) @map("duration_mins")
  meetingLink   String          @map("meeting_link")
  status        InterviewStatus @default(SCHEDULED)
  notes         String?         @db.Text
  createdAt     DateTime        @default(now()) @map("created_at")

  application   Application     @relation(fields: [applicationId], references: [id], onDelete: Cascade)
  company       Company         @relation(fields: [companyId], references: [id], onDelete: Cascade)
  student       Student         @relation(fields: [studentId], references: [id], onDelete: Cascade)

  @@index([studentId, scheduledTime])
  @@map("interviews")
}

model Feedback {
  id            String       @id @default(uuid())
  applicationId String       @map("application_id")
  studentId     String       @map("student_id")
  reviewerType  ReviewerType @map("reviewer_type")
  rating        Int          // Scale 1 to 5
  comments      String       @db.Text
  createdAt     DateTime     @default(now()) @map("created_at")

  application   Application  @relation(fields: [applicationId], references: [id], onDelete: Cascade)
  student       Student      @relation(fields: [studentId], references: [id], onDelete: Cascade)

  @@map("feedback")
}

model Resume {
  id          String   @id @default(uuid())
  studentId   String   @map("student_id")
  templateId  String   @map("template_id")
  rawJson     Json     @map("raw_json")
  pdfUrl      String   @map("pdf_url")
  generatedAt DateTime @default(now()) @map("generated_at")

  student     Student  @relation(fields: [studentId], references: [id], onDelete: Cascade)

  @@index([studentId])
  @@map("resumes")
}

model LearningResource {
  id          String   @id @default(uuid())
  skillId     String   @map("skill_id")
  provider    String   // "NPTEL", "SWAYAM", "COURSERA", "AYUSH_PORTAL"
  title       String
  courseUrl   String   @map("course_url")
  duration    String   // e.g. "8 Weeks", "12 Weeks"
  difficulty  String   // "Introductory", "Intermediate", "Advanced"
  createdAt   DateTime @default(now()) @map("created_at")

  skill       Skill    @relation(fields: [skillId], references: [id], onDelete: Cascade)

  @@index([skillId, provider])
  @@map("learning_resources")
}
```

---

### 4.2 Entity-Relationship (ER) Diagram

```mermaid
erDiagram
    users ||--o| students : "has profile"
    users ||--o| companies : "has profile"
    users ||--o| teachers : "has profile"
    users ||--o{ refresh_tokens : "owns"

    students ||--o{ quiz_attempts : "takes"
    students ||--o{ certificates : "submits"
    students ||--o{ verified_skills : "earns"
    students ||--o{ applications : "submits"
    students ||--o{ resumes : "generates"
    students ||--o{ interviews : "attends"
    students ||--o{ feedback : "receives/provides"

    companies ||--o{ internships : "posts"
    companies ||--o{ interviews : "conducts"

    teachers ||--o{ certificates : "verifies"

    skills ||--o{ skill_quizzes : "assessed by"
    skills ||--o{ verified_skills : "badges"
    skills ||--o{ internship_skills : "required in"
    skills ||--o{ learning_resources : "upskilling"

    skill_quizzes ||--o{ quiz_attempts : "attempt logs"
    
    internships ||--o{ internship_skills : "requires"
    internships ||--o{ applications : "receives"

    applications ||--o{ interviews : "progresses to"
    applications ||--o{ feedback : "evaluated in"

    users {
        uuid id PK
        string email UK
        string password_hash
        enum role
        boolean is_verified
    }

    students {
        uuid id PK
        uuid user_id FK
        string roll_number UK
        string college_name
        float cgpa
        int profile_completion_pct
    }

    companies {
        uuid id PK
        uuid user_id FK
        string company_name
        string industry
        enum verification_status
    }

    teachers {
        uuid id PK
        uuid user_id FK
        string employee_id UK
        string department
    }

    skills {
        uuid id PK
        string name UK
        string category
    }

    internships {
        uuid id PK
        uuid company_id FK
        string title
        int stipend_monthly
        enum mode
        date deadline
    }

    applications {
        uuid id PK
        uuid internship_id FK
        uuid student_id FK
        enum status
        float ai_match_score
    }

    interviews {
        uuid id PK
        uuid application_id FK
        datetime scheduled_time
        string meeting_link
        enum status
    }
```

---

# SECTION 5 — Backend Architecture

### 5.1 Clean Layered Folder Structure (`backend/`)

```
backend/
├── prisma/
│   ├── schema.prisma              # Database schema definition
│   ├── migrations/                # Version-controlled SQL migration history
│   └── seed.ts                    # Database seeder (skills, dummy quizzes, users)
├── src/
│   ├── @types/                    # Global ambient TypeScript definitions
│   │   └── express.d.ts           # Express Request user extension
│   ├── config/                    # Environment variables & runtime constants
│   │   ├── env.ts                 # Validated Zod environment parsing
│   │   ├── cloudinary.ts          # Cloudinary SDK credentials setup
│   │   └── database.ts            # Prisma client singleton instance
│   ├── controllers/               # Request intake, status codes, response dispatch
│   │   ├── auth.controller.ts
│   │   ├── student.controller.ts
│   │   ├── company.controller.ts
│   │   ├── teacher.controller.ts
│   │   ├── internship.controller.ts
│   │   ├── application.controller.ts
│   │   ├── interview.controller.ts
│   │   └── quiz.controller.ts
│   ├── services/                  # Pure business logic and DB transactions
│   │   ├── auth.service.ts
│   │   ├── student.service.ts
│   │   ├── company.service.ts
│   │   ├── teacher.service.ts
│   │   ├── internship.service.ts
│   │   ├── application.service.ts
│   │   ├── interview.service.ts
│   │   ├── ai-client.service.ts   # Axios client for internal FastAPI AI calls
│   │   ├── pdf-generator.service.ts # Puppeteer resume compilation
│   │   └── mailer.service.ts      # Nodemailer & .ics calendar generation
│   ├── routes/                    # Express Router definitions
│   │   ├── index.ts               # Master router aggregation (/api/v1)
│   │   ├── auth.routes.ts
│   │   ├── student.routes.ts
│   │   ├── company.routes.ts
│   │   ├── teacher.routes.ts
│   │   ├── internship.routes.ts
│   │   ├── application.routes.ts
│   │   ├── interview.routes.ts
│   │   └── quiz.routes.ts
│   ├── middlewares/               # Cross-cutting concerns & request interceptors
│   │   ├── auth.middleware.ts     # JWT verification & claims hydration
│   │   ├── role.middleware.ts     # RBAC authorization guard
│   │   ├── validate.middleware.ts # Zod request body/query validator
│   │   ├── error.middleware.ts    # Centralized HTTP error handler
│   │   └── rate-limit.middleware.ts # Memory / Redis rate limiter
│   ├── validations/               # Zod validation schemas
│   │   ├── auth.validation.ts
│   │   ├── internship.validation.ts
│   │   ├── application.validation.ts
│   │   └── interview.validation.ts
│   ├── utils/                     # Reusable pure helper functions
│   │   ├── api-response.ts        # Standardized { success, data, error } wrapper
│   │   ├── api-error.ts           # Custom ApiError class extending Error
│   │   └── logger.ts              # Winston / Morgan structured logger
│   └── app.ts                     # Express app setup, CORS, helmet & middleware
├── tests/                         # Integration and contract tests
│   ├── auth.test.ts
│   ├── internship.test.ts
│   └── application.test.ts
├── Dockerfile                     # Multi-stage production container build
├── package.json
├── tsconfig.json
└── .env.example
```

---

### 5.2 Complete REST API Directory

| Method | Endpoint | Access Role | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/register` | Public | Register new user (Student/Company/Teacher) |
| `POST` | `/api/v1/auth/login` | Public | Authenticate user, return JWT access token & set cookie |
| `POST` | `/api/v1/auth/refresh` | Public | Exchange refresh token cookie for new access token |
| `POST` | `/api/v1/auth/logout` | Authenticated | Revoke refresh token and clear cookie |
| `GET` | `/api/v1/students/profile` | Student | Get authenticated student's full profile & verified badges |
| `PUT` | `/api/v1/students/profile` | Student | Update student profile (bio, graduation year, CGPA) |
| `POST` | `/api/v1/students/certificates` | Student | Upload certification proof to Cloudinary & submit for verify |
| `GET` | `/api/v1/students/skill-gap` | Student | Get AI-identified skill gaps & recommended NPTEL courses |
| `POST` | `/api/v1/students/resume/generate` | Student | Compile dynamic ATS resume & generate download PDF |
| `GET` | `/api/v1/quizzes` | Student | List available skill assessments |
| `GET` | `/api/v1/quizzes/:id` | Student | Get timed quiz questions (omitting correct answers) |
| `POST` | `/api/v1/quizzes/:id/submit` | Student | Submit quiz answers, calculate score, award badge if passed |
| `GET` | `/api/v1/internships` | Public / Auth | Browse and filter active internships |
| `GET` | `/api/v1/internships/:id` | Public / Auth | Get specific internship details |
| `POST` | `/api/v1/internships` | Company | Post new internship with required skill tags |
| `PUT` | `/api/v1/internships/:id` | Company | Update existing internship details |
| `DELETE`| `/api/v1/internships/:id` | Company | Deactivate or delete internship |
| `POST` | `/api/v1/applications` | Student | Apply to an internship |
| `GET` | `/api/v1/students/applications` | Student | Track status of all submitted applications |
| `GET` | `/api/v1/companies/internships/:id/applicants`| Company | Get applicant list ordered by AI match ranking |
| `PATCH`| `/api/v1/applications/:id/status` | Company | Update application status (Shortlist / Reject) |
| `POST` | `/api/v1/interviews/schedule` | Company | Book interview slot, create meeting, dispatch invites |
| `GET` | `/api/v1/interviews/my-interviews` | Student / Comp | View scheduled upcoming and past interviews |
| `GET` | `/api/v1/teachers/verifications` | Teacher | Get pending certificate submissions for department |
| `PATCH`| `/api/v1/teachers/verifications/:id` | Teacher | Approve or reject student certification |
| `GET` | `/api/v1/teachers/analytics` | Teacher | Departmental skill distribution & placement metrics |
| `POST` | `/api/v1/feedback` | Student / Comp | Submit internship completion feedback & review |

---

### 5.3 Request / Response JSON Specifications

#### 1. Authentication: `POST /api/v1/auth/login`

**Request:**
```json
{
  "email": "ayush.sharma@ayush.edu.in",
  "password": "SecurePassword#2026"
}
```

**Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJhM2MxZDdlMC00ZGY2LTQ1MmMtYTkyZC05MmI1YmQxMmE0NTAiLCJyb2xlIjoiU1RVREVOVCIsImVtYWlsIjoiYXl1c2guc2hhcm1hQGF5dXNoLmVkdS5pbiIsImlhdCI6MTczNDcxNDQwMCwiZXhwIjoxNzM0NzE1MzAwfQ.SflKxwR_7g19d2U0A9B0C5...",
    "user": {
      "id": "a3c1d7e0-4df6-452c-a92d-92b5bd12a450",
      "email": "ayush.sharma@ayush.edu.in",
      "role": "STUDENT",
      "isVerified": true,
      "profile": {
        "firstName": "Ayush",
        "lastName": "Sharma",
        "rollNumber": "AIIA-2023-BAMS-042",
        "collegeName": "All India Institute of Ayurveda (AIIA), New Delhi",
        "branch": "Dravyaguna & Ayurvedic Pharmacology",
        "cgpa": 8.75,
        "profileCompletionPct": 85
      }
    }
  }
}
```

#### 2. Internship Creation: `POST /api/v1/internships`

**Request:**
```json
{
  "title": "Ayurvedic Formulation & Clinical R&D Intern",
  "description": "Engage in phytochemical characterization, standardizing herbal formulations, and evaluating clinical pharmacology protocols.",
  "requirements": "Strong foundation in Dravyaguna, Good Clinical Practice (GCP), analytical spectrometry, and clinical trial documentation.",
  "stipendMonthly": 25000,
  "durationWeeks": 16,
  "location": "New Delhi (Okhla Industrial Area)",
  "mode": "ONSITE",
  "minCgpa": 7.5,
  "deadline": "2026-11-30T23:59:59.000Z",
  "requiredSkillIds": [
    "s-drav-101",
    "s-pharma-204",
    "s-gcp-301"
  ]
}
```

**Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Internship published successfully",
  "data": {
    "id": "int-7f9a2e10-9b4c",
    "companyId": "comp-550e8400-e29b",
    "title": "Ayurvedic Formulation & Clinical R&D Intern",
    "stipendMonthly": 25000,
    "mode": "ONSITE",
    "isActive": true,
    "deadline": "2026-11-30T23:59:59.000Z",
    "skills": [
      { "id": "s-drav-101", "name": "Dravyaguna Standardization", "isRequired": true },
      { "id": "s-pharma-204", "name": "Phytochemical Extraction", "isRequired": true },
      { "id": "s-gcp-301", "name": "Good Clinical Practice (GCP)", "isRequired": true }
    ],
    "createdAt": "2026-09-20T22:00:00.000Z"
  }
}
```

#### 3. AI-Ranked Applicant List: `GET /api/v1/companies/internships/:id/applicants`

**Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "internshipId": "int-7f9a2e10-9b4c",
    "totalApplicants": 48,
    "rankedApplicants": [
      {
        "applicationId": "app-01a4e8d2",
        "studentId": "stud-992e34fa",
        "fullName": "Ayush Sharma",
        "college": "All India Institute of Ayurveda",
        "cgpa": 8.75,
        "aiMatchScore": 94.2,
        "breakdown": {
          "semanticFitPct": 96.0,
          "verifiedSkillMatchPct": 100.0,
          "quizScorePct": 92.5,
          "academicScorePct": 87.5
        },
        "verifiedBadges": ["Dravyaguna Expert", "GCP Certified", "Phytochem Intermediate"],
        "status": "APPLIED",
        "appliedAt": "2026-09-21T08:15:00.000Z"
      },
      {
        "applicationId": "app-02b5f9e3",
        "studentId": "stud-114c56ab",
        "fullName": "Priya Nair",
        "college": "Government Ayurveda College, Trivandrum",
        "cgpa": 8.10,
        "aiMatchScore": 86.7,
        "breakdown": {
          "semanticFitPct": 88.0,
          "verifiedSkillMatchPct": 85.0,
          "quizScorePct": 86.0,
          "academicScorePct": 81.0
        },
        "verifiedBadges": ["Phytochem Intermediate"],
        "status": "APPLIED",
        "appliedAt": "2026-09-21T09:40:00.000Z"
      }
    ]
  }
}
```

#### 4. Skill Gap Recommendation: `GET /api/v1/students/skill-gap`

**Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "studentId": "stud-992e34fa",
    "targetDomain": "Ayurvedic Drug Regulatory Affairs & Clinical Research",
    "currentCompetencies": [
      { "name": "Dravyaguna", "level": "ADVANCED", "verifiedBy": "QUIZ" },
      { "name": "Phytochemical Extraction", "level": "INTERMEDIATE", "verifiedBy": "TEACHER" }
    ],
    "identifiedSkillGaps": [
      {
        "skillName": "Ayurvedic Pharmacovigilance & WHO Guidelines",
        "gapSeverity": "HIGH",
        "industryDemandWeight": 0.88,
        "recommendedCourses": [
          {
            "provider": "NPTEL",
            "title": "Pharmacovigilance and Safety of Herbal Medicinal Products",
            "courseUrl": "https://nptel.ac.in/courses/102106099",
            "duration": "8 Weeks",
            "certifyingBody": "IIT Madras / Ministry of Ayush"
          },
          {
            "provider": "SWAYAM",
            "title": "Clinical Research Regulations and Ethics in AYUSH",
            "courseUrl": "https://swayam.gov.in/explorer?category=AYUSH",
            "duration": "12 Weeks",
            "certifyingBody": "Central Council for Research in Ayurvedic Sciences (CCRAS)"
          }
        ]
      }
    ]
  }
}
```

---

# SECTION 6 — AI Architecture

### 6.1 FastAPI Microservice Directory (`ai_service/`)

```
ai_service/
├── app/
│   ├── api/
│   │   ├── router.py              # Aggregates AI endpoints
│   │   └── endpoints/
│   │       ├── quiz_skill_extractor.py
│   │       ├── resume_parser.py
│   │       ├── internship_matcher.py
│   │       ├── applicant_ranker.py
│   │       └── skill_gap_recommender.py
│   ├── core/
│   │   ├── config.py              # Settings & model paths
│   │   └── security.py            # Shared HMAC secret verification
│   ├── models/                    # Pydantic validation schemas
│   │   ├── matching_models.py
│   │   ├── ranking_models.py
│   │   └── gap_models.py
│   ├── services/                  # ML inference workers
│   │   ├── embedding_service.py   # Sentence-Transformers cache
│   │   ├── nlp_extractor.py       # Regex & Spacy phrase matcher
│   │   ├── similarity_engine.py   # Vector dot product & cosine
│   │   └── gap_analyzer.py        # Set difference & course matcher
│   └── main.py                    # FastAPI application initialization
├── requirements.txt               # Locked dependencies
├── Dockerfile                     # Optimized PyTorch/CPU container
└── test_ai.py                     # Pytest suite for ML endpoints
```

---

### 6.2 The Five Specialized AI Services

#### Service 1: Skill Extraction from Quiz
- **Function:** Parses student assessment answers, response times, and conceptual errors to compute fine-grained competency vectors.
- **Input:** JSON payload of `{ studentId, quizId, questions: [{ questionId, selectedAnswer, isCorrect, timeSpentSec }] }`.
- **Output:** Categorized proficiency scores: `{ skillId, proficiencyScore (0.0-1.0), suggestedBadgeLevel: "BEGINNER"|"INTERMEDIATE"|"ADVANCED" }`.
- **Implementation:** Weighted scoring mapping question difficulty tiers (Bloom's Taxonomy) against correct answers, penalized for abnormal time anomalies.

#### Service 2: Resume Skill Extraction
- **Function:** Ingests raw resume text or PDF binary and extracts hard skills, domain keywords, and certifications without requiring manual entry.
- **Input:** Raw string `resume_text` or Cloudinary PDF URL.
- **Output:** `{ extractedSkills: ["Dravyaguna", "Phytochemistry", "HPLC", "GCP"], confidenceScores: [0.98, 0.94, 0.89, 0.95], education: { degree, cgpa } }`.
- **Implementation:** Hybrid entity extraction:
  1. Regex matching against master `Skills` taxonomy ($N = 2,500$ normalized tokens).
  2. Sub-phrase syntactic parsing using SpaCy `Matcher` to identify contextual skills (e.g., "conducted high-performance liquid chromatography" $\rightarrow$ `HPLC`).

#### Service 3: Semantic Internship Matching
- **Function:** Matches students with the top $K$ relevant internships across the national platform based on semantic vector similarity.
- **Model:** `SentenceTransformers('all-MiniLM-L6-v2')`.
- **Input:** Student composite representation $T_s$ (bio, verified skills, branch, target roles) and active internship embeddings $V_{jobs}$.
- **Mathematical Operation:**
  $$\vec{e}_s = \text{Embed}(T_s), \quad \vec{e}_{job} = \text{Embed}(T_{job})$$
  $$\text{Cosine Similarity}(\vec{e}_s, \vec{e}_{job}) = \frac{\vec{e}_s \cdot \vec{e}_{job}}{\|\vec{e}_s\| \|\vec{e}_{job}\|}$$
- **Output:** Ranked list of `[{ internshipId, similarityPercentage, matchingAttributes }]`.

#### Service 4: Multi-Attribute Applicant Ranking Percentage
- **Function:** Provides recruiters with an objective, mathematically defensible compatibility ranking for all applicants to a posted internship.
- **Input Vector:**
  - $S_{\text{semantic}}$: Cosine similarity between resume/profile and job description ($0.0 - 1.0$).
  - $S_{\text{skills}}$: Jaccard overlap between candidate's verified skills and mandatory job skills:
    $$S_{\text{skills}} = \frac{|\text{VerifiedSkills} \cap \text{RequiredSkills}|}{|\text{RequiredSkills}|}$$
  - $S_{\text{quiz}}$: Average normalized score in platform skill quizzes ($0.0 - 1.0$).
  - $S_{\text{academic}}$: Normalized CGPA ($\frac{\text{CGPA}}{10.0}$).
- **Composite Formula:**
  $$\text{Score} = 100 \times \left( 0.40 \cdot S_{\text{semantic}} + 0.25 \cdot S_{\text{skills}} + 0.20 \cdot S_{\text{quiz}} + 0.15 \cdot S_{\text{academic}} \right)$$
- **Output:** Output JSON: `{ studentId, finalRankScore: 92.4, rankPosition: 1, breakdown: { ... } }`.

#### Service 5: Skill Gap Recommendation using NPTEL / SWAYAM
- **Function:** Diagnoses missing competencies preventing students from qualifying for high-stipend internships and maps exact national courses to close the gap.
- **Input:** Target internship ID or desired career profile + student's current verified skill set.
- **Logic:**
  1. Computes Deficit Set: $\Delta = \text{TargetSkills} \setminus \text{StudentVerifiedSkills}$.
  2. For every missing skill $s \in \Delta$, queries the indexed NPTEL/SWAYAM course catalogue embedding space.
  3. Sorts recommendations by relevance, duration, and institution authority (IITs, IISc, AIIA, CCRAS).
- **Output:** Actionable learning roadmap with direct enrollment links, weekly syllabus hours, and certification weight.

---

### 6.3 Inter-Service Data Flow (Node.js ↔ FastAPI)

```mermaid
sequenceDiagram
    autonumber
    participant NodeAPI as Express Backend (Port 5000)
    participant FastAPIServer as FastAPI AI Microservice (Port 8000)
    participant SBERT as all-MiniLM-L6-v2 In-Memory Model
    participant DB as Postgres Cache

    NodeAPI->>FastAPIServer: POST /ai/rank-applicants (Header: X-Internal-Key: <HMAC_SECRET>)
    Note over NodeAPI,FastAPIServer: Payload: { internshipId, requirements, applicants: [...] }
    FastAPIServer->>FastAPIServer: Authenticate HMAC signature
    FastAPIServer->>SBERT: Batch Encode(Requirements + Applicant Vectors)
    SBERT-->>FastAPIServer: 384-dimensional dense tensors
    FastAPIServer->>FastAPIServer: Compute Cosine Distances & Multi-Factor Weights
    FastAPIServer-->>NodeAPI: 200 OK { rankedCandidates: [ { studentId, score, breakdown } ] }
    NodeAPI->>DB: Batch update applications with ai_match_score
```

---

# SECTION 7 — Frontend Architecture

### 7.1 React + TypeScript + Vite Structure (`frontend/`)

```
frontend/
├── public/
│   ├── favicon.ico
│   └── assets/images/             # Static logos and badge icons
├── src/
│   ├── assets/                    # Brand typography and SVG icons
│   ├── components/                # Reusable presentation components
│   │   ├── ui/                    # Shadcn UI primitives (Button, Dialog, Badge, Input, Card)
│   │   ├── common/                # Shared layout components
│   │   │   ├── Navbar.tsx         # Responsive navbar with role switcher
│   │   │   ├── Sidebar.tsx        # Collapsible dashboard sidebar
│   │   │   ├── Footer.tsx
│   │   │   ├── LoadingSpinner.tsx
│   │   │   └── ProtectedRoute.tsx # Route guard checking JWT + Role
│   │   ├── student/               # Student-specific components
│   │   │   ├── SkillRadarChart.tsx
│   │   │   ├── VerifiedBadgeCard.tsx
│   │   │   ├── ProfileMeter.tsx   # Visual circular completion indicator
│   │   │   └── NptelCourseCard.tsx
│   │   ├── company/               # Recruiter-specific components
│   │   │   ├── ApplicantRankTable.tsx
│   │   │   ├── InterviewSchedulerModal.tsx
│   │   │   └── PostInternshipForm.tsx
│   │   └── teacher/               # Faculty-specific components
│   │       ├── VerificationQueueTable.tsx
│   │       └── StudentProgressRadar.tsx
│   ├── layouts/                   # Dashboard frame layouts
│   │   ├── RootLayout.tsx         # Public landing page layout
│   │   ├── AuthLayout.tsx         # Clean split-screen login/register layout
│   │   └── DashboardLayout.tsx    # Authenticated sidebar + topbar shell
│   ├── pages/                     # Routed view components
│   │   ├── auth/
│   │   │   ├── LoginPage.tsx
│   │   │   └── RegisterPage.tsx
│   │   ├── student/
│   │   │   ├── StudentDashboard.tsx
│   │   │   ├── SkillQuizPage.tsx
│   │   │   ├── QuizActivePage.tsx
│   │   │   ├── PortfolioPage.tsx
│   │   │   ├── ResumeBuilderPage.tsx
│   │   │   ├── InternshipCatalogPage.tsx
│   │   │   ├── ApplicationTrackerPage.tsx
│   │   │   └── SkillGapAdvisorPage.tsx
│   │   ├── company/
│   │   │   ├── CompanyDashboard.tsx
│   │   │   ├── PostInternshipPage.tsx
│   │   │   ├── ManagePostingsPage.tsx
│   │   │   ├── ApplicantRankingPage.tsx
│   │   │   └── InterviewCalendarPage.tsx
│   │   └── teacher/
│   │       ├── TeacherDashboard.tsx
│   │       ├── VerificationQueuePage.tsx
│   │       ├── StudentProgressPage.tsx
│   │       └── InstitutionalAnalyticsPage.tsx
│   ├── hooks/                     # Custom React hooks
│   │   ├── useAuth.ts             # Auth state and login/logout methods
│   │   ├── useInternships.ts      # TanStack query wrapper for postings
│   │   ├── useApplications.ts    # Application state mutations
│   │   └── useDebounce.ts         # Search input debouncer
│   ├── context/                   # Global state management
│   │   └── auth-store.ts          # Zustand store for JWT & user profile
│   ├── services/api/              # Centralized Axios network layer
│   │   ├── client.ts              # Axios interceptors with token injection
│   │   ├── auth.api.ts
│   │   ├── student.api.ts
│   │   ├── company.api.ts
│   │   ├── teacher.api.ts
│   │   └── internship.api.ts
│   ├── types/                     # Shared TypeScript interfaces
│   │   ├── user.types.ts
│   │   ├── internship.types.ts
│   │   └── application.types.ts
│   ├── App.tsx                    # Top-level RouterProvider & React Query Provider
│   ├── main.tsx                   # React DOM entry point
│   └── index.css                  # Tailwind directives & CSS design tokens
├── tailwind.config.js
├── vite.config.ts
├── tsconfig.json
└── package.json
```

---

### 7.2 Page-to-API Binding Directory

| Page Component | Target Backend API Route | HTTP Method | Request Payload / Params | TanStack Query Key / Invalidation |
| :--- | :--- | :--- | :--- | :--- |
| `LoginPage.tsx` | `/api/v1/auth/login` | `POST` | `{ email, password }` | Mutates `auth-store` |
| `RegisterPage.tsx` | `/api/v1/auth/register` | `POST` | `{ email, password, role, details }`| Navigates to `/login` |
| `StudentDashboard.tsx` | `/api/v1/students/profile` | `GET` | Headers: Bearer Token | `['studentProfile']` |
| `PortfolioPage.tsx` | `/api/v1/students/certificates` | `POST` | `FormData (file, title, org)` | Invalidates `['studentProfile']` |
| `SkillQuizPage.tsx` | `/api/v1/quizzes` | `GET` | Query: `?category=AYUSH` | `['quizzes']` |
| `QuizActivePage.tsx` | `/api/v1/quizzes/:id/submit` | `POST` | `{ answers: [{ id, choice }] }` | Invalidates `['studentProfile']` |
| `InternshipCatalogPage.tsx`| `/api/v1/internships` | `GET` | Query: `?mode=HYBRID&stipend=10000` | `['internships', filters]` |
| `InternshipCatalogPage.tsx`| `/api/v1/applications` | `POST` | `{ internshipId }` | Invalidates `['myApplications']` |
| `ApplicationTrackerPage.tsx`|`/api/v1/students/applications`| `GET` | None | `['myApplications']` |
| `SkillGapAdvisorPage.tsx`| `/api/v1/students/skill-gap` | `GET` | None | `['skillGaps']` |
| `ResumeBuilderPage.tsx` | `/api/v1/students/resume/generate`| `POST` | `{ templateId: 'modern-ats' }` | `['generatedResume']` |
| `CompanyDashboard.tsx` | `/api/v1/companies/analytics` | `GET` | None | `['companyAnalytics']` |
| `PostInternshipPage.tsx`| `/api/v1/internships` | `POST` | Complete internship payload | Invalidates `['myPostings']` |
| `ApplicantRankingPage.tsx`|`/api/v1/companies/internships/:id/applicants`| `GET`| None | `['applicants', internshipId]` |
| `InterviewSchedulerModal.tsx`|`/api/v1/interviews/schedule`| `POST`| `{ applicationId, time, link }` | Invalidates `['applicants']` |
| `VerificationQueuePage.tsx`|`/api/v1/teachers/verifications`| `GET`| None | `['teacherVerifications']` |
| `VerificationQueuePage.tsx`|`/api/v1/teachers/verifications/:id`| `PATCH`| `{ action: 'APPROVE', badgeLevel }`| Invalidates `['teacherVerifications']`|

---

### 7.3 Client Routing Map with Role-Based Access Guards

```mermaid
flowchart TD
    AppRoot["/ (Root App)"] --> PublicRoutes["Public Routes"]
    AppRoot --> ProtectedStudent["Protected: STUDENT Role"]
    AppRoot --> ProtectedCompany["Protected: COMPANY Role"]
    AppRoot --> ProtectedTeacher["Protected: TEACHER Role"]

    subgraph PublicRoutes ["Public Zone"]
        Landing["/ (Landing Page)"]
        Login["/login"]
        Register["/register"]
        BrowseInternships["/internships (View Only)"]
    end

    subgraph ProtectedStudent ["Student Portal (/student)"]
        SDash["/student/dashboard"]
        SPortfolio["/student/portfolio"]
        SQuiz["/student/quizzes"]
        SQuizTake["/student/quizzes/:id"]
        SGap["/student/skill-gap"]
        SResume["/student/resume"]
        SApps["/student/applications"]
    end

    subgraph ProtectedCompany ["Company Portal (/company)"]
        CDash["/company/dashboard"]
        CPost["/company/post-internship"]
        CManage["/company/postings"]
        CRank["/company/internships/:id/applicants"]
        CInterviews["/company/interviews"]
    end

    subgraph ProtectedTeacher ["Teacher Portal (/teacher)"]
        TDash["/teacher/dashboard"]
        TVerify["/teacher/verifications"]
        TProgress["/teacher/student-progress"]
        TAnalytics["/teacher/institutional-analytics"]
    end
```

---

# SECTION 8 — Team Division (5 Members)

To guarantee flawless execution within the hackathon schedule, all architectural responsibilities are mapped to exactly **5 specialized engineers**.

```
+----------------------------------------------------------------------------------------------------+
| 5-MEMBER SQUAD DIRECTORY & REPOSITORY ROLES                                                        |
+-------------------+----------------------------+-----------------------+---------------------------+
| Role Title        | Primary Domain             | Dedicated Branch      | Scope of Authority        |
+-------------------+----------------------------+-----------------------+---------------------------+
| Member 1          | Database Engineer          | `database`            | PostgreSQL, Prisma, SQL   |
| Member 2          | AI/ML Engineer             | `ai-ml`               | Python, FastAPI, Models   |
| Member 3          | Backend Engineer           | `backend`             | Node, Express, REST, JWT  |
| Member 4          | Frontend Engineer          | `frontend`            | React, Tailwind, Shadcn   |
| Member 5          | Testing & Integration Lead | `testing-integration` | CI/CD, Merges, Deploy     |
+-------------------+----------------------------+-----------------------+---------------------------+
```

### Member 1 — Database Engineer
* **Responsibilities:**
  - Author and maintain `prisma/schema.prisma` definitions and database migrations.
  - Optimize SQL queries, write composite indexes, and enforce relational constraints.
  - Implement seed data scripts (`seed.ts`) populating real Ayush/STEM skills, sample quizzes, and mock user accounts.
  - Manage database connectivity, connection pooling, and connection resilience.
* **Folder Ownership:**
  - `backend/prisma/`
  - `backend/src/config/database.ts`
* **Deliverables:**
  - Fully migrated, clean PostgreSQL schema deployed on Supabase/Neon.
  - Seed script populating $>50$ standard skills and $>5$ quizzes.
  - Database rollback and migration verification scripts.
* **Git Branch Name:** `database`

### Member 2 — AI/ML Engineer
* **Responsibilities:**
  - Build, optimize, and deploy the Python 3.11 FastAPI microservice.
  - Implement Sentence-BERT embedding extraction (`all-MiniLM-L6-v2`) and Cosine Similarity matching.
  - Engineer the multi-attribute applicant ranking algorithm and NPTEL course recommendation engine.
  - Build resume skill parser using regex and NLP phrase matching.
* **Folder Ownership:**
  - `ai_service/` (entire directory)
* **Deliverables:**
  - Containerized FastAPI service exposing 5 validated endpoints with OpenAPI docs (`/docs`).
  - Unit-tested recommendation and ranking mathematical functions with $>90\%$ coverage.
* **Git Branch Name:** `ai-ml`

### Member 3 — Backend Engineer
* **Responsibilities:**
  - Architect and implement Express.js REST APIs in TypeScript.
  - Implement JWT authentication, refresh token cookie rotation, and RBAC middleware.
  - Integrate Prisma Client for database queries and transactions.
  - Integrate Cloudinary for media uploads and Puppeteer for dynamic PDF resume generation.
  - Author HTTP client service connecting Express to the FastAPI AI microservice.
* **Folder Ownership:**
  - `backend/src/` (controllers, routes, services, middlewares, validations, utils)
* **Deliverables:**
  - Fully functional Express REST API satisfying all 26 endpoints.
  - Postman/Insomnia Collection with automated test scripts.
* **Git Branch Name:** `backend`

### Member 4 — Frontend Engineer
* **Responsibilities:**
  - Develop complete React 18 single-page application using TypeScript and Vite.
  - Implement responsive modern UI with Tailwind CSS and Shadcn UI components.
  - Integrate Axios API client with TanStack Query caching and optimistic UI updates.
  - Construct dynamic interactive dashboards for Student, Company, and Teacher personas.
  - Build responsive forms with real-time Zod validation and visual status indicators.
* **Folder Ownership:**
  - `frontend/` (pages, components, layouts, hooks, context, services/api)
* **Deliverables:**
  - Fully responsive, accessible web portal covering all three user roles.
  - Zero console errors, smooth page transitions, and responsive mobile layout.
* **Git Branch Name:** `frontend`

### Member 5 — Testing & Integration Lead
* **Responsibilities:**
  - Repository owner and sole gatekeeper authorized to merge PRs into `main`.
  - Configure GitHub repository settings, branch protection rules, and CI/CD workflows.
  - Author and execute automated integration tests (Supertest) and E2E flows (Playwright).
  - Manage cloud deployments (Vercel for Frontend, Render/Railway for Backend & AI, Cloud DB).
  - Perform live integration testing between Frontend, Backend, AI, and Database.
* **Folder Ownership:**
  - `.github/workflows/`
  - `backend/tests/`
  - `frontend/e2e/`
  - Root configuration (`docker-compose.yml`, deployment configs)
* **Deliverables:**
  - GitHub Actions CI/CD pipeline executing linting, unit tests, and build verification.
  - Zero-defect production staging deployment with live public URLs.
* **Git Branch Name:** `testing-integration`

---

# SECTION 9 — Six Phase Implementation Plan

```mermaid
gantt
    title SIH 26044 Six-Phase Implementation Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1: Core Foundation
    DB Schema & Auth API         :p1_1, 2026-09-21, 2d
    Auth UI & CI Pipeline        :p1_2, after p1_1, 2d
    section Phase 2: Profiles & Media
    Profile Models & Storage     :p2_1, after p1_2, 2d
    Portfolio UI & Cloudinary    :p2_2, after p2_1, 2d
    section Phase 3: Quizzes & Badges
    Quiz Engine & Verification   :p3_1, after p2_2, 3d
    section Phase 4: Internships & ATS
    Internship CRUD & Apply Flow :p4_1, after p3_1, 3d
    section Phase 5: AI Engine
    S-BERT Matching & Ranking    :p5_1, after p4_1, 3d
    section Phase 6: Scheduler & Hardening
    Interviews, Resumes & Deploy :p6_1, after p5_1, 3d
```

### Phase 1: Core Foundation, Authentication & RBAC
* **Objective:** Establish the development environment, continuous integration pipeline, relational database schema, user authentication, and role-based route protection.
* **Features:** Multi-role registration, login, JWT issuance, refresh token rotation, and authenticated dashboard frames.
* **Database Work:** Create `users`, `refresh_tokens`, `students`, `companies`, `teachers` tables via Prisma; execute initial migration.
* **AI Work:** Initialize `ai_service/` repository structure; install FastAPI, PyTorch, and Sentence-Transformers; verify environment.
* **Backend Work:** Implement Express server, error handling, Zod validation, `AuthService`, and JWT verification middleware.
* **Frontend Work:** Scaffold Vite React application, configure Tailwind CSS & Shadcn UI, implement `LoginPage`, `RegisterPage`, and `ProtectedRoute`.
* **Testing Work:** Author unit tests for JWT generation and password hashing; setup GitHub Actions workflow for PR verification.
* **Git Deliverables:** PR from `database`, `backend`, `frontend` into `testing-integration`. Release Tag: `v0.1.0-alpha`.
* **Definition of Done (DoD):** A user can register as a Student, Company, or Teacher, log in, receive a secure JWT, and access an empty role-specific dashboard.

---

### Phase 2: Profiles, Digital Portfolios & Cloud Storage
* **Objective:** Enable rich profile creation, digital document uploads, and dynamic profile completion calculation.
* **Features:** Student profile editor, company profile builder, faculty credentials setup, Cloudinary secure document uploads.
* **Database Work:** Implement `certificates` table; add relations to `students` and `teachers`.
* **AI Work:** Build regex and rule-based skill tokenizer prototype for resume text parsing.
* **Backend Work:** Implement `StudentController`, `CompanyController`, and `CloudinaryService` for multipart streaming.
* **Frontend Work:** Build `StudentDashboard`, `PortfolioPage`, `ProfileMeter` component, and Cloudinary drag-and-drop file uploader.
* **Testing Work:** Test file upload size limits, MIME type filters (PDF/PNG only), and profile update database integrity.
* **Git Deliverables:** PRs merged into `testing-integration`. Release Tag: `v0.2.0-alpha`.
* **Definition of Done (DoD):** Students can upload certificates to Cloudinary, update their CGPA and bio, and see their profile completion meter dynamically increase.

---

### Phase 3: Skill Quiz Engine & Teacher Verification Workflow
* **Objective:** Implement standardized assessment tests and faculty-driven credential verification to generate verified skill badges.
* **Features:** Timed skill assessment delivery, auto-grading, teacher verification queue, and verified badge rendering.
* **Database Work:** Migrate `skills`, `skill_quizzes`, `quiz_attempts`, and `verified_skills` tables; seed with initial skill question banks.
* **AI Work:** Implement Service 1 (Quiz skill extraction and proficiency tier scoring).
* **Backend Work:** Implement `QuizController` (timed delivery, answer evaluation, badge award) and `TeacherController` (approval endpoints).
* **Frontend Work:** Build `SkillQuizPage`, interactive `QuizActivePage` with countdown timer, and `VerificationQueuePage` for teachers.
* **Testing Work:** Supertest quiz grading math (ensure correct answers are hidden from network payload); test teacher approval permissions.
* **Git Deliverables:** Integrated PRs merged into `testing-integration`. Release Tag: `v0.3.0-beta`.
* **Definition of Done (DoD):** A student takes a quiz, passes, and receives an automatic verified badge; alternatively, a teacher approves an uploaded certificate to award a verified badge.

---

### Phase 4: Internship Management & Application Pipeline (ATS)
* **Objective:** Build full internship lifecycle management, search filtering, and application submission with state tracking.
* **Features:** Company internship posting form, searchable student catalog, one-click application submission, and live ATS status tracker.
* **Database Work:** Migrate `internships`, `internship_skills`, and `applications` tables with composite unique constraints.
* **AI Work:** Prepare mock endpoints for semantic matching to allow seamless frontend-backend development.
* **Backend Work:** Implement `InternshipService` and `ApplicationService` with eligibility checks (minimum CGPA thresholds).
* **Frontend Work:** Build `PostInternshipPage`, `InternshipCatalogPage` with multi-facet filters, and `ApplicationTrackerPage`.
* **Testing Work:** Validate edge cases: ensure students cannot apply twice to the same posting and cannot apply if their CGPA is below the minimum.
* **Git Deliverables:** Merged to `testing-integration`. Release Tag: `v0.4.0-beta`.
* **Definition of Done (DoD):** A company posts an internship; a student browses, filters, applies; the application appears in both the student's tracker and the company's applicant pipeline.

---

### Phase 5: AI Engine Integration (Semantic Matching, Ranking & Skill Gap)
* **Objective:** Connect the Express backend to the FastAPI AI microservice to inject intelligence across matching, ranking, and upskilling.
* **Features:** Semantic internship recommendations, automated percentage ranking for recruiters, and NPTEL/SWAYAM skill gap remediation.
* **Database Work:** Migrate `learning_resources` table; seed with real NPTEL and SWAYAM courses; add `ai_match_score` index on applications.
* **AI Work:** Deploy full Sentence-BERT embedding engine, Cosine Similarity worker, multi-factor ranker, and skill gap set-difference algorithm.
* **Backend Work:** Connect `ai-client.service.ts` to live FastAPI routes; implement ranking cache in Redis; expose `/api/v1/students/skill-gap`.
* **Frontend Work:** Build `ApplicantRankingPage` with score breakdown dialogs, and `SkillGapAdvisorPage` with direct NPTEL course enroll cards.
* **Testing Work:** Automated Pytest suite verifying embedding vector dimensions (384), Cosine Similarity bounds ($[-1, 1]$), and ranking determinism.
* **Git Deliverables:** Merged to `testing-integration`. Release Tag: `v0.5.0-rc`.
* **Definition of Done (DoD):** Company sees applicants sorted by an AI score percentage; students see missing skills with direct links to NPTEL courses.

---

### Phase 6: Interview Scheduler, Resume Generator, End-to-End Hardening & Launch
* **Objective:** Complete the placement lifecycle with calendar-integrated interview scheduling, dynamic PDF resume generation, final E2E testing, and production deployment.
* **Features:** Interview scheduler modal with `.ics` calendar generation, Puppeteer dynamic resume generation, full end-to-end regression testing.
* **Database Work:** Migrate `interviews`, `feedback`, and `resumes` tables; conduct index audits and performance tuning.
* **AI Work:** Run final inference speed optimizations (torch JIT compilation, quantization); ensure sub-100ms response times.
* **Backend Work:** Implement `InterviewService` with email dispatch, and `PdfGeneratorService` using Puppeteer.
* **Frontend Work:** Build `InterviewCalendarPage`, `ResumeBuilderPage` with live PDF preview, and student feedback forms.
* **Testing Work:** Playwright end-to-end tests covering complete user journeys from registration to interview scheduling; Lighthouse audit ($>90$ performance).
* **Git Deliverables:** Final merge into `main` by Testing Lead. Production Release: `v1.0.0-PROD`.
* **Definition of Done (DoD):** Company schedules an interview; both parties receive calendar invites; student downloads an auto-generated verified PDF resume; all Playwright tests pass in CI/CD.

---

# SECTION 10 — Collaboration Flow

### 10.1 Inter-Team Technical Dependency Sequence

```mermaid
flowchart LR
    M1["1. Database Engineer<br/>(Prisma Schema & Migrations)"] --> M3["2. Backend Engineer<br/>(REST APIs & Business Logic)"]
    M3 <== "API Contract / Payloads" ==> M2["3. AI/ML Engineer<br/>(FastAPI ML Microservice)"]
    M3 --> M4["4. Frontend Engineer<br/>(React UI & State Integration)"]
    M4 --> M5["5. Testing & Integration Lead<br/>(E2E Tests & Branch Merge)"]
    M5 --> Main["Protected 'main' Branch<br/>(Production Deployment)"]
```

### 10.2 Communication Protocols & Synchronization Handshakes

1. **Schema-First Handshake:**
   - Member 1 (Database) defines schema changes in `schema.prisma`, generates TypeScript types, and pushes to `database`.
   - Member 1 posts the generated schema interface in the team communication channel before Member 3 (Backend) starts controller integration.
2. **API Contract Handshake:**
   - Member 3 (Backend) and Member 2 (AI) agree on request/response JSON schemas for AI endpoints using OpenAPI/Pydantic models.
   - Member 3 provides mock responses so Member 4 (Frontend) can build UI views in parallel without waiting for backend implementation.
3. **Daily Blocker Escalation:**
   - Standups take place at the start of each phase. Any blocker lasting $>30$ minutes is escalated immediately to Member 5 (Testing & Integration Lead) for resolution.
4. **Merge Protocol:**
   - No team member merges directly to `main` or another peer's branch. All code moves through Pull Requests reviewed and merged exclusively by Member 5.

---

# SECTION 11 — GitHub Workflow

### 11.1 Repository Strategy & Protection Rules

* **Protected `main` Branch:** Direct pushes, force pushes, and branch deletions are strictly disabled. Merging requires:
  1. Passing GitHub Actions CI pipeline (Linting, TypeScript compilation, Unit tests, Build).
  2. Approved Pull Request review by Member 5 (Testing & Integration Lead).
* **Active Branches:**
  - `database` (Member 1)
  - `ai-ml` (Member 2)
  - `backend` (Member 3)
  - `frontend` (Member 4)
  - `testing-integration` (Member 5)

### 11.2 The 9 Mandatory Repository Rules

1. **Never work on `main`:** All code must be developed strictly inside assigned branches.
2. **Pull before starting:** Always run `git pull origin <branch>` before beginning a coding session.
3. **Verify folder structure:** Never place files outside assigned folder boundaries.
4. **Maintain architectural consistency:** Never introduce unauthorized packages or third-party CDNs.
5. **Commit atomically:** Commit with conventional commit messages (`feat:`, `fix:`, `chore:`, `test:`).
6. **Push daily:** Push your branch to remote GitHub at least once daily to prevent data loss.
7. **Create descriptive PRs:** Include screenshots, API examples, and linked phase tasks.
8. **Testing Lead approval required:** Only Member 5 has merge privileges into `main`.
9. **Semantic phase tagging:** Member 5 tags the repository with release versions (`v0.1.0`, `v0.2.0`, ...) after every phase.

---

### 11.3 Step-by-Step Git Commands for Every Member

#### Member 1 — Database Engineer
```bash
# Clone and setup branch
git clone https://github.com/organization/SIH26044-Academia-Industry-Portal.git
cd SIH26044-Academia-Industry-Portal
git checkout -b database

# Daily work cycle
git pull origin database
# Make modifications to prisma/schema.prisma and seed scripts
npx prisma migrate dev --name init_core_schema
git add backend/prisma/
git commit -m "feat(database): define core relational schema and initial migrations"
git push origin database

# Open Pull Request targeting 'testing-integration' via GitHub UI
```

#### Member 2 — AI/ML Engineer
```bash
# Clone and setup branch
git clone https://github.com/organization/SIH26044-Academia-Industry-Portal.git
cd SIH26044-Academia-Industry-Portal
git checkout -b ai-ml

# Daily work cycle
git pull origin ai-ml
# Implement FastAPI endpoints inside ai_service/
pytest ai_service/test_ai.py
git add ai_service/
git commit -m "feat(ai): implement sentence-bert applicant ranking and skill gap matching"
git push origin ai-ml

# Open Pull Request targeting 'testing-integration'
```

#### Member 3 — Backend Engineer
```bash
# Clone and setup branch
git clone https://github.com/organization/SIH26044-Academia-Industry-Portal.git
cd SIH26044-Academia-Industry-Portal
git checkout -b backend

# Daily work cycle
git pull origin backend
# Implement Express routes, controllers, and services inside backend/src/
npm run test:unit
git add backend/src/
git commit -m "feat(backend): implement auth, internship and application lifecycle controllers"
git push origin backend

# Open Pull Request targeting 'testing-integration'
```

#### Member 4 — Frontend Engineer
```bash
# Clone and setup branch
git clone https://github.com/organization/SIH26044-Academia-Industry-Portal.git
cd SIH26044-Academia-Industry-Portal
git checkout -b frontend

# Daily work cycle
git pull origin frontend
# Implement React components and pages inside frontend/src/
npm run build
git add frontend/src/
git commit -m "feat(frontend): construct student portfolio, ATS tracker and recruiter dashboards"
git push origin frontend

# Open Pull Request targeting 'testing-integration'
```

#### Member 5 — Testing & Integration Lead
```bash
# Checkout integration branch
git checkout -b testing-integration
git pull origin testing-integration

# Fetch and test incoming PRs from team members
git fetch origin database:database
git merge --no-ff database

git fetch origin backend:backend
git merge --no-ff backend

git fetch origin ai-ml:ai-ml
git merge --no-ff ai-ml

git fetch origin frontend:frontend
git merge --no-ff frontend

# Run Full Integration & E2E Test Suite
npm run test:integration
npx playwright test

# Merge into Main and Tag Release
git checkout main
git merge --no-ff testing-integration
git tag -a v1.0.0-PROD -m "Release Phase Completed: All services integrated and verified"
git push origin main --tags
```

---

# SECTION 12 — Integration Checklist

Use this checklist during staging gate reviews before promoting to production:

```markdown
### [ ] 1. Database Tier Readiness
- [ ] PostgreSQL 16 server running with SSL encryption enabled.
- [ ] `prisma migrate status` reports database schema is up-to-date with zero drift.
- [ ] Database seeder executes cleanly (`npx prisma db seed`), creating skills, quizzes, and test accounts.
- [ ] Foreign key constraints, cascade rules, and compound unique indexes verified.

### [ ] 2. Core Backend REST APIs
- [ ] Express server starts with clean environment validation on port 5000.
- [ ] All 26 REST routes mount without routing conflicts.
- [ ] Zod middleware catches malformed JSON and returns standard 400 Bad Request.
- [ ] Global error handler catches unexpected exceptions without terminating the Node process.

### [ ] 3. AI / ML Microservice
- [ ] FastAPI ASGI server starts on port 8000; OpenAPI docs accessible at `/docs`.
- [ ] Sentence-Transformers model (`all-MiniLM-L6-v2`) pre-loads into memory successfully.
- [ ] HMAC signature authentication blocks unauthorized calls to internal AI routes.
- [ ] Inference response latency for batch ranking $\le 150$ms.

### [ ] 4. Frontend & User Experience
- [ ] Vite production build completes (`npm run build`) with zero TypeScript errors.
- [ ] Responsive UI verified on Desktop (1920x1080), Tablet (768x1024), and Mobile (375x812).
- [ ] TanStack Query correctly caches and invalidates queries on successful mutations.
- [ ] Forms provide inline validation feedback and clear error states.

### [ ] 5. Authentication & Security (RBAC)
- [ ] User registration and bcrypt hashing (salt rounds: 12) verified.
- [ ] JWT access token correctly rejected when expired (15m window).
- [ ] HTTP-only, secure, SameSite=Strict cookie rotation verified for refresh tokens.
- [ ] Route guards prevent Students from accessing Company/Teacher routes and vice versa.

### [ ] 6. Media Vault & Cloudinary Integration
- [ ] Cloudinary client authenticated with API keys and secrets.
- [ ] Certificate PDF and image uploads successfully stream to Cloudinary CDN.
- [ ] Signed delivery URLs render correctly inside browser preview modal.

### [ ] 7. End-to-End Placement Lifecycle
- [ ] Company posts internship $\rightarrow$ Appears instantly in Student Catalog.
- [ ] Student applies $\rightarrow$ Eligibility rules enforced (minimum CGPA & profile completion).
- [ ] AI ranker calculates applicant compatibility score $\rightarrow$ Recruiter views ranked table.
- [ ] Company schedules interview $\rightarrow$ Both parties receive email + `.ics` calendar invite.
- [ ] Teacher reviews and approves certificate $\rightarrow$ Verified badge rendered on Student Profile.
- [ ] Dynamic resume generator compiles student data and outputs downloadable PDF.

### [ ] 8. DevOps, CI/CD & Production Deployment
- [ ] GitHub Actions CI pipeline passes all linters, unit tests, and build checks.
- [ ] Vercel frontend edge deployment live with custom domain and automatic SSL.
- [ ] Render / Railway container services running with zero memory leaks.
- [ ] Production health check probe (`GET /health`) returns `200 OK` across all microservices.
```

---

# SECTION 13 — Daily Communication & Handoff Templates

To maintain complete transparency and eliminate integration misunderstandings, every developer posts the following standardized handoff message into the team Slack/Discord channel upon completing tasks in each phase.

### Template 1: Member 1 (Database Engineer)
```text
======================================================
DAILY PHASE HANDOFF — DATABASE TIER
======================================================
Completed by: Member 1 (Database Engineer)
Branch: database
Files changed:
  - backend/prisma/schema.prisma
  - backend/prisma/migrations/20260921_init_schema/migration.sql
  - backend/prisma/seed.ts
Database changes:
  - Added tables: users, students, companies, teachers, skills, verified_skills
  - Created composite unique index on verified_skills [student_id, skill_id]
  - Executed migration and seeded 60 Ayush/STEM skills
Required by next member:
  - Backend Engineer: Run `npx prisma generate` to update Prisma Client types.
Testing status: Migration applied cleanly on staging Postgres; seed verified.
Ready for merge: Yes
======================================================
```

### Template 2: Member 2 (AI/ML Engineer)
```text
======================================================
DAILY PHASE HANDOFF — AI / ML TIER
======================================================
Completed by: Member 2 (AI/ML Engineer)
Branch: ai-ml
Files changed:
  - ai_service/app/endpoints/applicant_ranker.py
  - ai_service/app/services/embedding_service.py
  - ai_service/test_ai.py
APIs added:
  - POST /ai/rank-applicants (Calculates 4-factor composite candidate score)
  - POST /ai/skill-gap (Computes missing skills & maps NPTEL/SWAYAM courses)
Required by next member:
  - Backend Engineer: Point `ai-client.service.ts` to http://localhost:8000.
    Include header: `X-Internal-Secret: <AI_SECRET_KEY>`.
Testing status: 14 Pytest assertions passed. Inference time: 82ms.
Ready for merge: Yes
======================================================
```

### Template 3: Member 3 (Backend Engineer)
```text
======================================================
DAILY PHASE HANDOFF — BACKEND TIER
======================================================
Completed by: Member 3 (Backend Engineer)
Branch: backend
Files changed:
  - backend/src/controllers/internship.controller.ts
  - backend/src/controllers/application.controller.ts
  - backend/src/services/ai-client.service.ts
  - backend/src/routes/internship.routes.ts
APIs added:
  - POST /api/v1/internships (Company post)
  - GET  /api/v1/internships (Student browse & filter)
  - POST /api/v1/applications (Student apply with eligibility guard)
  - GET  /api/v1/companies/internships/:id/applicants (AI ranked list)
Required by next member:
  - Frontend Engineer: Connect `useInternships` and `useApplications` hooks.
Testing status: Supertest suite passed (22 test cases passing).
Ready for merge: Yes
======================================================
```

### Template 4: Member 4 (Frontend Engineer)
```text
======================================================
DAILY PHASE HANDOFF — FRONTEND TIER
======================================================
Completed by: Member 4 (Frontend Engineer)
Branch: frontend
Files changed:
  - frontend/src/pages/company/ApplicantRankingPage.tsx
  - frontend/src/pages/student/SkillGapAdvisorPage.tsx
  - frontend/src/components/company/ApplicantRankTable.tsx
  - frontend/src/services/api/company.api.ts
APIs integrated:
  - GET /api/v1/companies/internships/:id/applicants
  - GET /api/v1/students/skill-gap
Required by next member:
  - Testing Lead: Validate applicant table sorting and NPTEL course card links.
Testing status: Zero TypeScript errors; verified in Chrome, Edge, and Safari.
Ready for merge: Yes
======================================================
```

### Template 5: Member 5 (Testing & Integration Lead)
```text
======================================================
PHASE RELEASE REPORT & GATE APPROVAL
======================================================
Completed by: Member 5 (Testing & Integration Lead)
Branch: testing-integration -> main
PRs Merged:
  - PR #14 (Database Schema Migration v0.4)
  - PR #15 (Backend ATS & AI Client v0.4)
  - PR #16 (AI Microservice Ranking Engine v0.4)
  - PR #17 (Frontend Applicant & Skill Gap Views v0.4)
Actions Taken:
  - Executed Playwright E2E suite across all 3 user roles.
  - Verified Cloudinary asset ingestion and Nodemailer calendar triggers.
  - Deployed build to staging environment: https://staging.sih26044.internal
Release Tag: v0.4.0-beta
Deployment Status: PASSED (Zero regressions detected)
Next Phase Target: Phase 5 (Advanced AI Integration & Interview Scheduling)
======================================================
```

---
*(End of Architecture Specification)*
