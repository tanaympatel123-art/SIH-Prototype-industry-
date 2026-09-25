"""
Standalone Automated Verification Suite for SIH26044 AI Microservice.
Verifies all 4 endpoints (GET /health, POST /ai/v1/optimize-resume,
POST /ai/v1/generate-quiz, POST /ai/v1/skill-gap) and verifies contract schemas.
"""

import sys
import os

# Add parent path to sys.path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    print("Testing GET /health...")
    response = client.get("/health")
    assert response.status_code == 200, f"Health check failed: {response.text}"
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "SIH26044 AI Engine"
    print("  [SUCCESS] GET /health ->", data)

def test_optimize_resume():
    print("Testing POST /ai/v1/optimize-resume...")
    payload = {
        "student_id": 1,
        "target_role": "Frontend Developer",
        "verified_skills": ["React.js", "JavaScript", "CSS3"],
        "bio": "Enthusiastic developer with background in building web apps."
    }
    response = client.post("/ai/v1/optimize-resume", json=payload)
    assert response.status_code == 200, f"Resume endpoint failed: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    assert "professional_summary" in data
    assert len(data["bullet_points"]) >= 3
    assert len(data["suggested_keywords"]) >= 1
    print("  [SUCCESS] POST /ai/v1/optimize-resume -> Bullet count:", len(data["bullet_points"]))

def test_generate_quiz():
    print("Testing POST /ai/v1/generate-quiz...")
    payload = {
        "skill_id": 12,
        "skill_name": "React.js",
        "difficulty": "medium",
        "num_questions": 5
    }
    response = client.post("/ai/v1/generate-quiz", json=payload)
    assert response.status_code == 200, f"Quiz endpoint failed: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    assert data["skill_id"] == 12
    assert len(data["questions"]) == 5
    for q in data["questions"]:
        assert "question" in q
        assert len(q["options"]) == 4
        assert 0 <= q["correct_answer"] <= 3
        assert "explanation" in q
    print("  [SUCCESS] POST /ai/v1/generate-quiz -> Generated", len(data["questions"]), "questions")

def test_skill_gap():
    print("Testing POST /ai/v1/skill-gap...")
    payload = {
        "student_id": 1,
        "current_skills": ["HTML5", "CSS3", "JavaScript"],
        "target_role": "Full Stack Developer"
    }
    response = client.post("/ai/v1/skill-gap", json=payload)
    assert response.status_code == 200, f"Skill gap endpoint failed: {response.text}"
    data = response.json()
    assert data["status"] == "success"
    assert "readiness_score" in data
    assert len(data["missing_skills"]) > 0
    assert len(data["learning_path"]) > 0
    print("  [SUCCESS] POST /ai/v1/skill-gap -> Readiness:", data["readiness_score"], "%, Missing skills:", data["missing_skills"])

if __name__ == "__main__":
    print("=== STARTING AI SERVICE CONTRACT VERIFICATION ===")
    test_health_check()
    test_optimize_resume()
    test_generate_quiz()
    test_skill_gap()
    print("=== ALL AI SERVICE TESTS PASSED SUCCESSFULLY! ===")
