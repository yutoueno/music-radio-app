"use client";
import { useNavigation } from "./AppNavigator";

export default function TabBar() {
  const { currentTab, switchTab } = useNavigation();

  const tabs = [
    { id: "home" as const, label: "Home", icon: (active: boolean) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className={active ? "text-crate-accent" : "text-crate-text-tertiary"}>
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" strokeWidth="2" fill={active ? "currentColor" : "none"} fillOpacity={active ? 0.15 : 0}/>
      </svg>
    )},
    { id: "search" as const, label: "Search", icon: (active: boolean) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className={active ? "text-crate-accent" : "text-crate-text-tertiary"}>
        <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="2"/>
        <path d="m21 21-4.35-4.35" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      </svg>
    )},
    { id: "broadcast" as const, label: "Broadcast", icon: (active: boolean) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className={active ? "text-crate-accent" : "text-crate-text-tertiary"}>
        <path d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4z" stroke="currentColor" strokeWidth="2"/>
        <path d="M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-8.49a6 6 0 0 0 0 8.49" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
        <path d="M19.07 4.93a10 10 0 0 1 0 14.14m-14.14 0a10 10 0 0 1 0-14.14" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      </svg>
    )},
    { id: "profile" as const, label: "Profile", icon: (active: boolean) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className={active ? "text-crate-accent" : "text-crate-text-tertiary"}>
        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill={active ? "currentColor" : "none"} fillOpacity={active ? 0.15 : 0}/>
        <circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="2"/>
      </svg>
    )},
  ];

  return (
    <div className="flex items-center justify-around py-2 bg-crate-surface border-t border-crate-border">
      {tabs.map(tab => (
        <button key={tab.id} onClick={() => switchTab(tab.id)} className="flex flex-col items-center gap-0.5">
          {tab.icon(currentTab === tab.id)}
          <span className={`text-[10px] ${currentTab === tab.id ? 'text-crate-accent' : 'text-crate-text-tertiary'}`}>
            {tab.label}
          </span>
        </button>
      ))}
    </div>
  );
}
