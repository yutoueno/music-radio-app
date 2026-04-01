"use client";
import { useNavigation } from "../AppNavigator";

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
  const { push } = useNavigation();
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
                className={`flex items-start gap-3 py-3 px-2 rounded-lg cursor-pointer ${
                  n.unread ? "bg-crate-surface" : "bg-crate-void"
                }`}
                onClick={() => n.action.includes("show") || n.action.includes("liked") ? push("program") : push("broadcaster")}
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

    </div>
  );
}
