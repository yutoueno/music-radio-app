// API Response types
export interface ApiResponse<T> {
  data: T;
  meta?: PaginationMeta;
}

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
  has_next: boolean;
}

// Backend error format: {"detail": {"code": "...", "message": "..."}}
export interface ApiErrorDetail {
  code: string;
  message: string;
}

// Auth
export interface LoginRequest {
  email: string;
  password: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
}

export interface Admin {
  id: string;
  email: string;
  name: string;
}

// UserProfile (nested in User)
export interface UserProfile {
  id: string;
  user_id: string;
  nickname: string;
  avatar_url: string | null;
  wallpaper_url: string | null;
  message: string | null;
  follower_count: number;
  created_at: string;
  updated_at: string;
}

// User (matches backend AdminUserResponse)
export interface User {
  id: string;
  email: string;
  is_active: boolean;
  is_admin: boolean;
  email_verified: boolean;
  profile: UserProfile | null;
  created_at: string;
  updated_at: string;
}

// Program (matches backend ProgramResponse)
export interface Program {
  id: string;
  user_id: string;
  title: string;
  description: string | null;
  audio_url: string | null;
  thumbnail_url: string | null;
  status: "draft" | "published" | "archived";
  program_type: string;
  genre: string | null;
  scheduled_at: string | null;
  play_count: number;
  favorite_count: number;
  duration_seconds: number | null;
  waveform_data: Record<string, unknown> | null;
  tracks: Track[];
  user_nickname: string | null;
  created_at: string;
  updated_at: string;
}

// Genre with count
export interface GenreCount {
  genre: string;
  count: number;
}

// Track (matches backend TrackResponse)
export interface Track {
  id: string;
  program_id: string;
  apple_music_url: string | null;
  apple_music_track_id: string | null;
  title: string;
  artist_name: string;
  artwork_url: string | null;
  play_timing_seconds: number;
  duration_seconds: number | null;
  track_order: number;
  created_at: string;
}

// Inquiry (matches backend InquiryResponse)
export interface Inquiry {
  id: string;
  user_id: string | null;
  email: string;
  subject: string;
  body: string;
  status: "pending" | "in_progress" | "resolved" | "closed";
  admin_note: string | null;
  created_at: string;
  updated_at: string;
}

// Dashboard (matches backend GET /admin/dashboard)
export interface DashboardStats {
  total_users: number;
  total_programs: number;
  published_programs: number;
  total_plays: number;
  total_favorites: number;
  total_follows: number;
}

// Reports (matches backend GET /admin/reports)
export interface ReportsData {
  top_programs_by_plays: ReportProgram[];
  top_programs_by_favorites: ReportProgram[];
  play_count_trends: TrendDataPoint[];
  new_user_trends: TrendDataPoint[];
}

export interface TrendDataPoint {
  date: string;
  count: number;
}

// Daily Analytics (matches backend GET /admin/analytics/daily)
export interface DailyAnalyticsData {
  daily_plays: TrendDataPoint[];
  summary: DailyAnalyticsSummary;
}

export interface DailyAnalyticsSummary {
  total_plays: number;
  growth_percent: number;
  most_active_day: string | null;
  most_active_count: number;
  period_days: number;
  period_start: string;
  period_end: string;
}

export interface ReportProgram {
  id: string;
  title: string;
  play_count?: number;
  favorite_count?: number;
  user_id: string;
}

// Broadcaster detail (matches backend GET /admin/broadcasters/{user_id})
export interface BroadcasterProgram {
  id: string;
  title: string;
  status: "draft" | "published" | "archived";
  play_count: number;
  favorite_count: number;
  genre: string | null;
  duration_seconds: number | null;
  track_count: number;
  created_at: string;
}

export interface BroadcasterStats {
  total_programs: number;
  total_plays: number;
  total_favorites: number;
  follower_count: number;
  following_count: number;
}

export interface BroadcasterProfile extends UserProfile {
  following_count: number;
}

export interface BroadcasterDetail {
  id: string;
  email: string;
  is_active: boolean;
  is_admin: boolean;
  email_verified: boolean;
  profile: BroadcasterProfile | null;
  programs: BroadcasterProgram[];
  stats: BroadcasterStats;
  created_at: string;
  updated_at: string;
}

// Query params
export interface PaginationParams {
  page?: number;
  per_page?: number;
}

export interface UserListParams extends PaginationParams {
  search?: string;
  role?: string;
  status?: string;
  sort_by?: string;
  sort_order?: "asc" | "desc";
}

export interface ProgramListParams extends PaginationParams {
  search?: string;
  status?: string;
  broadcaster_id?: string;
  genre?: string;
  sort_by?: string;
  sort_order?: "asc" | "desc";
}

export interface InquiryListParams extends PaginationParams {
  status?: string;
  search?: string;
}
