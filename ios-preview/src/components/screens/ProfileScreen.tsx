"use client";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

const menuItems = [
  { icon: "radio", label: "My Shows" },
  { icon: "heart", label: "Favorites" },
  { icon: "users", label: "Following" },
  { icon: "settings", label: "Settings" },
];

export default function ProfileScreen() {
  const { push } = useNavigation();
  const { profile, unreadCount } = useStore();
  const stats = [
    { label: "Shows", value: profile.showCount.toString() },
    { label: "Followers", value: profile.followerCount >= 1000 ? `${(profile.followerCount / 1000).toFixed(1)}K` : profile.followerCount.toString() },
    { label: "Following", value: profile.followingCount.toString() },
    { label: "Favorites", value: profile.favoriteCount.toString() },
  ];
  const menuClickMap: Record<string, () => void> = {
    "My Shows": () => push("broadcast"),
    "Favorites": () => push("favorites"),
    "Following": () => push("followList"),
    "Settings": () => push("settings"),
  };
  return (
    <div className="flex flex-col h-full bg-crate-void">
      <div className="flex items-center justify-between px-4 py-3">
        <div className="w-8" />
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">PROFILE</span>
        <button className="relative w-8 h-8 flex items-center justify-center" onClick={() => push("notifications")}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          {unreadCount > 0 && (
            <span className="absolute -top-0.5 -right-0.5 w-[16px] h-[16px] bg-crate-error rounded-full text-[9px] font-bold text-white flex items-center justify-center">{unreadCount}</span>
          )}
        </button>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Avatar */}
        <div className="flex justify-center mt-4">
          <div className="w-[88px] h-[88px] rounded-full bg-crate-elevated border-2 border-crate-accent/30 flex items-center justify-center">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="1.5"/>
              <circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </div>
        </div>

        <h1 className="text-[22px] font-bold text-center mt-4">{profile.nickname}</h1>
        <p className="text-[15px] text-crate-text-secondary text-center mt-1 px-6">
          {profile.bio}
        </p>
        <button
          className="mx-auto mt-3 px-5 py-1.5 border border-crate-accent rounded-full text-[13px] text-crate-accent block"
          onClick={() => push("profileEdit")}
        >
          Edit Profile
        </button>

        {/* Stats */}
        <div className="grid grid-cols-4 gap-2 mt-6">
          {stats.map((s) => (
            <div key={s.label} className="flex flex-col items-center py-3 bg-crate-surface border border-crate-border rounded-[10px]">
              <span className="text-[17px] font-semibold">{s.value}</span>
              <span className="text-[10px] text-crate-text-muted mt-0.5">{s.label}</span>
            </div>
          ))}
        </div>

        {/* Menu */}
        <div className="mt-6 bg-crate-surface border border-crate-border rounded-[10px] overflow-hidden">
          {menuItems.map((item, i) => (
            <div key={item.label} className={`flex items-center gap-3 px-4 py-3.5 cursor-pointer ${i < menuItems.length - 1 ? 'border-b border-crate-border' : ''}`} onClick={menuClickMap[item.label]}>
              <div className="w-[28px] h-[28px] rounded-[6px] bg-crate-accent/10 flex items-center justify-center">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                  {item.icon === "radio" && <><circle cx="12" cy="12" r="2" stroke="currentColor" strokeWidth="2"/><path d="M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-8.49a6 6 0 0 0 0 8.49" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></>}
                  {item.icon === "heart" && <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" stroke="currentColor" strokeWidth="2"/>}
                  {item.icon === "users" && <><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2"/><circle cx="9" cy="7" r="4" stroke="currentColor" strokeWidth="2"/><path d="M23 21v-2a4 4 0 0 0-3-3.87" stroke="currentColor" strokeWidth="2"/><path d="M16 3.13a4 4 0 0 1 0 7.75" stroke="currentColor" strokeWidth="2"/></>}
                  {item.icon === "settings" && <><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="2"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="currentColor" strokeWidth="2"/></>}
                </svg>
              </div>
              <span className="flex-1 text-[15px]">{item.label}</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
                <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
          ))}
        </div>

        {/* Sign Out */}
        <div className="mt-3 mb-8 bg-crate-surface border border-crate-border rounded-[10px]">
          <div className="flex items-center gap-3 px-4 py-3.5">
            <div className="w-[28px] h-[28px] rounded-[6px] bg-crate-error/10 flex items-center justify-center">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-error">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                <polyline points="16,17 21,12 16,7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                <line x1="21" y1="12" x2="9" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
            <span className="text-[15px] text-crate-error">Sign Out</span>
          </div>
        </div>
      </div>

    </div>
  );
}
