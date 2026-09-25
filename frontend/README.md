# SIH26044 Frontend Prototype (Phase 1 Foundation & Architecture Fix)

This is the Next.js / React frontend web application for the **SIH26044 Academia-Industry Collaboration Portal**.

## 🛡️ Express Gateway Routing Architecture

The frontend strictly communicates with the **Express Backend Gateway on Port 5000** via `NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1`. 

Direct browser access to internal Python AI microservices (Port 8000) is **disabled** to enforce:
1. JWT authentication & Role-Based Access Control (RBAC).
2. Express 3000ms Circuit Breaker with deterministic database fallbacks.
3. CORS isolation and backend security.

### Gateway Endpoint Mapping:
- **Resume Optimizer**: `POST ${NEXT_PUBLIC_API_URL}/ai/resume/generate`
- **Quiz Generator**: `POST ${NEXT_PUBLIC_API_URL}/ai/quiz/generate`
- **Skill Gap Analyzer**: `POST ${NEXT_PUBLIC_API_URL}/ai/skill-gap`

## 🚀 Phase 1 Features Delivered

1. **Repository & Infrastructure Setup**:
   - Next.js Pages Router with TypeScript.
   - Tailwind CSS configuration with custom SIH26044 brand palette (`#0A2540` Primary Navy, `#F6F9FC` Background, `#24B47E` Success Green).
   - PostCSS & Lucide React Icon integrations.

2. **Role-Aware Navigation & State Management**:
   - `useAuth` hook and `AuthProvider` context managing active sessions and role switching (`Student`, `Company`, `Teacher`).
   - Sticky global `Navbar` with instant role switching tabs for seamless demo presentation.

3. **Landing & Authentication**:
   - **Landing Page (`/`)**: Hero section, portal feature overview, microservice architecture highlights.
   - **Login & Role Selection Page (`/login`)**: Role selector tabs for Student, Company, and Teacher with pre-filled demo accounts.

4. **Role Dashboards**:
   - **Student Dashboard (`/student/dashboard`)**: Profile completeness meter, verified skill badge matrix, diagnostic quiz triggers.
   - **Company Dashboard (`/company/dashboard`)**: Job postings stream, applicant roster, top candidate AI match preview (`92% Match`).
   - **Teacher Dashboard (`/teacher/dashboard`)**: Skill verification queue, AI OCR confidence metrics, badge approval workflow.

## 🛠️ How to Run Locally

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Run dev server (runs on http://localhost:3000)
npm run dev
```

## ⚙️ Environment Configuration

Set in `.env`, `.env.local`, and `.env.example`:

```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1
```
