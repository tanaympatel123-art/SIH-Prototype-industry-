import React, { useState } from "react";
import { useRouter } from "next/router";
import { Navbar } from "../component/common/Navbar";
import { useAuth, UserRole } from "../hooks/useAuth";
import { GraduationCap, Building2, UserCheck, ArrowRight, ShieldCheck } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [selectedRole, setSelectedRole] = useState<UserRole>("student");
  const [email, setEmail] = useState("alex.johnson@university.edu");
  const [password, setPassword] = useState("password123");

  const handleRoleSelect = (role: UserRole) => {
    setSelectedRole(role);
    if (role === "student") setEmail("alex.johnson@university.edu");
    if (role === "company") setEmail("recruitment@techcorp.com");
    if (role === "teacher") setEmail("s.verma@university.edu");
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedRole) {
      login(selectedRole, email);
      router.push(`/${selectedRole}/dashboard`);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#F6F9FC]">
      <Navbar />

      <main className="flex-1 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full bg-white rounded-2xl p-8 border border-gray-100 shadow-xl">
          <div className="text-center">
            <h2 className="text-2xl font-extrabold text-gray-900">Welcome to SIH26044</h2>
            <p className="mt-2 text-sm text-gray-600">Select your role to access the portal dashboard</p>
          </div>

          {/* Role Selection Tabs */}
          <div className="mt-8 grid grid-cols-3 gap-3 p-1.5 bg-gray-100 rounded-xl">
            <button
              type="button"
              onClick={() => handleRoleSelect("student")}
              className={`flex flex-col items-center justify-center p-3 rounded-lg text-xs font-semibold transition-all ${
                selectedRole === "student"
                  ? "bg-white text-blue-700 shadow-sm border border-gray-200"
                  : "text-gray-500 hover:text-gray-900"
              }`}
            >
              <GraduationCap className="w-5 h-5 mb-1" />
              <span>Student</span>
            </button>

            <button
              type="button"
              onClick={() => handleRoleSelect("company")}
              className={`flex flex-col items-center justify-center p-3 rounded-lg text-xs font-semibold transition-all ${
                selectedRole === "company"
                  ? "bg-white text-emerald-700 shadow-sm border border-gray-200"
                  : "text-gray-500 hover:text-gray-900"
              }`}
            >
              <Building2 className="w-5 h-5 mb-1" />
              <span>Company</span>
            </button>

            <button
              type="button"
              onClick={() => handleRoleSelect("teacher")}
              className={`flex flex-col items-center justify-center p-3 rounded-lg text-xs font-semibold transition-all ${
                selectedRole === "teacher"
                  ? "bg-white text-indigo-700 shadow-sm border border-gray-200"
                  : "text-gray-500 hover:text-gray-900"
              }`}
            >
              <UserCheck className="w-5 h-5 mb-1" />
              <span>Teacher</span>
            </button>
          </div>

          {/* Login Form */}
          <form onSubmit={handleLogin} className="mt-6 space-y-4">
            <div>
              <label className="block text-xs font-medium text-gray-700">Email Address</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 block w-full px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-700">Password</label>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="mt-1 block w-full px-3 py-2 rounded-lg border border-gray-300 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="pt-2">
              <button
                type="submit"
                className="w-full py-3 px-4 rounded-xl bg-[#0A2540] hover:bg-blue-900 text-white font-semibold text-sm shadow-md transition-all flex items-center justify-center space-x-2"
              >
                <span>Enter {selectedRole ? selectedRole.toUpperCase() : ""} Portal</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </form>

          <div className="mt-6 pt-4 border-t border-gray-100 flex items-center justify-center space-x-1 text-xs text-gray-500">
            <ShieldCheck className="w-4 h-4 text-emerald-500" />
            <span>Phase 1 Authentication & Role Switcher Active</span>
          </div>
        </div>
      </main>
    </div>
  );
}
