"use client";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

const genres = ["All", "Lo-Fi", "Jazz", "Pop", "Electronic", "Hip-Hop", "R&B"];

export default function SearchScreen() {
  const { push } = useNavigation();
  const { searchQuery, setSearchQuery, selectedGenre, setSelectedGenre, getFilteredPrograms, setCurrentProgram } = useStore();
  const results = getFilteredPrograms();
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
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search shows, creators..."
            className="flex-1 text-[15px] text-crate-text-primary placeholder:text-crate-text-tertiary bg-transparent outline-none"
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery("")} className="text-crate-text-muted">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </button>
          )}
        </div>

        {/* Genres */}
        <div className="flex gap-2 mt-4 overflow-x-auto phone-scroll pb-1">
          {genres.map((g) => (
            <button
              key={g}
              className={`px-3 py-1.5 rounded-full text-[13px] shrink-0 transition-colors ${
                selectedGenre === g ? 'bg-crate-accent text-white' : 'border border-crate-border text-crate-text-secondary'
              }`}
              onClick={() => setSelectedGenre(g)}
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
          <span className="text-[11px] font-mono text-crate-text-muted">{results.length} shows</span>
        </div>

        {/* Results */}
        <div className="flex flex-col gap-[10px] mt-3 pb-20">
          {results.map((p) => (
            <div key={p.id} className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] cursor-pointer" onClick={() => { setCurrentProgram(p.id); push("program"); }}>
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
