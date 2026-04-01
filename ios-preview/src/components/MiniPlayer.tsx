"use client";
import { useNavigation } from "./AppNavigator";

export default function MiniPlayer() {
  const { showMiniPlayer, push, isPlaying, setIsPlaying } = useNavigation();

  if (!showMiniPlayer) return null;

  return (
    <div className="border-t border-crate-border bg-crate-surface" onClick={() => push("nowPlayingFull")}>
      <div className="h-[2px] bg-crate-border">
        <div className="h-full w-[65%] bg-crate-accent transition-all duration-300" />
      </div>
      <div className="flex items-center gap-3 px-3 py-2">
        <div className="w-[36px] h-[36px] rounded bg-crate-elevated shrink-0 flex items-center justify-center">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
            <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
            <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
          </svg>
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-[13px] font-medium truncate">Late Night Chill Mix</p>
          <p className="text-[11px] text-crate-text-secondary">DJ Kenta</p>
        </div>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-accent shrink-0">
          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" fill="currentColor"/>
        </svg>
        <button
          className="w-[28px] h-[28px] rounded-full bg-crate-accent flex items-center justify-center shrink-0"
          onClick={(e) => { e.stopPropagation(); setIsPlaying(!isPlaying); }}
        >
          {isPlaying ? (
            <svg width="10" height="10" viewBox="0 0 24 24" fill="white">
              <rect x="6" y="4" width="4" height="16" rx="1"/>
              <rect x="14" y="4" width="4" height="16" rx="1"/>
            </svg>
          ) : (
            <svg width="10" height="10" viewBox="0 0 24 24" fill="white">
              <polygon points="6,3 20,12 6,21"/>
            </svg>
          )}
        </button>
      </div>
    </div>
  );
}
