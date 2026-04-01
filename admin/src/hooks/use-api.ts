"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";
import type {
  ApiResponse,
  User,
  Program,
  Track,
  DashboardStats,
  ReportsData,
  DailyAnalyticsData,
  BroadcasterDetail,
  UserListParams,
  ProgramListParams,
  InquiryListParams,
  Inquiry,
  GenreCount,
} from "@/types";

// Dashboard
export function useDashboardStats() {
  return useQuery({
    queryKey: ["dashboard", "stats"],
    queryFn: () => apiClient.get<ApiResponse<DashboardStats>>("/admin/dashboard"),
  });
}

// Reports (top programs by plays and favorites)
export function useReports() {
  return useQuery({
    queryKey: ["reports"],
    queryFn: () => apiClient.get<ApiResponse<ReportsData>>("/admin/reports"),
  });
}

// Daily Analytics
export function useDailyAnalytics(days: number = 30) {
  return useQuery({
    queryKey: ["analytics", "daily", days],
    queryFn: () =>
      apiClient.get<ApiResponse<DailyAnalyticsData>>("/admin/analytics/daily", { days }),
  });
}

// Users
export function useUsers(params: UserListParams) {
  return useQuery({
    queryKey: ["users", params],
    queryFn: () =>
      apiClient.get<ApiResponse<User[]>>("/admin/users", params as Record<string, string | number | undefined>),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ["users", id],
    queryFn: async () => {
      // Fetch all users and find the one with matching id
      // Since backend doesn't have a single user endpoint, get from list
      const response = await apiClient.get<ApiResponse<User[]>>("/admin/users", { per_page: 100 });
      const user = response.data.find((u: User) => u.id === id);
      if (!user) throw new Error("ユーザーが見つかりません");
      return { data: user } as ApiResponse<User>;
    },
    enabled: !!id,
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: { is_active?: boolean; is_admin?: boolean } }) =>
      apiClient.patch<ApiResponse<User>>(`/admin/users/${id}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
  });
}

export function useSuspendUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) =>
      apiClient.patch<ApiResponse<User>>(`/admin/users/${id}`, { is_active: false }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
  });
}

export function useActivateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) =>
      apiClient.patch<ApiResponse<User>>(`/admin/users/${id}`, { is_active: true }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
  });
}

// Broadcasters
export function useBroadcaster(id: string) {
  return useQuery({
    queryKey: ["broadcasters", id],
    queryFn: () =>
      apiClient.get<ApiResponse<BroadcasterDetail>>(`/admin/broadcasters/${id}`),
    enabled: !!id,
  });
}

// Programs
export function usePrograms(params: ProgramListParams) {
  return useQuery({
    queryKey: ["programs", params],
    queryFn: () =>
      apiClient.get<ApiResponse<Program[]>>("/admin/programs", params as Record<string, string | number | undefined>),
  });
}

export function useProgram(id: string) {
  return useQuery({
    queryKey: ["programs", id],
    queryFn: async () => {
      // Fetch from program list and find matching
      const response = await apiClient.get<ApiResponse<Program[]>>("/admin/programs", { per_page: 100 });
      const program = response.data.find((p: Program) => p.id === id);
      if (!program) throw new Error("番組が見つかりません");
      return { data: program } as ApiResponse<Program>;
    },
    enabled: !!id,
  });
}

export function useProgramTracks(programId: string) {
  return useQuery({
    queryKey: ["programs", programId, "tracks"],
    queryFn: () =>
      apiClient.get<ApiResponse<Track[]>>(`/tracks/program/${programId}`),
    enabled: !!programId,
  });
}

export function useUpdateProgramStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      apiClient.patch<ApiResponse<Program>>(`/admin/programs/${id}`, { status }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["programs"] });
    },
  });
}

// Genres
export function useGenres() {
  return useQuery({
    queryKey: ["genres"],
    queryFn: () =>
      apiClient.get<ApiResponse<GenreCount[]>>("/programs/genres"),
  });
}

// Inquiries
export function useInquiries(params: InquiryListParams) {
  return useQuery({
    queryKey: ["inquiries", params],
    queryFn: () =>
      apiClient.get<ApiResponse<Inquiry[]>>("/admin/inquiries", params as Record<string, string | number | undefined>),
  });
}

export function useInquiry(id: string) {
  return useQuery({
    queryKey: ["inquiries", id],
    queryFn: () =>
      apiClient.get<ApiResponse<Inquiry>>(`/admin/inquiries/${id}`),
    enabled: !!id,
  });
}

export function useUpdateInquiry() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: { status?: string; admin_note?: string } }) =>
      apiClient.patch<ApiResponse<Inquiry>>(`/admin/inquiries/${id}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inquiries"] });
    },
  });
}
