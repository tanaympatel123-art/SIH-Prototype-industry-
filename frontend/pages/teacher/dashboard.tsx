import React from "react";
import Link from "next/link";
import { Navbar } from "../../component/common/Navbar";
import { StatCard } from "../../component/common/StatCard";
import { Badge } from "../../component/common/Badge";
import { useAuth } from "../../hooks/useAuth";
import { UserCheck, ShieldCheck, FileCheck, Users, CheckCircle2, Clock, ArrowRight, Sparkles } from "lucide-react";

export default function TeacherDashboard() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen flex flex-col bg-[#F6F9FC]">
      <Navbar />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full flex-1">
        {/* Welcome Header */}
        <div className="bg-gradient-to-r from-[#0A2540] to-indigo-950 rounded-2xl p-6 sm:p-8 text-white shadow-lg mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center space-x-2 text-indigo-300 text-xs font-semibold uppercase tracking-wider mb-2">
              <UserCheck className="w-4 h-4" />
              <span>Teacher Portal • Phase 1 Dashboard</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold">Welcome, {user?.name || "Dr. Sarah Verma"}!</h1>
            <p className="mt-1 text-sm text-blue-200">{user?.institution || "National Institute of Technology - CS Dept"}</p>
          </div>

          <div className="bg-white/10 backdrop-blur-md border border-white/20 p-4 rounded-xl text-center min-w-[200px]">
            <span className="text-2xl font-bold text-emerald-400">12 Pending</span>
            <p className="text-xs text-blue-200 mt-1">Skill Verifications</p>
          </div>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
          <StatCard title="Pending Skill Requests" value="12 Claims" icon={Clock} trend="Requires Review" trendType="negative" />
          <StatCard title="Approved Certifications" value="45 Badges" icon={ShieldCheck} trend="+8 this month" trendType="positive" />
          <StatCard title="Students Mentored" value="64 Students" icon={Users} trend="Active Class" trendType="neutral" />
          <StatCard title="AI OCR Confidence" value="94% Avg" icon={Sparkles} trend="Automated Scan" trendType="positive" />
        </div>

        {/* Dashboard Sections */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Pending Verifications Stream */}
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-bold text-gray-900">Student Skill Verification Requests</h2>
                <span className="text-xs font-semibold text-indigo-600">Phase 1 Queue</span>
              </div>

              <div className="space-y-4">
                {/* Request Item 1 */}
                <div className="p-4 rounded-xl border border-gray-100 bg-gray-50/50 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center space-x-2">
                      <span className="font-bold text-gray-900 text-sm">Alex Johnson</span>
                      <Badge variant="primary">React.js</Badge>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">Submitted: Certificate PDF (Coursera React Advanced)</p>
                    <div className="mt-2 flex items-center space-x-2 text-[11px] text-emerald-600 font-medium">
                      <Sparkles className="w-3.5 h-3.5" />
                      <span>AI OCR Match: 96% Confidence (Name & Issuer Match)</span>
                    </div>
                  </div>

                  <div className="flex items-center space-x-2">
                    <button className="px-3 py-1.5 rounded-lg bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition-colors">
                      Approve Badge
                    </button>
                  </div>
                </div>

                {/* Request Item 2 */}
                <div className="p-4 rounded-xl border border-gray-100 bg-gray-50/50 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center space-x-2">
                      <span className="font-bold text-gray-900 text-sm">Priya Sharma</span>
                      <Badge variant="accent">Python Data Structures</Badge>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">Submitted: NPTEL Certificate</p>
                    <div className="mt-2 flex items-center space-x-2 text-[11px] text-emerald-600 font-medium">
                      <Sparkles className="w-3.5 h-3.5" />
                      <span>AI OCR Match: 92% Confidence</span>
                    </div>
                  </div>

                  <div className="flex items-center space-x-2">
                    <button className="px-3 py-1.5 rounded-lg bg-emerald-600 text-white text-xs font-semibold hover:bg-emerald-700 transition-colors">
                      Approve Badge
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: Faculty Activity */}
          <div className="space-y-6">
            <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
              <h3 className="font-bold text-gray-900 text-base mb-4">Faculty Guidelines</h3>
              <div className="text-xs text-gray-600 space-y-3">
                <p>1. AI OCR automatically inspects uploaded certificate PDFs for name consistency and structural anomalies.</p>
                <p>2. Approving a skill claim immediately awards a verified badge to the student's public profile.</p>
                <p>3. Verified skills boost student match score by +10% in company job rankings.</p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
