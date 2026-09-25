import React from "react";
import Link from "next/link";
import { useAuth, UserRole } from "../../hooks/useAuth";
import { GraduationCap, Building2, UserCheck, LogOut, Sparkles, LayoutDashboard } from "lucide-react";

export const Navbar: React.FC = () => {
  const { user, role, switchRole, logout } = useAuth();

  return (
    <header className="sticky top-0 z-50 bg-[#0A2540] text-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        {/* Logo */}
        <Link href="/" className="flex items-center space-x-3">
          <div className="bg-emerald-500 text-white p-2 rounded-lg shadow-sm">
            <Sparkles className="w-5 h-5" />
          </div>
          <div>
            <span className="font-bold text-lg tracking-tight">SIH26044</span>
            <span className="hidden sm:inline-block text-xs bg-blue-900/60 text-blue-200 px-2 py-0.5 rounded ml-2 font-mono">
              Academia-Industry Portal
            </span>
          </div>
        </Link>

        {/* Navigation & Role Switcher */}
        {role && user ? (
          <div className="flex items-center space-x-6">
            {/* Navigation links based on active role */}
            <nav className="hidden md:flex items-center space-x-4 text-sm font-medium">
              <Link
                href={`/${role}/dashboard`}
                className="flex items-center space-x-1.5 px-3 py-1.5 rounded-md hover:bg-white/10 transition-colors text-blue-100"
              >
                <LayoutDashboard className="w-4 h-4" />
                <span>Dashboard</span>
              </Link>
            </nav>

            {/* Quick Role Switcher for Demo */}
            <div className="flex items-center bg-blue-950/80 p-1 rounded-lg border border-blue-800/60 text-xs">
              <button
                onClick={() => switchRole("student")}
                className={`flex items-center space-x-1 px-2.5 py-1 rounded-md transition-all ${
                  role === "student"
                    ? "bg-blue-600 text-white font-semibold shadow-sm"
                    : "text-blue-300 hover:text-white"
                }`}
              >
                <GraduationCap className="w-3.5 h-3.5" />
                <span>Student</span>
              </button>
              <button
                onClick={() => switchRole("company")}
                className={`flex items-center space-x-1 px-2.5 py-1 rounded-md transition-all ${
                  role === "company"
                    ? "bg-blue-600 text-white font-semibold shadow-sm"
                    : "text-blue-300 hover:text-white"
                }`}
              >
                <Building2 className="w-3.5 h-3.5" />
                <span>Company</span>
              </button>
              <button
                onClick={() => switchRole("teacher")}
                className={`flex items-center space-x-1 px-2.5 py-1 rounded-md transition-all ${
                  role === "teacher"
                    ? "bg-blue-600 text-white font-semibold shadow-sm"
                    : "text-blue-300 hover:text-white"
                }`}
              >
                <UserCheck className="w-3.5 h-3.5" />
                <span>Teacher</span>
              </button>
            </div>

            {/* User Info & Logout */}
            <div className="flex items-center space-x-3">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-semibold text-white">{user.name}</p>
                <p className="text-[10px] text-blue-300 capitalize">{role} Portal</p>
              </div>
              <button
                onClick={logout}
                title="Logout"
                className="p-1.5 rounded-lg hover:bg-rose-500/20 text-rose-300 hover:text-rose-200 transition-colors"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          </div>
        ) : (
          <div className="flex items-center space-x-3">
            <Link
              href="/login"
              className="text-sm font-medium px-4 py-2 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white transition-colors"
            >
              Sign In / Select Role
            </Link>
          </div>
        )}
      </div>
    </header>
  );
};
