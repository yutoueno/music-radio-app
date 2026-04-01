"use client";

const tracks = [
  { id: 1, title: "Sunset Drive", artist: "Nujabes", timing: "00:00", active: false },
  { id: 2, title: "Luv(sic) Part 3", artist: "Nujabes ft. Shing02", timing: "04:30", active: true },
  { id: 3, title: "Reflection Eternal", artist: "Nujabes", timing: "09:15", active: false },
  { id: 4, title: "Feather", artist: "Nujabes ft. Cise Starr", timing: "14:00", active: false },
];

export default function ProgramScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
          <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          NOW PLAYING
        </span>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
          <circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>
        </svg>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll">
        {/* Artwork */}
        <div className="flex justify-center px-4 mt-2">
          <div className="w-[200px] h-[200px] rounded-[10px] bg-crate-elevated border border-crate-border flex items-center justify-center">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
              <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
              <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="1.5"/>
              <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </div>
        </div>

        {/* Info */}
        <div className="text-center mt-5 px-4">
          <h1 className="text-[22px] font-bold tracking-[-0.5px]">Late Night Chill Mix</h1>
          <p className="text-[15px] text-crate-text-secondary mt-1">DJ Kenta</p>
          <span className="inline-block text-[11px] text-crate-accent bg-crate-accent/10 px-2 py-0.5 rounded mt-2">
            Lo-Fi
          </span>
        </div>

        {/* Waveform */}
        <div className="px-6 mt-6">
          <div className="flex items-end justify-center gap-[3px] h-[40px]">
            {Array.from({ length: 50 }, (_, i) => {
              const height = Math.random() * 30 + 10;
              const isPlayed = i < 20;
              return (
                <div
                  key={i}
                  className={`w-[2px] rounded-full ${isPlayed ? 'bg-crate-accent' : 'bg-crate-border'}`}
                  style={{ height: `${height}px` }}
                />
              );
            })}
          </div>
          <div className="flex justify-between mt-2">
            <span className="text-[12px] font-mono text-crate-text-muted">12:45</span>
            <span className="text-[12px] font-mono text-crate-text-muted">32:15</span>
          </div>
        </div>

        {/* Controls */}
        <div className="flex items-center justify-center gap-8 mt-5">
          <button className="flex flex-col items-center">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
              <path d="M1 4v6h6M23 20v-6h-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[10px] text-crate-text-muted mt-0.5">15s</span>
          </button>
          <button className="w-[54px] h-[54px] rounded-full bg-crate-accent flex items-center justify-center">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="white">
              <rect x="6" y="4" width="4" height="16" rx="1"/>
              <rect x="14" y="4" width="4" height="16" rx="1"/>
            </svg>
          </button>
          <button className="flex flex-col items-center">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
              <path d="M23 4v6h-6M1 20v-6h6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[10px] text-crate-text-muted mt-0.5">30s</span>
          </button>
        </div>

        {/* Tracks */}
        <div className="px-4 mt-6 pb-20">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            TRACKS IN THIS SHOW
          </span>
          <div className="flex flex-col gap-[10px] mt-3">
            {tracks.map((t) => (
              <div
                key={t.id}
                className={`flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] ${
                  t.active ? 'border-l-[2px] border-l-crate-accent' : ''
                }`}
              >
                <div className="w-[40px] h-[40px] rounded-[6px] bg-crate-elevated flex items-center justify-center shrink-0">
                  {t.active ? (
                    <div className="flex items-end gap-[2px] h-[16px]">
                      <div className="w-[2px] bg-crate-accent rounded-full animate-pulse" style={{ height: '12px' }}/>
                      <div className="w-[2px] bg-crate-accent rounded-full animate-pulse" style={{ height: '8px', animationDelay: '0.2s' }}/>
                      <div className="w-[2px] bg-crate-accent rounded-full animate-pulse" style={{ height: '14px', animationDelay: '0.4s' }}/>
                      <div className="w-[2px] bg-crate-accent rounded-full animate-pulse" style={{ height: '6px', animationDelay: '0.1s' }}/>
                    </div>
                  ) : (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
                      <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2"/>
                      <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                      <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                    </svg>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p className={`text-[14px] font-medium truncate ${t.active ? 'text-crate-accent' : 'text-crate-text-primary'}`}>
                    {t.title}
                  </p>
                  <p className="text-[12px] text-crate-text-secondary mt-0.5">{t.artist}</p>
                </div>
                <span className="text-[11px] font-mono text-crate-text-muted bg-crate-void px-2 py-0.5 rounded shrink-0">
                  {t.timing}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Action bar */}
      <div className="flex items-center justify-around py-3 px-4 border-t border-crate-border bg-crate-surface">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" fill="currentColor"/>
        </svg>
        <button className="px-4 py-1.5 border border-crate-text-tertiary rounded-full text-[13px] text-crate-text-secondary">
          Follow
        </button>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
          <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          <polyline points="16 6 12 2 8 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          <line x1="12" y1="2" x2="12" y2="15" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
    </div>
  );
}
