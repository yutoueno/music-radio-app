"use client";
import { useState } from "react";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

export default function FavoritesScreen() {
  const { pop, push } = useNavigation();
  const { getFavoritePrograms, toggleFavorite, isFavorite, setCurrentProgram } = useStore();
  const programs = getFavoritePrograms();
  const [animatingId, setAnimatingId] = useState<string | null>(null);
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
          <span className="text-[12px] font-mono text-crate-text-muted">{programs.length} shows</span>
        </div>

        {/* Program Cards */}
        <div className="flex flex-col gap-[10px] pb-20">
          {programs.map((p, i) => (
            <div
              key={p.id}
              className="relative flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] overflow-hidden cursor-pointer"
              onClick={() => { setCurrentProgram(p.id); push("program"); }}
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
              <button
                className={`w-[36px] h-[36px] rounded-full flex items-center justify-center shrink-0 transition-transform ${animatingId === p.id ? 'animate-heart-beat' : ''}`}
                onClick={(e) => {
                  e.stopPropagation();
                  setAnimatingId(p.id);
                  toggleFavorite(p.id);
                  setTimeout(() => setAnimatingId(null), 300);
                }}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                  <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" fill="currentColor"/>
                </svg>
              </button>
            </div>
          ))}
        </div>
      </div>

    </div>
  );
}
