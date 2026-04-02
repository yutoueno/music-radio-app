"use client";
import { useNavigation } from "../AppNavigator";
import { useState } from "react";

const searchResults = [
  { id: "am1", title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", duration: "3:20" },
  { id: "am2", title: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia", duration: "3:23" },
  { id: "am3", title: "Stay", artist: "The Kid LAROI, Justin Bieber", album: "F*CK LOVE 3", duration: "2:21" },
  { id: "am4", title: "Heat Waves", artist: "Glass Animals", album: "Dreamland", duration: "3:59" },
  { id: "am5", title: "Peaches", artist: "Justin Bieber", album: "Justice", duration: "3:18" },
];

const recentSearches = ["Nujabes", "lo-fi hip hop", "Shing02", "jazz piano"];

export default function AppleMusicSearchScreen() {
  const { pop } = useNavigation();
  const [query, setQuery] = useState("");
  const [addedTracks, setAddedTracks] = useState<Set<string>>(new Set());
  const showResults = query.length > 0;

  const toggleAdd = (id: string) => {
    setAddedTracks(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3 relative">
        <button className="w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="absolute left-1/2 -translate-x-1/2 text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">ADD TRACKS</span>
        <button className="text-[13px] text-crate-accent font-medium" onClick={() => pop()}>
          Done ({addedTracks.size})
        </button>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4 pb-20">
        {/* Search bar */}
        <div className="flex items-center gap-2 px-3 py-2.5 bg-crate-elevated border border-crate-border rounded-[10px]">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <circle cx="11" cy="11" r="8" stroke="currentColor" strokeWidth="2"/>
            <path d="m21 21-4.35-4.35" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          </svg>
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="flex-1 bg-transparent text-[15px] text-crate-text-primary outline-none placeholder:text-crate-text-tertiary"
            placeholder="Search Apple Music..."
          />
          {query && (
            <button onClick={() => setQuery("")} className="text-crate-text-muted">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="10" fill="currentColor" opacity="0.3"/>
                <path d="M15 9l-6 6M9 9l6 6" stroke="white" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </button>
          )}
        </div>

        {/* Apple Music badge */}
        <div className="flex items-center gap-2 mt-3 mb-4">
          <div className="w-[20px] h-[20px] rounded-[4px] bg-gradient-to-b from-[#FA233B] to-[#FB5C74] flex items-center justify-center">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="white">
              <path d="M9 18V5l12-2v13"/>
              <circle cx="6" cy="18" r="3" fill="white"/>
              <circle cx="18" cy="16" r="3" fill="white"/>
            </svg>
          </div>
          <span className="text-[12px] text-crate-text-muted">Search powered by Apple Music</span>
        </div>

        {!showResults ? (
          /* Recent Searches */
          <div>
            <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted">RECENT SEARCHES</span>
            <div className="flex flex-wrap gap-2 mt-2">
              {recentSearches.map(s => (
                <button key={s} className="px-3 py-1.5 bg-crate-surface border border-crate-border rounded-full text-[13px] text-crate-text-secondary" onClick={() => setQuery(s)}>
                  {s}
                </button>
              ))}
            </div>
          </div>
        ) : (
          /* Search Results */
          <div>
            <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted">RESULTS</span>
            <div className="flex flex-col gap-[8px] mt-2">
              {searchResults.map(track => {
                const isAdded = addedTracks.has(track.id);
                return (
                  <div key={track.id} className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px]">
                    <div className="w-[44px] h-[44px] rounded-[6px] bg-gradient-to-br from-crate-accent/30 to-crate-elevated flex items-center justify-center shrink-0">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                        <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                        <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                        <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                      </svg>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-[14px] font-medium truncate">{track.title}</p>
                      <p className="text-[12px] text-crate-text-secondary truncate">{track.artist}</p>
                      <p className="text-[11px] text-crate-text-muted">{track.duration}</p>
                    </div>
                    <button
                      className={`w-[32px] h-[32px] rounded-full flex items-center justify-center shrink-0 transition-all ${
                        isAdded ? 'bg-crate-accent' : 'border border-crate-accent text-crate-accent'
                      }`}
                      onClick={() => toggleAdd(track.id)}
                    >
                      {isAdded ? (
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                          <path d="M20 6L9 17l-5-5" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                      ) : (
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                          <path d="M12 5v14M5 12h14" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      )}
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
