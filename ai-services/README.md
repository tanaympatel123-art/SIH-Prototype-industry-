# SIH26044 AI Microservice (Role 5: AI/ML/GenAI Developer)

Standalone Python FastAPI AI Microservice serving the Academia-Industry Collaboration Portal. Integrates with the Express REST API backend on port `5000` via proxy routes and circuit breakers.

---

## 🚀 Quick Start

### 1. Requirements
- Python 3.10+
- `pip`

### 2. Installation & Setup
```bash
cd ai-service

# Create virtual environment (optional but recommended)
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Run AI Service
```bash
python main.py
```
Or using Uvicorn directly:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
The server will start on **`http://localhost:8000`**.

Interactive API Docs:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

## 🧪 Run Automated Tests

To run the contract test suite against all AI endpoints:
```bash
python test_ai_service.py
```

---

## ⚙️ Environment Configuration (`.env`)

| Variable | Default | Description |
| :--- | :--- | :--- |
| `PORT` | `8000` | Port for the FastAPI server |
| `HOST` | `0.0.0.0` | Host IP binding |
| `AI_PROVIDER` | `mock` | `mock` (zero-key mode), `openai`, `groq`, or `ollama` |
| `AI_SERVICE_TIMEOUT_MS` | `2500` | Internal timeout limit in ms before fallback execution |
| `OPENAI_API_KEY` | `""` | API key if using OpenAI provider |
| `GROQ_API_KEY` | `""` | API key if using Groq provider |

---

## 📡 Endpoint Contracts

### 1. Health Check
- `GET /health`
- **Response**: `{"status": "healthy", "service": "SIH26044 AI Engine", "version": "1.0.0", "ai_provider": "mock"}`

### 2. Resume Optimization
- `POST /ai/v1/optimize-resume`
- **Body**: `{"student_id": 1, "target_role": "Frontend Developer", "verified_skills": ["React.js", "JavaScript"], "bio": "Summary..."}`

### 3. Quiz Generation
- `POST /ai/v1/generate-quiz`
- **Body**: `{"skill_id": 12, "skill_name": "React.js", "difficulty": "medium", "num_questions": 5}`

### 4. Skill Gap Analysis
- `POST /ai/v1/skill-gap`
- **Body**: `{"student_id": 1, "current_skills": ["HTML5", "CSS3"], "target_role": "Full Stack Developer"}`
