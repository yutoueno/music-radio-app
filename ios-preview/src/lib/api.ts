// API configuration
const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api/v1";

// Types
export interface Program {
  id: string;
  title: string;
  broadcaster: string;
  broadcasterId: string;
  duration: string;
  durationSeconds: number;
  genre: string;
  thumbnailColor: string;
  playCount: number;
  favoriteCount: number;
  description: string;
  status: "published" | "draft" | "archived";
  createdAt: string;
}

export interface Broadcaster {
  id: string;
  name: string;
  color: string;
  bio: string;
  followerCount: number;
  followingCount: number;
  showCount: number;
  isFollowing: boolean;
}

export interface Track {
  id: string;
  title: string;
  artist: string;
  timing: string;
  timingSeconds: number;
  duration: string;
  appleMusicId: string;
  artworkColor: string;
}

export interface Notification {
  id: string;
  type: "new_show" | "follow" | "like" | "system";
  title: string;
  body: string;
  read: boolean;
  createdAt: string;
  relatedId?: string;
}

export interface UserProfile {
  id: string;
  nickname: string;
  bio: string;
  avatarColor: string;
  showCount: number;
  followerCount: number;
  followingCount: number;
  favoriteCount: number;
}

export interface AnalyticsOverview {
  totalPlays: number;
  totalPlaysTrend: number; // percentage change
  totalListeners: number;
  totalListenersTrend: number;
  avgListenTime: string;
  avgListenTimeTrend: number;
  totalFollowers: number;
  totalFollowersTrend: number;
}

export interface Inquiry {
  id: string;
  email: string;
  subject: string;
  body: string;
  status: "pending" | "in_progress" | "resolved" | "closed";
  createdAt: string;
  adminNote?: string;
}

// Mock Data
export const mockBroadcasters: Broadcaster[] = [
  { id: "1", name: "DJ Kenta", color: "#7C83FF", bio: "Lo-fi beats & chill vibes. Broadcasting from Tokyo.", followerCount: 1200, followingCount: 48, showCount: 12, isFollowing: true },
  { id: "2", name: "Yuki", color: "#FF6B8A", bio: "Jazz lover, pianist, and late night radio host.", followerCount: 890, followingCount: 32, showCount: 8, isFollowing: true },
  { id: "3", name: "Taro", color: "#4DFF88", bio: "Pop music enthusiast. Weekend vibes only.", followerCount: 2300, followingCount: 120, showCount: 15, isFollowing: false },
  { id: "4", name: "Mika", color: "#FFB84D", bio: "Electronic & ambient soundscapes from Osaka.", followerCount: 560, followingCount: 25, showCount: 6, isFollowing: true },
  { id: "5", name: "Ryo", color: "#83D9FF", bio: "Hip-hop heads unite. Daily beats and bars.", followerCount: 3400, followingCount: 85, showCount: 22, isFollowing: false },
];

export const mockPrograms: Program[] = [
  { id: "1", title: "Late Night Chill Mix", broadcaster: "DJ Kenta", broadcasterId: "1", duration: "32:15", durationSeconds: 1935, genre: "Lo-Fi", thumbnailColor: "#7C83FF", playCount: 1240, favoriteCount: 89, description: "A curated selection of lo-fi beats perfect for late night coding sessions.", status: "published", createdAt: "2026-03-28" },
  { id: "2", title: "Morning Jazz Radio", broadcaster: "Yuki", broadcasterId: "2", duration: "45:00", durationSeconds: 2700, genre: "Jazz", thumbnailColor: "#FF6B8A", playCount: 890, favoriteCount: 67, description: "Start your morning with smooth jazz standards and fresh discoveries.", status: "published", createdAt: "2026-03-27" },
  { id: "3", title: "Weekend Vibes", broadcaster: "Taro", broadcasterId: "3", duration: "28:30", durationSeconds: 1710, genre: "Pop", thumbnailColor: "#4DFF88", playCount: 2100, favoriteCount: 142, description: "The best pop hits to kick off your weekend.", status: "published", createdAt: "2026-03-26" },
  { id: "4", title: "Deep Focus Beats", broadcaster: "Mika", broadcasterId: "4", duration: "55:00", durationSeconds: 3300, genre: "Electronic", thumbnailColor: "#FFB84D", playCount: 670, favoriteCount: 45, description: "Deep electronic beats for maximum concentration.", status: "published", createdAt: "2026-03-25" },
  { id: "5", title: "Tokyo Drift Beats", broadcaster: "Ryo", broadcasterId: "5", duration: "42:10", durationSeconds: 2530, genre: "Hip-Hop", thumbnailColor: "#83D9FF", playCount: 3200, favoriteCount: 210, description: "Hip-hop beats inspired by Tokyo street culture.", status: "published", createdAt: "2026-03-24" },
  { id: "6", title: "Midnight Sessions", broadcaster: "Yuki", broadcasterId: "2", duration: "38:20", durationSeconds: 2300, genre: "Jazz", thumbnailColor: "#FF6B8A", playCount: 780, favoriteCount: 56, description: "Late night jazz sessions for the soul.", status: "published", createdAt: "2026-03-23" },
  { id: "7", title: "Chill Hop Sunday", broadcaster: "DJ Kenta", broadcasterId: "1", duration: "55:00", durationSeconds: 3300, genre: "Lo-Fi", thumbnailColor: "#7C83FF", playCount: 1560, favoriteCount: 112, description: "Sunday morning chill hop to ease into the week.", status: "published", createdAt: "2026-03-22" },
  { id: "8", title: "Neon Nights", broadcaster: "Ryo", broadcasterId: "5", duration: "35:45", durationSeconds: 2145, genre: "Electronic", thumbnailColor: "#83D9FF", playCount: 2890, favoriteCount: 178, description: "Neon-drenched electronic music for night owls.", status: "draft", createdAt: "2026-03-21" },
];

export const mockTracks: Track[] = [
  { id: "t1", title: "Sunset Drive", artist: "Nujabes", timing: "00:00", timingSeconds: 0, duration: "4:30", appleMusicId: "1234", artworkColor: "#7C83FF" },
  { id: "t2", title: "Luv(sic) Part 3", artist: "Nujabes ft. Shing02", timing: "04:30", timingSeconds: 270, duration: "5:45", appleMusicId: "2345", artworkColor: "#FF6B8A" },
  { id: "t3", title: "Reflection Eternal", artist: "Nujabes", timing: "09:15", timingSeconds: 555, duration: "4:45", appleMusicId: "3456", artworkColor: "#4DFF88" },
  { id: "t4", title: "Feather", artist: "Nujabes ft. Cise Starr", timing: "14:00", timingSeconds: 840, duration: "6:12", appleMusicId: "4567", artworkColor: "#FFB84D" },
  { id: "t5", title: "Aruarian Dance", artist: "Nujabes", timing: "20:12", timingSeconds: 1212, duration: "5:03", appleMusicId: "5678", artworkColor: "#83D9FF" },
];

export const mockNotifications: Notification[] = [
  { id: "n1", type: "new_show", title: "New Show", body: "DJ Kenta published 'Late Night Chill Mix'", read: false, createdAt: "2m ago", relatedId: "1" },
  { id: "n2", type: "follow", title: "New Follower", body: "Mika started following you", read: false, createdAt: "15m ago", relatedId: "4" },
  { id: "n3", type: "like", title: "New Favorite", body: "Ryo favorited 'Morning Jazz Radio'", read: true, createdAt: "1h ago", relatedId: "2" },
  { id: "n4", type: "new_show", title: "New Show", body: "Yuki published 'Midnight Sessions'", read: true, createdAt: "3h ago", relatedId: "6" },
  { id: "n5", type: "system", title: "Welcome!", body: "Welcome to CRATE. Start exploring shows!", read: true, createdAt: "1d ago" },
];

export const mockProfile: UserProfile = {
  id: "1",
  nickname: "DJ Kenta",
  bio: "Lo-fi beats & chill vibes. Broadcasting from Tokyo.",
  avatarColor: "#7C83FF",
  showCount: 12,
  followerCount: 1200,
  followingCount: 48,
  favoriteCount: 85,
};

export const mockAnalytics: AnalyticsOverview = {
  totalPlays: 12847,
  totalPlaysTrend: 12.5,
  totalListeners: 3241,
  totalListenersTrend: 8.3,
  avgListenTime: "18:42",
  avgListenTimeTrend: -2.1,
  totalFollowers: 1200,
  totalFollowersTrend: 15.7,
};
