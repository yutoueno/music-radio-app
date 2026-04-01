"use client";

const broadcasters = [
  { id: 1, name: "DJ Kenta", color: "#7C83FF" },
  { id: 2, name: "Yuki", color: "#FF6B8A" },
  { id: 3, name: "Taro", color: "#4DFF88" },
  { id: 4, name: "Mika", color: "#FFB84D" },
  { id: 5, name: "Ryo", color: "#83D9FF" },
];

const programs = [
  { id: 1, title: "Late Night Chill Mix", broadcaster: "DJ Kenta", duration: "32:15", genre: "Lo-Fi" },
  { id: 2, title: "Morning Jazz Radio", broadcaster: "Yuki", duration: "45:00", genre: "Jazz" },
  { id: 3, title: "Weekend Vibes", broadcaster: "Taro", duration: "28:30", genre: "Pop" },
  { id: 4, title: "Deep Focus Beats", broadcaster: "Mika", duration: "55:00", genre: "Electronic" },
];

export default function TopScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3">
        <span className="text-[22px] font-bold tracking-[4px] uppercase">CRATE</span>
        <div className="w-8 h-8 rounded-full bg-crate-elevated border border-crate-border" />
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Following */}
        <div className="mb-6">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            FOLLOWING
          </span>
          <div className="flex gap-4 mt-3 overflow-x-auto phone-scroll pb-2">
            {broadcasters.map((b) => (
              <div key={b.id} className="flex flex-col items-center gap-1.5 shrink-0">
                <div
                  className="w-[44px] h-[44px] rounded-full border-2 border-crate-accent/30"
                  style={{ background: `${b.color}33` }}
                />
                <span className="text-[11px] text-crate-text-secondary">{b.name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Recommended */}
        <div>
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            RECOMMENDED
          </span>
          <div className="flex flex-col gap-[10px] mt-3 pb-20">
            {programs.map((p) => (
              <div
                key={p.id}
                className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px]"
              >
                <div className="w-[52px] h-[52px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                    <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[15px] font-medium text-crate-text-primary truncate">{p.title}</p>
                  <p className="text-[13px] text-crate-text-secondary mt-0.5">{p.broadcaster}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px] font-mono text-crate-text-muted">{p.duration}</span>
                    <span className="text-[11px] text-crate-accent bg-crate-accent/10 px-1.5 py-0.5 rounded">{p.genre}</span>
                  </div>
                </div>
                <button className="w-[36px] h-[36px] rounded-full bg-crate-accent flex items-center justify-center shrink-0">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                    <polygon points="6,3 20,12 6,21" />
                  </svg>
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Mini Player */}
      <div className="border-t border-crate-border bg-crate-surface">
        <div className="h-[2px] bg-crate-border">
          <div className="h-full w-[65%] bg-crate-accent" />
        </div>
        <div className="flex items-center gap-3 px-3 py-2">
          <div className="w-[36px] h-[36px] rounded bg-crate-elevated shrink-0" />
          <div className="flex-1 min-w-0">
            <p className="text-[13px] font-medium truncate">Late Night Chill Mix</p>
            <p className="text-[11px] text-crate-text-secondary">DJ Kenta</p>
          </div>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary shrink-0">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" stroke="currentColor" strokeWidth="2"/>
          </svg>
          <button className="w-[28px] h-[28px] rounded-full bg-crate-accent flex items-center justify-center shrink-0">
            <svg width="10" height="10" viewBox="0 0 24 24" fill="white">
              <rect x="6" y="4" width="4" height="16" rx="1"/>
              <rect x="14" y="4" width="4" height="16" rx="1"/>
            </svg>
          </button>
        </div>
      </div>

      {/* Tab Bar */}
      <div className="flex items-center justify-around py-2 bg-crate-surface border-t border-crate-border">
        <div className="flex flex-col items-center gap-0.5">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" strokeWidth="2" fill="currentColor" fillOpacity="0.15"/>
          </svg>
          <span className="text-[10px] text-crate-accent">Home</span>
        </div>
        <div className="flex flex-col items-center gap-0.5">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
            <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="2"/>
            <path d="m21 21-4.35-4.35" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          </svg>
          <span className="text-[10px] text-crate-text-tertiary">Search</span>
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
