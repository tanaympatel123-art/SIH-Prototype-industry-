import React from "react";
import Link from "next/link";
import { Navbar } from "../../component/common/Navbar";
import { StatCard } from "../../component/common/StatCard";
import { Badge } from "../../component/common/Badge";
import { useAuth } from "../../hooks/useAuth";
import { Building2, Users, Briefcase, TrendingUp, Plus, ArrowRight, Sparkles, CheckCircle2 } from "lucide-react";

export default function CompanyDashboard() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen flex flex-col bg-[#F6F9FC]">
      <Navbar />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full flex-1">
        {/* Welcome Header */}
        <div className="bg-gradient-to-r from-[#0A2540] to-emerald-950 rounded-2xl p-6 sm:p-8 text-white shadow-lg mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center space-x-2 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-2">
              <Building2 className="w-4 h-4" />
              <span>Company Recruitment Portal • Phase 1 Dashboard</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold">Welcome, {user?.name || "TechCorp Industries"}!</h1>
            <p className="mt-1 text-sm text-blue-200">Manage internship postings and explainable candidate rankings</p>
          </div>

          <button className="px-5 py-3 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-semibold shadow-md transition-all flex items-center space-x-2">
            <Plus className="w-4 h-4" />
            <span>Post New Internship</span>
          </button>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
          <StatCard title="Active Postings" value="3 Jobs" icon={Briefcase} trend="2 Full-time / 1 Intern" trendType="neutral" />
          <StatCard title="Total Applicants" value="28 Candidates" icon={Users} trend="+12 this week" trendType="positive" />
          <StatCard title="Top Candidate Match" value="92% Match" icon={Sparkles} trend="React + Node.js" trendType="positive" />
          <StatCard title="Interviews Scheduled" value="5 Interviews" icon={TrendingUp} trend="2 Today" trendType="positive" />
        </div>

        {/* Dashboard Sections */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Active Job Postings List */}
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-bold text-gray-900">Active Opportunities</h2>
                <span className="text-xs font-semibold text-emerald-600">3 Published</span>
              </div>

              <div className="space-y-4">
                {/* Posting Item 1 */}
                <div className="p-4 rounded-xl border border-gray-100 bg-gray-50/50 hover:bg-gray-50 transition-colors flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-gray-900 text-sm">Frontend Developer Intern</h3>
                    <p className="text-xs text-gray-500 mt-0.5">Posted 3 days ago • Remote / Hybrid</p>
                    <div className="flex gap-1.5 mt-2">
                      <Badge variant="primary">React.js</Badge>
                      <Badge variant="primary">TypeScript</Badge>
                      <Badge variant="neutral">Tailwind</Badge>
                    </div>
                  </div>
                  <div className="text-right">
                    <span className="text-sm font-bold text-gray-900">14 Applicants</span>
                    <p className="text-xs text-emerald-600 font-semibold mt-1">Top Match: 92%</p>
                  </div>
                </div>

                {/* Posting Item 2 */}
                <div className="p-4 rounded-xl border border-gray-100 bg-gray-50/50 hover:bg-gray-50 transition-colors flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-gray-900 text-sm">Fullstack AI Engineer</h3>
                    <p className="text-xs text-gray-500 mt-0.5">Posted 1 week ago • On-site</p>
                    <div className="flex gap-1.5 mt-2">
                      <Badge variant="accent">Python</Badge>
                      <Badge variant="accent">FastAPI</Badge>
                      <Badge variant="success">Teacher Verified</Badge>
                    </div>
                  </div>
                  <div className="text-right">
                    <span className="text-sm font-bold text-gray-900">14 Applicants</span>
                    <p className="text-xs text-emerald-600 font-semibold mt-1">Top Match: 88%</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: AI Ranking Preview */}
          <div className="space-y-6">
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <h3 className="font-bold text-gray-900 text-base mb-4 flex items-center space-x-2">
                <Sparkles className="w-4 h-4 text-emerald-500" />
                <span>Top Candidate Match</span>
              </h3>

              <div className="p-4 rounded-xl bg-emerald-50/60 border border-emerald-100">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-emerald-900">Alex Johnson</span>
                  <span className="text-xs font-extrabold bg-emerald-600 text-white px-2 py-0.5 rounded-full">
                    92% Match
                  </span>
                </div>
                <p className="text-[11px] text-emerald-700 mt-1">Verified credentials in React & TypeScript</p>

                <div className="mt-3 pt-3 border-t border-emerald-200/60 text-[11px] text-gray-600 space-y-1">
                  <p className="flex items-center space-x-1">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>4/4 Required Skills Verified</span>
                  </p>
                  <p className="flex items-center space-x-1">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>88% Quiz Proficiency Score</span>
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
