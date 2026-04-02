"use client";
import { createContext, useContext, useState, useCallback, ReactNode } from "react";
import { mockPrograms, mockBroadcasters, mockNotifications, mockProfile, type Program, type Broadcaster, type Notification, type UserProfile } from "./api";

interface StoreContext {
  // Favorites
  favorites: Set<string>;
  toggleFavorite: (programId: string) => void;
  isFavorite: (programId: string) => boolean;

  // Follows
  follows: Set<string>;
  toggleFollow: (broadcasterId: string) => void;
  isFollowing: (broadcasterId: string) => boolean;

  // Search
  searchQuery: string;
  setSearchQuery: (q: string) => void;
  selectedGenre: string;
  setSelectedGenre: (g: string) => void;

  // Programs
  programs: Program[];
  getProgram: (id: string) => Program | undefined;
  getProgramsByBroadcaster: (broadcasterId: string) => Program[];
  getFavoritePrograms: () => Program[];
  getFilteredPrograms: () => Program[];

  // Broadcasters
  broadcasters: Broadcaster[];
  getBroadcaster: (id: string) => Broadcaster | undefined;
  getFollowedBroadcasters: () => Broadcaster[];

  // Notifications
  notifications: Notification[];
  unreadCount: number;
  markAsRead: (id: string) => void;
  markAllAsRead: () => void;

  // Profile
  profile: UserProfile;
  updateProfile: (updates: Partial<UserProfile>) => void;

  // Playback
  currentProgramId: string | null;
  playbackProgress: number; // 0-100
  setCurrentProgram: (id: string) => void;
  setPlaybackProgress: (p: number) => void;
  getCurrentProgram: () => Program | undefined;
}

const Store = createContext<StoreContext | null>(null);

export function useStore() {
  const ctx = useContext(Store);
  if (!ctx) throw new Error("useStore must be used within StoreProvider");
  return ctx;
}

export function StoreProvider({ children }: { children: ReactNode }) {
  const [favorites, setFavorites] = useState<Set<string>>(new Set(["1", "2", "3", "4"]));
  const [follows, setFollows] = useState<Set<string>>(new Set(["1", "2", "4"]));
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedGenre, setSelectedGenre] = useState("All");
  const [notifications, setNotifications] = useState(mockNotifications);
  const [profile, setProfile] = useState(mockProfile);
  const [currentProgramId, setCurrentProgramId] = useState<string | null>("1");
  const [playbackProgress, setPlaybackProgress] = useState(38);

  const programs = mockPrograms;
  const broadcasters = mockBroadcasters;

  const toggleFavorite = useCallback((programId: string) => {
    setFavorites(prev => {
      const next = new Set(prev);
      if (next.has(programId)) next.delete(programId);
      else next.add(programId);
      return next;
    });
  }, []);

  const isFavorite = useCallback((programId: string) => favorites.has(programId), [favorites]);

  const toggleFollow = useCallback((broadcasterId: string) => {
    setFollows(prev => {
      const next = new Set(prev);
      if (next.has(broadcasterId)) next.delete(broadcasterId);
      else next.add(broadcasterId);
      return next;
    });
  }, []);

  const isFollowing = useCallback((broadcasterId: string) => follows.has(broadcasterId), [follows]);

  const getProgram = useCallback((id: string) => programs.find(p => p.id === id), [programs]);
  const getProgramsByBroadcaster = useCallback((bId: string) => programs.filter(p => p.broadcasterId === bId), [programs]);
  const getFavoritePrograms = useCallback(() => programs.filter(p => favorites.has(p.id)), [programs, favorites]);

  const getFilteredPrograms = useCallback(() => {
    let filtered = programs.filter(p => p.status === "published");
    if (selectedGenre !== "All") filtered = filtered.filter(p => p.genre === selectedGenre);
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      filtered = filtered.filter(p => p.title.toLowerCase().includes(q) || p.broadcaster.toLowerCase().includes(q));
    }
    return filtered;
  }, [programs, selectedGenre, searchQuery]);

  const getBroadcaster = useCallback((id: string) => broadcasters.find(b => b.id === id), [broadcasters]);
  const getFollowedBroadcasters = useCallback(() => broadcasters.filter(b => follows.has(b.id)), [broadcasters, follows]);

  const unreadCount = notifications.filter(n => !n.read).length;
  const markAsRead = useCallback((id: string) => {
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
  }, []);
  const markAllAsRead = useCallback(() => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  }, []);

  const updateProfile = useCallback((updates: Partial<UserProfile>) => {
    setProfile(prev => ({ ...prev, ...updates }));
  }, []);

  const setCurrentProgram = useCallback((id: string) => {
    setCurrentProgramId(id);
    setPlaybackProgress(0);
  }, []);

  const getCurrentProgram = useCallback(() => {
    if (!currentProgramId) return undefined;
    return programs.find(p => p.id === currentProgramId);
  }, [currentProgramId, programs]);

  return (
    <Store.Provider value={{
      favorites, toggleFavorite, isFavorite,
      follows, toggleFollow, isFollowing,
      searchQuery, setSearchQuery, selectedGenre, setSelectedGenre,
      programs, getProgram, getProgramsByBroadcaster, getFavoritePrograms, getFilteredPrograms,
      broadcasters, getBroadcaster, getFollowedBroadcasters,
      notifications, unreadCount, markAsRead, markAllAsRead,
      profile, updateProfile,
      currentProgramId, playbackProgress, setCurrentProgram, setPlaybackProgress, getCurrentProgram,
    }}>
      {children}
    </Store.Provider>
  );
}
