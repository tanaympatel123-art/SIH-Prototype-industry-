import React, { createContext, useContext, useState, useEffect, ReactNode } from "react";

export type UserRole = "student" | "company" | "teacher" | null;

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  institution?: string;
  companyName?: string;
  completionRate?: number;
}

interface AuthContextType {
  user: UserProfile | null;
  role: UserRole;
  login: (role: UserRole, email?: string) => void;
  logout: () => void;
  switchRole: (role: UserRole) => void;
}

const defaultProfiles: Record<NonNullable<UserRole>, UserProfile> = {
  student: {
    id: "stu_101",
    name: "Alex Johnson",
    email: "alex.johnson@university.edu",
    role: "student",
    institution: "National Institute of Technology",
    completionRate: 75,
  },
  company: {
    id: "comp_202",
    name: "TechCorp Industries",
    email: "recruitment@techcorp.com",
    role: "company",
    companyName: "TechCorp Global Solutions",
  },
  teacher: {
    id: "teach_303",
    name: "Dr. Sarah Verma",
    email: "s.verma@university.edu",
    role: "teacher",
    institution: "National Institute of Technology - CS Dept",
  },
};

const AuthContext = createContext<AuthContextType>({
  user: null,
  role: null,
  login: () => {},
  logout: () => {},
  switchRole: () => {},
});

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [role, setRole] = useState<UserRole>(null);
  const [user, setUser] = useState<UserProfile | null>(null);

  useEffect(() => {
    const savedRole = localStorage.getItem("sih_user_role") as UserRole;
    if (savedRole && defaultProfiles[savedRole]) {
      setRole(savedRole);
      setUser(defaultProfiles[savedRole]);
    } else {
      // Default to student for seamless dev preview
      setRole("student");
      setUser(defaultProfiles["student"]);
    }
  }, []);

  const login = (selectedRole: UserRole, email?: string) => {
    if (selectedRole && defaultProfiles[selectedRole]) {
      const updatedUser = {
        ...defaultProfiles[selectedRole],
        email: email || defaultProfiles[selectedRole].email,
      };
      setRole(selectedRole);
      setUser(updatedUser);
      localStorage.setItem("sih_user_role", selectedRole);
    }
  };

  const switchRole = (newRole: UserRole) => {
    if (newRole && defaultProfiles[newRole]) {
      setRole(newRole);
      setUser(defaultProfiles[newRole]);
      localStorage.setItem("sih_user_role", newRole);
    }
  };

  const logout = () => {
    setRole(null);
    setUser(null);
    localStorage.removeItem("sih_user_role");
  };

  return (
    <AuthContext.Provider value={{ user, role, login, logout, switchRole }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
