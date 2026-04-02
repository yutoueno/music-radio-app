"use client";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

export default function NotificationsScreen() {
  const { push, pop } = useNavigation();
  const { notifications, markAsRead, markAllAsRead, unreadCount } = useStore();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <button className="w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          NOTIFICATIONS
        </span>
        {unreadCount > 0 ? (
          <button className="text-[11px] text-crate-accent font-medium" onClick={() => markAllAsRead()}>
            Read all
          </button>
        ) : (
          <div className="w-8" />
        )}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Notification List */}
        <div className="flex flex-col">
          {notifications.map((n, i) => {
            const typeColorMap: Record<string, string> = {
              new_show: "#7C83FF",
              follow: "#FF6B8A",
              like: "#4DFF88",
              system: "#FFB84D",
            };
            const color = typeColorMap[n.type] || "#83D9FF";
            const initial = n.title.charAt(0);
            return (
              <div key={n.id}>
                <div
                  className={`flex items-start gap-3 py-3 px-2 rounded-lg cursor-pointer transition-colors ${
                    !n.read ? "bg-crate-surface" : "bg-crate-void"
                  }`}
                  onClick={() => {
                    markAsRead(n.id);
                    if (n.type === "new_show" || n.type === "like") push("program");
                    else if (n.type === "follow") push("broadcaster");
                  }}
                >
                  {/* Unread dot */}
                  <div className="w-[6px] flex items-center justify-center shrink-0 pt-3.5">
                    {!n.read && (
                      <div className="w-[6px] h-[6px] rounded-full bg-crate-accent" />
                    )}
                  </div>
                  {/* Avatar */}
                  <div
                    className="w-[32px] h-[32px] rounded-full flex items-center justify-center shrink-0 text-[12px] font-bold"
                    style={{ background: `${color}25`, color }}
                  >
                    {initial}
                  </div>
                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[13px] text-crate-text-primary leading-snug">
                      <span className="font-semibold">{n.title}</span>{" "}
                      <span className="text-crate-text-secondary">{n.body}</span>
                    </p>
                  </div>
                  {/* Timestamp */}
                  <span className="text-[11px] font-mono text-crate-text-muted shrink-0 pt-0.5">
                    {n.createdAt}
                  </span>
                </div>
                {i < notifications.length - 1 && (
                  <div className="h-px bg-crate-border ml-[50px]" />
                )}
              </div>
            );
          })}
        </div>
      </div>

    </div>
  );
}
