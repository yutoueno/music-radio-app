import { create } from "zustand";
import type { Admin } from "@/types";
import { getToken, removeToken, setToken } from "@/lib/auth";

interface AuthState {
  admin: Admin | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (admin: Admin, token: string) => void;
  logout: () => void;
  initialize: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  admin: null,
  token: null,
  isAuthenticated: false,

  setAuth: (admin: Admin, token: string) => {
    setToken(token);
    set({ admin, token, isAuthenticated: true });
  },

  logout: () => {
    removeToken();
    set({ admin: null, token: null, isAuthenticated: false });
    if (typeof window !== "undefined") {
      window.location.href = "/login";
    }
  },

  initialize: () => {
    const token = getToken();
    if (token) {
      set({ token, isAuthenticated: true });
    }
  },
}));
