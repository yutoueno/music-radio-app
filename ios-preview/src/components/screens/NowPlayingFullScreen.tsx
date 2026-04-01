"use client";

// Fixed waveform data for the progress bar (80 bars)
const waveformData = [
  22, 30, 18, 35, 26, 14, 38, 28, 20, 33, 16, 40, 24, 19, 36, 29, 12, 34, 22, 27,
  31, 15, 37, 25, 20, 32, 18, 39, 23, 17, 35, 28, 14, 30, 21, 36, 26, 19, 33, 24,
  38, 16, 29, 34, 22, 27, 13, 40, 31, 18, 35, 23, 20, 37, 26, 15, 32, 28, 21, 36,
  14, 30, 25, 38, 19, 33, 17, 34, 29, 22, 27, 16, 40, 24, 31, 20, 35, 18, 37, 26,
];

const progressPosition = 42; // 42% through

export default function NowPlayingFullScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void relative overflow-hidden">
      {/* Background gradient (simulated artwork color bleed) */}
      <div className="absolute inset-0 bg-gradient-to-b from-crate-accent/15 via-crate-accent/5 to-crate-void pointer-events-none" />
      <div className="absolute inset-0 bg-gradient-to-t from-crate-void via-transparent to-transparent pointer-events-none" />

      {/* Drag Handle + AirPlay */}
      <div className="relative z-10 flex items-center justify-between px-4 pt-3 pb-1">
        <div className="w-8" />
        <div className="w-[36px] h-[5px] bg-crate-text-muted/60 rounded-full" />
        {/* AirPlay icon */}
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
          <path d="M5 17H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-1" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          <polygon points="12 15 17 21 7 21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>

      {/* Content */}
      <div className="relative z-10 flex-1 flex flex-col items-center px-6 pt-6">
        {/* Large Artwork */}
        <div className="w-[300px] h-[300px] rounded-[16px] bg-crate-elevated border border-crate-border/50 flex items-center justify-center relative overflow-hidden shadow-2xl">
          <div className="absolute inset-0 bg-gradient-to-br from-crate-accent/25 via-crate-elevated to-crate-accent/10" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
          <svg width="72" height="72" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary/60 relative z-10">
            <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="1.5"/>
            <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="1.5"/>
          </svg>
        </div>

        {/* Title + Broadcaster */}
        <div className="w-full mt-8 flex items-start justify-between">
          <div className="flex-1 min-w-0">
            <h1 className="text-[20px] font-bold tracking-[-0.3px] text-crate-text-primary truncate">
              Late Night Chill Mix
            </h1>
            <p className="text-[15px] text-crate-text-secondary mt-1">DJ Kenta</p>
          </div>
          {/* Favorite */}
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-crate-accent shrink-0 mt-1">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" fill="currentColor"/>
          </svg>
        </div>

        {/* Waveform Progress Bar */}
        <div className="w-full mt-6">
          <div className="flex items-end justify-center gap-[2px] h-[36px]">
            {waveformData.map((h, i) => {
              const isPlayed = i < (progressPosition / 100) * waveformData.length;
              return (
                <div
                  key={i}
                  className={`w-[2.5px] rounded-full ${isPlayed ? 'bg-crate-accent' : 'bg-crate-text-muted/30'}`}
                  style={{ height: `${h}px` }}
                />
              );
            })}
          </div>
          <div className="flex justify-between mt-2">
            <span className="text-[12px] font-mono text-crate-text-muted">12:45</span>
            <span className="text-[12px] font-mono text-crate-text-muted">32:15</span>
          </div>
        </div>

        {/* Large Playback Controls */}
        <div className="flex items-center justify-center gap-8 mt-6 w-full">
          {/* Shuffle */}
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
            <polyline points="16 3 21 3 21 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="4" y1="20" x2="21" y2="3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <polyline points="21 16 21 21 16 21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="15" y1="15" x2="21" y2="21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="4" y1="4" x2="9" y2="9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>

          {/* Rewind 15s */}
          <button className="flex flex-col items-center">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
              <path d="M1 4v6h6M3.51 15a9 9 0 1 0 2.13-9.36L1 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[9px] font-mono text-crate-text-muted mt-0.5">15</span>
          </button>

          {/* Play/Pause (large) */}
          <button className="w-[64px] h-[64px] rounded-full bg-crate-accent flex items-center justify-center shadow-[0_0_30px_rgba(124,131,255,0.35)]">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="white">
              <rect x="6" y="4" width="4" height="16" rx="1"/>
              <rect x="14" y="4" width="4" height="16" rx="1"/>
            </svg>
          </button>

          {/* Forward 30s */}
          <button className="flex flex-col items-center">
            <svg width="30" height="30" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
              <path d="M23 4v6h-6M20.49 15a9 9 0 1 1-2.13-9.36L23 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[9px] font-mono text-crate-text-muted mt-0.5">30</span>
          </button>

          {/* Repeat */}
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
            <polyline points="17 1 21 5 17 9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M3 11V9a4 4 0 0 1 4-4h14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <polyline points="7 23 3 19 7 15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M21 13v2a4 4 0 0 1-4 4H3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>

        {/* Volume slider */}
        <div className="w-full mt-6 flex items-center gap-3 px-2">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <path d="M11 5L6 9H2v6h4l5 4V5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          <div className="flex-1 h-[3px] bg-crate-border rounded-full relative">
            <div className="h-full w-[68%] bg-crate-text-secondary rounded-full" />
          </div>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <path d="M11 5L6 9H2v6h4l5 4V5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="relative z-10 flex items-center justify-around px-8 py-4 mt-auto">
        {/* Now Playing Track Info */}
        <div className="flex items-center gap-2">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
            <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2"/>
            <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
            <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
          </svg>
          <span className="text-[11px] text-crate-text-secondary">Luv(sic) Part 3</span>
        </div>

        {/* Share */}
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
          <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <polyline points="16 6 12 2 8 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          <line x1="12" y1="2" x2="12" y2="15" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
        </svg>

        {/* Queue */}
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
          <line x1="8" y1="6" x2="21" y2="6" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <line x1="8" y1="12" x2="21" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <line x1="8" y1="18" x2="21" y2="18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <line x1="3" y1="6" x2="3.01" y2="6" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <line x1="3" y1="12" x2="3.01" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <line x1="3" y1="18" x2="3.01" y2="18" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
    </div>
  );
}
