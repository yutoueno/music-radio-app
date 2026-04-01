"use client";

const notifications = [
  { id: 1, avatar: "K", color: "#7C83FF", text: "DJ Kenta", action: "published a new show", time: "2h ago", unread: true },
  { id: 2, avatar: "Y", color: "#FF6B8A", text: "Yuki", action: "started following you", time: "5h ago", unread: true },
  { id: 3, avatar: "T", color: "#4DFF88", text: "Taro", action: "published a new show", time: "1d ago", unread: false },
  { id: 4, avatar: "M", color: "#FFB84D", text: "Mika", action: "liked your show", time: "2d ago", unread: false },
  { id: 5, avatar: "R", color: "#83D9FF", text: "Ryo", action: "started following you", time: "3d ago", unread: false },
];

const filters = [
  { label: "All", active: true },
  { label: "New Shows", active: false },
  { label: "Follows", active: false },
];

export default function NotificationsScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-center px-4 py-3">
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          NOTIFICATIONS
        </span>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Filter Pills */}
        <div className="flex gap-2 mb-4">
          {filters.map((f) => (
            <button
              key={f.label}
              className={`px-3 py-1.5 rounded-full text-[12px] font-medium ${
                f.active
                  ? "bg-crate-accent text-white"
                  : "bg-crate-surface border border-crate-border text-crate-text-secondary"
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>

        {/* Notification List */}
        <div className="flex flex-col">
          {notifications.map((n, i) => (
            <div key={n.id}>
              <div
                className={`flex items-start gap-3 py-3 px-2 rounded-lg ${
                  n.unread ? "bg-crate-surface" : "bg-crate-void"
                }`}
              >
                {/* Unread dot */}
                <div className="w-[6px] flex items-center justify-center shrink-0 pt-3.5">
                  {n.unread && (
                    <div className="w-[6px] h-[6px] rounded-full bg-crate-accent" />
                  )}
                </div>
                {/* Avatar */}
                <div
                  className="w-[32px] h-[32px] rounded-full flex items-center justify-center shrink-0 text-[12px] font-bold"
                  style={{ background: `${n.color}25`, color: n.color }}
                >
                  {n.avatar}
                </div>
                {/* Content */}
                <div className="flex-1 min-w-0">
                  <p className="text-[13px] text-crate-text-primary leading-snug">
                    <span className="font-semibold">{n.text}</span>{" "}
                    <span className="text-crate-text-secondary">{n.action}</span>
                  </p>
                </div>
                {/* Timestamp */}
                <span className="text-[11px] font-mono text-crate-text-muted shrink-0 pt-0.5">
                  {n.time}
                </span>
              </div>
              {i < notifications.length - 1 && (
                <div className="h-px bg-crate-border ml-[50px]" />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Tab Bar */}
      <div className="flex items-center justify-around py-2 bg-crate-surface border-t border-crate-border">
        <div className="flex flex-col items-center gap-0.5">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" strokeWidth="2"/>
          </svg>
          <span className="text-[10px] text-crate-text-tertiary">Home</span>
        </div>
        <div className="flex flex-col items-center gap-0.5">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
            <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="2"/>
            <path d="m21 21-4.35-4.35" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          </svg>
          <span className="text-[10px] text-crate-text-tertiary">Search</span>
        </div>
        <div className="flex flex-col items-center gap-0.5 relative">
          <div className="relative">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
            </svg>
            <div className="absolute -top-0.5 -right-0.5 w-[7px] h-[7px] rounded-full bg-crate-accent" />
          </div>
          <span className="text-[10px] text-crate-accent">Notifications</span>
        </div>
        <div className="flex flex-col items-center gap-0.5">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
            <circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="2"/>
          </svg>
          <span className="text-[10px] text-crate-text-tertiary">Profile</span>
        </div>
      </div>
    </div>
  );
}
