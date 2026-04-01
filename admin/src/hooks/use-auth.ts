"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuthStore } from "@/stores/auth-store";
import { apiClient } from "@/lib/api-client";
import type { LoginRequest, ApiResponse, Admin, TokenResponse } from "@/types";

export function useAuth() {
  const router = useRouter();
  const { admin, isAuthenticated, setAuth, logout, initialize } =
    useAuthStore();

  useEffect(() => {
    initialize();
  }, [initialize]);

  const login = async (credentials: LoginRequest) => {
    const response = await apiClient.post<ApiResponse<TokenResponse>>(
      "/auth/login",
      credentials
    );
    const token = response.data.access_token;
    const adminUser: Admin = {
      id: "",
      email: credentials.email,
      name: "管理者",
    };
    setAuth(adminUser, token);
    router.push("/dashboard");
  };

  return {
    admin,
    isAuthenticated,
    login,
    logout,
  };
}

export function useRequireAuth() {
  const router = useRouter();
  const { isAuthenticated, initialize } = useAuthStore();

  useEffect(() => {
    initialize();
    const token = localStorage.getItem("admin_token");
    if (!token) {
      router.push("/login");
    }
  }, [initialize, router]);

  return { isAuthenticated };
}
