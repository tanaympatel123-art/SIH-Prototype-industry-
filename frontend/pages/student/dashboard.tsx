import React from "react";
import Link from "next/link";
import { Navbar } from "../../component/common/Navbar";
import { StatCard } from "../../component/common/StatCard";
import { Badge } from "../../component/common/Badge";
import { useAuth } from "../../hooks/useAuth";
import { GraduationCap, Award, BookOpen, Briefcase, FileText, CheckCircle2, ArrowRight, Sparkles, AlertCircle } from "lucide-react";

export default function StudentDashboard() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen flex flex-col bg-[#F6F9FC]">
      <Navbar />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full flex-1">
        {/* Welcome Header */}
        <div className="bg-gradient-to-r from-[#0A2540] to-blue-900 rounded-2xl p-6 sm:p-8 text-white shadow-lg mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center space-x-2 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-2">
              <GraduationCap className="w-4 h-4" />
              <span>Student Portal • Phase 1 Dashboard</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold">Welcome back, {user?.name || "Alex"}!</h1>
            <p className="mt-1 text-sm text-blue-200">{user?.institution || "National Institute of Technology"}</p>
          </div>

          {/* Profile Completeness Widget */}
          <div className="bg-white/10 backdrop-blur-md border border-white/20 p-4 rounded-xl text-right min-w-[220px]">
            <div className="flex items-center justify-between text-xs text-blue-200 mb-1">
              <span>Profile Completeness</span>
              <span className="font-bold text-white">75%</span>
            </div>
            <div className="w-full bg-blue-950/60 rounded-full h-2.5 overflow-hidden">
              <div className="bg-emerald-400 h-2.5 rounded-full" style={{ width: "75%" }}></div>
            </div>
            <p className="text-[10px] text-blue-300 mt-2 flex items-center justify-end space-x-1">
              <AlertCircle className="w-3 h-3 text-amber-300" />
              <span>Take a quiz to reach 100%</span>
            </p>
          </div>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
          <StatCard title="Verified Skills" value="4 Skills" icon={Award} trend="+1 Teacher Verified" trendType="positive" />
          <StatCard title="Quizzes Completed" value="3 Quizzes" icon={BookOpen} trend="Avg score 88%" trendType="positive" />
          <StatCard title="Active Applications" value="2 Jobs" icon={Briefcase} trend="1 Under Review" trendType="neutral" />
          <StatCard title="AI Resume Status" value="Optimized" icon={FileText} trend="ATS Ready" trendType="positive" />
        </div>

        {/* Dashboard Sections */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Action Cards (Left 2 cols) */}
          <div className="lg:col-span-2 space-y-6">
            {/* Quick Actions */}
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center space-x-2">
                <Sparkles className="w-5 h-5 text-emerald-500" />
                <span>Phase 1 Quick Actions</span>
              </h2>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="p-4 rounded-xl border border-gray-100 bg-blue-50/50 hover:bg-blue-50 transition-colors">
                  <div className="flex items-center space-x-3 mb-2">
                    <div className="p-2 rounded-lg bg-blue-600 text-white">
                      <BookOpen className="w-4 h-4" />
                    </div>
                    <h3 className="font-semibold text-gray-900 text-sm">Skill Quiz Diagnostics</h3>
                  </div>
                  <p className="text-xs text-gray-600 mb-3">Test your proficiency in React, Node.js, and Python to get verified.</p>
                  <span className="text-xs font-semibold text-blue-600 flex items-center space-x-1">
                    <span>Feature Ready for Phase 2</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </span>
                </div>

                <div className="p-4 rounded-xl border border-gray-100 bg-emerald-50/50 hover:bg-emerald-50 transition-colors">
                  <div className="flex items-center space-x-3 mb-2">
                    <div className="p-2 rounded-lg bg-emerald-600 text-white">
                      <Briefcase className="w-4 h-4" />
                    </div>
                    <h3 className="font-semibold text-gray-900 text-sm">Internship Search</h3>
                  </div>
                  <p className="text-xs text-gray-600 mb-3">Explore recommended industry postings with AI match score breakdowns.</p>
                  <span className="text-xs font-semibold text-emerald-600 flex items-center space-x-1">
                    <span>Browse Listings</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </span>
                </div>
              </div>
            </div>

            {/* Verified Skills Summary */}
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <h2 className="text-lg font-bold text-gray-900 mb-4">My Verified Skills Profile</h2>
              <div className="flex flex-wrap gap-2">
                <Badge variant="success" size="md">React.js (Teacher Verified)</Badge>
                <Badge variant="success" size="md">TypeScript (Quiz Verified)</Badge>
                <Badge variant="primary" size="md">Node.js</Badge>
                <Badge variant="primary" size="md">Python / FastAPI</Badge>
                <Badge variant="neutral" size="md">Git & GitHub</Badge>
              </div>
            </div>
          </div>

          {/* Right Column (Recent Updates & Verification) */}
          <div className="space-y-6">
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <h3 className="font-bold text-gray-900 text-base mb-4">Teacher Verification Status</h3>
              <div className="space-y-3">
                <div className="p-3 rounded-lg bg-emerald-50 border border-emerald-100 flex items-start space-x-3">
                  <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-xs font-semibold text-emerald-900">React.js Certificate Approved</p>
                    <p className="text-[11px] text-emerald-700">Verified by Dr. Sarah Verma</p>
                  </div>
                </div>

                <div className="p-3 rounded-lg bg-amber-50 border border-amber-100 flex items-start space-x-3">
                  <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-xs font-semibold text-amber-900">Python Skill Verification Pending</p>
                    <p className="text-[11px] text-amber-700">Submitted for faculty review</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
