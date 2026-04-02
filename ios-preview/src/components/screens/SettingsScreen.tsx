"use client";
import { useNavigation } from "../AppNavigator";

interface SettingsItem {
  label: string;
  icon: string;
  action?: string | null;
  toggle?: boolean;
  value?: boolean;
  subtitle?: string;
}

const settingsSections: { title: string; items: SettingsItem[] }[] = [
  {
    title: "ACCOUNT",
    items: [
      { label: "Edit Profile", icon: "user", action: "profileEdit" },
      { label: "Change Password", icon: "lock", action: null },
      { label: "Email Notifications", icon: "mail", toggle: true, value: true },
    ],
  },
  {
    title: "PLAYBACK",
    items: [
      { label: "Auto-play Next", icon: "play", toggle: true, value: true },
      { label: "Cellular Streaming", icon: "signal", toggle: true, value: false },
      { label: "Audio Quality", icon: "sliders", subtitle: "High (256kbps)" },
    ],
  },
  {
    title: "GENERAL",
    items: [
      { label: "Apple Music Connection", icon: "music", subtitle: "Connected" },
      { label: "Push Notifications", icon: "bell", toggle: true, value: true },
      { label: "Contact Us", icon: "message", action: "contact" },
      { label: "Terms of Service", icon: "file" },
      { label: "Privacy Policy", icon: "shield" },
    ],
  },
];

export default function SettingsScreen() {
  const { pop, push } = useNavigation();

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3 relative">
        <button className="w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="absolute left-1/2 -translate-x-1/2 text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">SETTINGS</span>
        <div className="w-8" />
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4 pb-20">
        {settingsSections.map((section) => (
          <div key={section.title} className="mb-6">
            <span className="text-[10px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">
              {section.title}
            </span>
            <div className="mt-2 bg-crate-surface border border-crate-border rounded-[10px] overflow-hidden">
              {section.items.map((item, i) => (
                <div
                  key={item.label}
                  className={`flex items-center gap-3 px-4 py-3.5 ${i < section.items.length - 1 ? 'border-b border-crate-border' : ''} ${item.action ? 'cursor-pointer' : ''}`}
                  onClick={() => item.action && push(item.action as any)}
                >
                  <div className="w-[28px] h-[28px] rounded-[6px] bg-crate-accent/10 flex items-center justify-center shrink-0">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                      {item.icon === "user" && <><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2"/><circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "lock" && <><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" strokeWidth="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "mail" && <><rect x="2" y="4" width="20" height="16" rx="2" stroke="currentColor" strokeWidth="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "play" && <polygon points="6,3 20,12 6,21" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/>}
                      {item.icon === "signal" && <><path d="M2 20h.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><path d="M7 20v-4" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><path d="M12 20v-8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><path d="M17 20V8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></>}
                      {item.icon === "sliders" && <><line x1="4" y1="21" x2="4" y2="14" stroke="currentColor" strokeWidth="2"/><line x1="4" y1="10" x2="4" y2="3" stroke="currentColor" strokeWidth="2"/><line x1="12" y1="21" x2="12" y2="12" stroke="currentColor" strokeWidth="2"/><line x1="12" y1="8" x2="12" y2="3" stroke="currentColor" strokeWidth="2"/><line x1="20" y1="21" x2="20" y2="16" stroke="currentColor" strokeWidth="2"/><line x1="20" y1="12" x2="20" y2="3" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "music" && <><path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/><circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/><circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "bell" && <><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="currentColor" strokeWidth="2"/><path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "message" && <><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "file" && <><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" stroke="currentColor" strokeWidth="2"/><polyline points="14,2 14,8 20,8" stroke="currentColor" strokeWidth="2"/></>}
                      {item.icon === "shield" && <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke="currentColor" strokeWidth="2"/>}
                    </svg>
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-[15px]">{item.label}</span>
                    {item.subtitle && <p className="text-[12px] text-crate-text-muted mt-0.5">{item.subtitle}</p>}
                  </div>
                  {item.toggle !== undefined && (
                    <div className={`w-[44px] h-[26px] rounded-full flex items-center px-[3px] transition-colors ${item.value ? 'bg-crate-accent' : 'bg-crate-border'}`}>
                      <div className={`w-[20px] h-[20px] rounded-full bg-white transition-transform ${item.value ? 'translate-x-[18px]' : 'translate-x-0'}`} />
                    </div>
                  )}
                  {!item.toggle && !item.action && (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
                      <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                  )}
                  {item.action && (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
                      <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                  )}
                </div>
              ))}
            </div>
          </div>
        ))}

        {/* Version */}
        <div className="text-center mt-4 mb-8">
          <p className="text-[12px] font-mono text-crate-text-muted">CRATE v1.0.0</p>
          <p className="text-[11px] text-crate-text-muted mt-1">Made with love in Tokyo</p>
        </div>
      </div>
    </div>
  );
}
