"use client";
import { useNavigation } from "../AppNavigator";

const genres = ["All", "Lo-Fi", "Jazz", "Pop", "Electronic", "Hip-Hop", "R&B"];

const results = [
  { id: 1, title: "Midnight Sessions", broadcaster: "Yuki", duration: "38:20", genre: "Jazz" },
  { id: 2, title: "Tokyo Drift Beats", broadcaster: "Ryo", duration: "42:10", genre: "Electronic" },
  { id: 3, title: "Chill Hop Sunday", broadcaster: "DJ Kenta", duration: "55:00", genre: "Lo-Fi" },
];

export default function SearchScreen() {
  const { push } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      <div className="px-4 pt-3 pb-2">
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">SEARCH</span>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Search bar */}
        <div className="flex items-center gap-2 px-3 py-2.5 bg-crate-elevated border border-crate-border rounded-[10px]">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="2"/>
            <path d="m21 21-4.35-4.35" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          </svg>
          <span className="text-[15px] text-crate-text-tertiary">Search shows, creators...</span>
        </div>

        {/* Genres */}
        <div className="flex gap-2 mt-4 overflow-x-auto phone-scroll pb-1">
          {genres.map((g, i) => (
            <button
              key={g}
              className={`px-3 py-1.5 rounded-full text-[13px] shrink-0 ${
                i === 0 ? 'bg-crate-accent text-white' : 'border border-crate-border text-crate-text-secondary'
              }`}
            >
              {g}
            </button>
          ))}
        </div>

        {/* Sort */}
        <div className="flex items-center justify-between mt-4">
          <div className="flex gap-2">
            {["Recent", "Trending", "Newest"].map((s, i) => (
              <button
                key={s}
                className={`px-3 py-1 rounded text-[12px] ${
                  i === 1 ? 'bg-crate-accent/15 text-crate-accent' : 'text-crate-text-muted'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
          <span className="text-[11px] font-mono text-crate-text-muted">156 shows</span>
        </div>

        {/* Results */}
        <div className="flex flex-col gap-[10px] mt-3 pb-20">
          {results.map((p) => (
            <div key={p.id} className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] cursor-pointer" onClick={() => push("program")}>
              <div className="w-[52px] h-[52px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                  <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                  <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[15px] font-medium truncate">{p.title}</p>
                <p className="text-[13px] text-crate-text-secondary mt-0.5">{p.broadcaster}</p>
                <div className="flex items-center gap-2 mt-1">
                  <span className="text-[11px] font-mono text-crate-text-muted">{p.duration}</span>
                  <span className="text-[11px] text-crate-accent bg-crate-accent/10 px-1.5 py-0.5 rounded">{p.genre}</span>
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
  );
}
