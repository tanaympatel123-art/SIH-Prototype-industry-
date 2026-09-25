import React from "react";
import Link from "next/link";
import { Navbar } from "../component/common/Navbar";
import { GraduationCap, Building2, UserCheck, Sparkles, Award, ArrowRight, ShieldCheck, Cpu } from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen flex flex-col bg-[#F6F9FC]">
      <Navbar />

      {/* Hero Section */}
      <section className="bg-gradient-to-b from-[#0A2540] to-blue-950 text-white pt-16 pb-24 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
        <div className="max-w-5xl mx-auto text-center relative z-10">
          <div className="inline-flex items-center space-x-2 bg-blue-900/60 border border-blue-700/50 px-3 py-1 rounded-full text-xs font-semibold text-blue-200 mb-6">
            <Sparkles className="w-3.5 h-3.5 text-emerald-400" />
            <span>SIH26044 AI-Powered Ecosystem</span>
          </div>
          <h1 className="text-4xl sm:text-6xl font-extrabold tracking-tight leading-tight">
            Bridging Academia & Industry with <span className="text-emerald-400">Intelligent Matchmaking</span>
          </h1>
          <p className="mt-6 text-lg sm:text-xl text-blue-100 max-w-3xl mx-auto leading-relaxed">
            Empowering students with verified skill credentials, connecting top industry recruiters with job-ready candidates, and assisting faculty with automated verification.
          </p>

          <div className="mt-10 flex flex-wrap justify-center gap-4">
            <Link
              href="/login"
              className="px-8 py-3.5 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-semibold shadow-lg hover:shadow-emerald-500/25 transition-all flex items-center space-x-2"
            >
              <span>Get Started / Enter Portal</span>
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </section>

      {/* 3 Main Role Portals */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 -mt-12 mb-20 relative z-20">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Student Portal Card */}
          <div className="bg-white rounded-2xl p-8 border border-gray-100 shadow-xl hover:shadow-2xl transition-all flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center mb-6">
                <GraduationCap className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-gray-900">Student Portal</h3>
              <p className="mt-3 text-sm text-gray-600 leading-relaxed">
                Take dynamic AI quizzes, build verified skill profiles, generate ATS-optimized resumes, and apply for matched internships.
              </p>
            </div>
            <div className="mt-8 pt-6 border-t border-gray-100">
              <Link
                href="/student/dashboard"
                className="text-sm font-semibold text-blue-600 hover:text-blue-800 flex items-center justify-between"
              >
                <span>Launch Student Dashboard</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>

          {/* Company Portal Card */}
          <div className="bg-white rounded-2xl p-8 border border-gray-100 shadow-xl hover:shadow-2xl transition-all flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center mb-6">
                <Building2 className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-gray-900">Company Portal</h3>
              <p className="mt-3 text-sm text-gray-600 leading-relaxed">
                Post job listings with parsed skill requirements, view explainable candidate match percentages, and schedule interviews.
              </p>
            </div>
            <div className="mt-8 pt-6 border-t border-gray-100">
              <Link
                href="/company/dashboard"
                className="text-sm font-semibold text-emerald-600 hover:text-emerald-800 flex items-center justify-between"
              >
                <span>Launch Company Dashboard</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>

          {/* Teacher Portal Card */}
          <div className="bg-white rounded-2xl p-8 border border-gray-100 shadow-xl hover:shadow-2xl transition-all flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center mb-6">
                <UserCheck className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-bold text-gray-900">Teacher Portal</h3>
              <p className="mt-3 text-sm text-gray-600 leading-relaxed">
                Verify student skill claims and certificates with AI OCR assistance, track class progress, and manage live industry projects.
              </p>
            </div>
            <div className="mt-8 pt-6 border-t border-gray-100">
              <Link
                href="/teacher/dashboard"
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-800 flex items-center justify-between"
              >
                <span>Launch Teacher Dashboard</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Architecture Highlights */}
      <section className="bg-white py-16 border-t border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">Engineered for Transparency & Performance</h2>
            <p className="mt-3 text-gray-600">Phase 1 Foundation architecture integrated with robust microservices.</p>
          </div>

          <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
            <div className="p-6 rounded-xl bg-gray-50 border border-gray-100">
              <Cpu className="w-8 h-8 text-blue-600 mx-auto mb-4" />
              <h4 className="font-bold text-gray-900">Multi-Provider AI Service</h4>
              <p className="mt-2 text-xs text-gray-600">FastAPI microservice proxying OpenAI, Groq, and local Ollama models with sub-10ms fallback execution.</p>
            </div>
            <div className="p-6 rounded-xl bg-gray-50 border border-gray-100">
              <ShieldCheck className="w-8 h-8 text-emerald-600 mx-auto mb-4" />
              <h4 className="font-bold text-gray-900">Teacher-Verified Credentials</h4>
              <p className="mt-2 text-xs text-gray-600">Skills are verified through automated testing and faculty sign-offs, creating trustworthy candidate pools.</p>
            </div>
            <div className="p-6 rounded-xl bg-gray-50 border border-gray-100">
              <Award className="w-8 h-8 text-indigo-600 mx-auto mb-4" />
              <h4 className="font-bold text-gray-900">Explainable Candidate Ranking</h4>
              <p className="mt-2 text-xs text-gray-600">Transparent match algorithms with skill breakdown indicators instead of black-box hiring scores.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="mt-auto bg-[#0A2540] text-blue-200 py-8 text-center text-sm border-t border-blue-900">
        <p>SIH26044 – Academia-Industry Collaboration Portal Prototype</p>
      </footer>
    </div>
  );
}
