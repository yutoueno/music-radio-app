"use client";
import { useNavigation } from "../AppNavigator";

const programs = [
  { id: 1, title: "Late Night Chill Mix", broadcaster: "DJ Kenta", duration: "32:15", genre: "Lo-Fi" },
  { id: 2, title: "Morning Jazz Radio", broadcaster: "Yuki", duration: "45:00", genre: "Jazz" },
  { id: 3, title: "Tokyo Sunset Beats", broadcaster: "Ryo", duration: "28:30", genre: "Electronic" },
  { id: 4, title: "Deep Focus Session", broadcaster: "Mika", duration: "55:00", genre: "Ambient" },
];

export default function FavoritesScreen() {
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
        <span className="absolute left-1/2 -translate-x-1/2 text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          FAVORITES
        </span>
        <div className="w-8" />
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Count */}
        <div className="flex justify-end mb-3">
          <span className="text-[12px] font-mono text-crate-text-muted">12 shows</span>
        </div>

        {/* Program Cards */}
        <div className="flex flex-col gap-[10px] pb-20">
          {programs.map((p, i) => (
            <div
              key={p.id}
              className="relative flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] overflow-hidden cursor-pointer"
              onClick={() => push("program")}
            >
              {/* Swipe hint on first card */}
              {i === 0 && (
                <div className="absolute right-0 top-0 bottom-0 w-[6px] bg-gradient-to-l from-crate-error/25 to-transparent" />
              )}
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
  );
}
