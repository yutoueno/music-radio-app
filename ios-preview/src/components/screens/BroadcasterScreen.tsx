"use client";

const shows = [
  { id: 1, title: "Late Night Chill Mix", duration: "32:15", genre: "Lo-Fi" },
  { id: 2, title: "Sunday Morning Jazz", duration: "45:00", genre: "Jazz" },
  { id: 3, title: "Deep Focus Session", duration: "55:30", genre: "Ambient" },
];

export default function BroadcasterScreen() {
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Hero */}
      <div className="relative h-[200px] bg-crate-elevated overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-crate-accent/15 to-crate-void" />
        <div className="absolute top-3 left-3">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <div className="absolute bottom-4 left-4 flex items-end gap-3">
          <div className="w-[52px] h-[52px] rounded-full bg-crate-surface border-2 border-crate-accent/40 flex items-center justify-center">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="1.5"/>
              <circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </div>
          <div>
            <h2 className="text-[17px] font-semibold">DJ Kenta</h2>
            <p className="text-[13px] text-crate-text-secondary">1.2K followers</p>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Follow */}
        <div className="mt-4">
          <button className="px-6 py-2 bg-crate-accent rounded-full text-[14px] font-medium text-white">
            Follow
          </button>
        </div>

        {/* Bio */}
        <p className="text-[15px] text-crate-text-secondary mt-3 leading-relaxed">
          Lo-fi beats & chill vibes. Broadcasting from Tokyo every weekend. Curating the best tracks to help you relax and focus.
        </p>

        {/* Shows */}
        <div className="mt-6 pb-8">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">SHOWS</span>
          <div className="flex flex-col gap-[10px] mt-3">
            {shows.map((s) => (
              <div key={s.id} className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px]">
                <div className="w-[52px] h-[52px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                    <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[15px] font-medium truncate">{s.title}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px] font-mono text-crate-text-muted">{s.duration}</span>
                    <span className="text-[11px] text-crate-accent bg-crate-accent/10 px-1.5 py-0.5 rounded">{s.genre}</span>
                  </div>
                </div>
                <button className="w-[36px] h-[36px] rounded-full bg-crate-accent flex items-center justify-center shrink-0">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="white"><polygon points="6,3 20,12 6,21"/></svg>
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
