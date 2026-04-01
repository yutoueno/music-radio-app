"use client";
import { useNavigation } from "../AppNavigator";

const stats = [
  { label: "Total Plays", value: "12,847", change: "+23%", changeColor: "text-crate-success" },
  { label: "Followers", value: "1,204", change: "+12%", changeColor: "text-crate-success" },
  { label: "Shows", value: "24", badge: "active" },
  { label: "Avg. Duration", value: "34:15", mono: true },
];

const shows = [
  {
    id: 1,
    title: "Late Night Chill Mix Vol.12",
    status: "Draft",
    statusColor: "bg-crate-text-muted/20 text-crate-text-muted",
    subtitle: "Last edited 2h ago",
  },
  {
    id: 2,
    title: "Morning Jazz Session",
    status: "Published",
    statusColor: "bg-crate-success/15 text-crate-success",
    subtitle: "1,234 plays",
  },
  {
    id: 3,
    title: "Weekend Vibes #8",
    status: "Published",
    statusColor: "bg-crate-success/15 text-crate-success",
    subtitle: "856 plays",
  },
];

export default function BroadcastHubScreen() {
  const { push } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3">
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          BROADCASTING
        </span>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
          <circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="2" />
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="currentColor" strokeWidth="2" />
        </svg>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-[10px]">
          {stats.map((s) => (
            <div
              key={s.label}
              className="p-3 bg-crate-surface border border-crate-border rounded-[10px] cursor-pointer"
              onClick={() => push("analytics")}
            >
              <p className="text-[11px] text-crate-text-muted">{s.label}</p>
              <p className={`text-[20px] font-bold mt-1 ${s.mono ? "font-mono" : ""}`}>
                {s.value}
              </p>
              {s.change && (
                <span className={`text-[11px] font-medium ${s.changeColor}`}>{s.change}</span>
              )}
              {s.badge === "active" && (
                <div className="flex items-center gap-1 mt-0.5">
                  <div className="w-[6px] h-[6px] rounded-full bg-crate-success" />
                  <span className="text-[11px] text-crate-success">active</span>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Create Button */}
        <button className="w-full mt-5 py-3.5 bg-crate-accent rounded-[10px] text-[15px] font-semibold text-white flex items-center justify-center gap-2" onClick={() => push("audioUpload")}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="text-white">
            <path d="M12 5v14m-7-7h14" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
          </svg>
          CREATE NEW SHOW
        </button>

        {/* Your Shows */}
        <div className="mt-6">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            YOUR SHOWS
          </span>
          <div className="flex flex-col gap-[10px] mt-3 pb-4">
            {shows.map((s) => (
              <div
                key={s.id}
                className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] cursor-pointer"
                onClick={() => push("programEdit")}
              >
                {/* Thumbnail */}
                <div className="w-[48px] h-[48px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                    <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                    <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2" />
                    <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2" />
                  </svg>
                </div>
                {/* Info */}
                <div className="flex-1 min-w-0">
                  <p className="text-[14px] font-medium text-crate-text-primary truncate">{s.title}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className={`text-[11px] font-medium px-2 py-0.5 rounded-full ${s.statusColor}`}>
                      {s.status}
                    </span>
                    <span className="text-[11px] text-crate-text-muted">{s.subtitle}</span>
                  </div>
                </div>
                {/* Chevron */}
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
                  <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </div>
            ))}
          </div>
        </div>
      </div>

    </div>
  );
}
