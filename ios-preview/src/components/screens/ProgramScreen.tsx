"use client";
import { useState } from "react";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

// Fixed waveform data (100 bars) - seeded, not random
const waveformHeights = [
  18, 25, 32, 28, 15, 22, 38, 35, 20, 12, 30, 36, 24, 19, 33, 27, 14, 40, 31, 22,
  16, 29, 35, 21, 26, 37, 18, 33, 28, 15, 23, 39, 30, 17, 34, 25, 20, 36, 14, 28,
  32, 19, 38, 24, 16, 31, 27, 35, 21, 13, 29, 37, 23, 18, 34, 26, 40, 15, 30, 22,
  17, 33, 28, 36, 20, 25, 14, 38, 31, 19, 27, 35, 23, 16, 32, 29, 37, 21, 26, 18,
  34, 12, 30, 24, 39, 17, 28, 33, 15, 22, 36, 20, 31, 25, 14, 38, 27, 19, 35, 23,
];

// playheadPosition now comes from store

const tracks = [
  { id: 1, title: "Sunset Drive", artist: "Nujabes", timing: "00:00", duration: "4:30", active: false, appleMusicId: "1234" },
  { id: 2, title: "Luv(sic) Part 3", artist: "Nujabes ft. Shing02", timing: "04:30", duration: "5:45", active: true, appleMusicId: "2345" },
  { id: 3, title: "Reflection Eternal", artist: "Nujabes", timing: "09:15", duration: "4:45", active: false, appleMusicId: "3456" },
  { id: 4, title: "Feather", artist: "Nujabes ft. Cise Starr", timing: "14:00", duration: "6:12", active: false, appleMusicId: "4567" },
  { id: 5, title: "Aruarian Dance", artist: "Nujabes", timing: "20:12", duration: "5:03", active: false, appleMusicId: "5678" },
];

// Equalizer bar heights for active track (fixed)
const eqBars = [12, 8, 14, 6, 10];

export default function ProgramScreen() {
  const { push, pop, isPlaying } = useNavigation();
  const { getCurrentProgram, getProgram, toggleFavorite, isFavorite, playbackProgress } = useStore();
  const program = getCurrentProgram() || getProgram("1");
  const [heartAnimating, setHeartAnimating] = useState(false);
  const fav = program ? isFavorite(program.id) : false;
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary cursor-pointer" onClick={() => pop()}>
          <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          NOW PLAYING
        </span>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
          <circle cx="12" cy="12" r="1" fill="currentColor"/><circle cx="19" cy="12" r="1" fill="currentColor"/><circle cx="5" cy="12" r="1" fill="currentColor"/>
        </svg>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll">
        {/* Artwork */}
        <div className="flex justify-center px-4 mt-2">
          <div className="w-[200px] h-[200px] rounded-[10px] bg-crate-elevated border border-crate-border flex items-center justify-center relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-crate-accent/20 to-transparent" />
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary relative z-10">
              <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
              <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="1.5"/>
              <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </div>
        </div>

        {/* Info */}
        <div className="text-center mt-5 px-4">
          <h1 className="text-[22px] font-bold tracking-[-0.5px]">{program?.title || "Late Night Chill Mix"}</h1>
          <p className="text-[15px] text-crate-text-secondary mt-1 cursor-pointer" onClick={() => push("broadcaster")}>{program?.broadcaster || "DJ Kenta"}</p>
          <span className="inline-block text-[11px] text-crate-accent bg-crate-accent/10 px-2 py-0.5 rounded mt-2">
            {program?.genre || "Lo-Fi"}
          </span>
          <div className="flex items-center justify-center gap-4 mt-2">
            <span className="text-[11px] text-crate-text-muted">{program?.playCount?.toLocaleString() || "0"} plays</span>
            <span className="text-[11px] text-crate-text-muted">{program?.favoriteCount || "0"} favorites</span>
          </div>
        </div>

        {/* Waveform */}
        <div className="px-5 mt-6">
          <div className="relative flex items-end justify-center gap-[1.5px] h-[44px]">
            {waveformHeights.map((h, i) => {
              const playheadPos = Math.floor((playbackProgress / 100) * waveformHeights.length);
              const isPlayed = i < playheadPos;
              const isPlayhead = i === playheadPos;
              return (
                <div key={i} className="relative flex items-end" style={{ height: '44px' }}>
                  <div
                    className={`w-[2px] rounded-full transition-colors ${
                      isPlayed ? 'bg-crate-accent' : 'bg-crate-border'
                    } ${isPlayhead ? 'bg-crate-accent' : ''} ${isPlayed && isPlaying ? 'waveform-bar-animated' : ''}`}
                    style={{ height: `${h}px` }}
                  />
                  {isPlayhead && (
                    <div className="absolute bottom-0 left-0 w-[2px] bg-crate-accent rounded-full shadow-[0_0_6px_rgba(124,131,255,0.6)]" style={{ height: '44px' }} />
                  )}
                </div>
              );
            })}
          </div>
          <div className="flex justify-between mt-2">
            <span className="text-[12px] font-mono text-crate-text-muted">12:45</span>
            <span className="text-[12px] font-mono text-crate-text-muted">32:15</span>
          </div>
        </div>

        {/* Volume */}
        <div className="px-8 mt-3 flex items-center gap-3">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <path d="M11 5L6 9H2v6h4l5 4V5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          <div className="flex-1 h-[3px] bg-crate-border rounded-full relative">
            <div className="h-full w-[72%] bg-crate-accent rounded-full" />
            <div className="absolute top-1/2 -translate-y-1/2 w-[10px] h-[10px] bg-crate-accent rounded-full" style={{ left: '72%', marginLeft: '-5px' }} />
          </div>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted shrink-0">
            <path d="M11 5L6 9H2v6h4l5 4V5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>

        {/* Playback Controls */}
        <div className="flex items-center justify-center gap-6 mt-5">
          {/* Shuffle */}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
            <polyline points="16 3 21 3 21 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="4" y1="20" x2="21" y2="3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <polyline points="21 16 21 21 16 21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="15" y1="15" x2="21" y2="21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <line x1="4" y1="4" x2="9" y2="9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>

          {/* Rewind 15s */}
          <button className="flex flex-col items-center">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
              <path d="M1 4v6h6M3.51 15a9 9 0 1 0 2.13-9.36L1 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[9px] font-mono text-crate-text-muted mt-0.5">15</span>
          </button>

          {/* Play/Pause */}
          <button className="w-[54px] h-[54px] rounded-full bg-crate-accent flex items-center justify-center shadow-[0_0_20px_rgba(124,131,255,0.3)]">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="white">
              <rect x="6" y="4" width="4" height="16" rx="1"/>
              <rect x="14" y="4" width="4" height="16" rx="1"/>
            </svg>
          </button>

          {/* Forward 30s */}
          <button className="flex flex-col items-center">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" className="text-crate-text-secondary">
              <path d="M23 4v6h-6M20.49 15a9 9 0 1 1-2.13-9.36L23 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="text-[9px] font-mono text-crate-text-muted mt-0.5">30</span>
          </button>

          {/* Repeat */}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
            <polyline points="17 1 21 5 17 9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M3 11V9a4 4 0 0 1 4-4h14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <polyline points="7 23 3 19 7 15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M21 13v2a4 4 0 0 1-4 4H3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>

        {/* Tracks */}
        <div className="px-4 mt-6 pb-20">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            TRACKS IN THIS SHOW
          </span>
          <div className="relative flex flex-col gap-[10px] mt-3">
            {/* Timeline vertical line */}
            <div className="absolute left-[19px] top-[10px] bottom-[10px] w-[2px] bg-crate-accent/20 rounded-full" />

            {tracks.map((t, idx) => (
              <div key={t.id} className="flex items-start gap-3 relative">
                {/* Timeline dot */}
                <div className="relative z-10 mt-4 shrink-0">
                  <div className={`w-[8px] h-[8px] rounded-full border-2 ${
                    t.active
                      ? 'bg-crate-accent border-crate-accent shadow-[0_0_8px_rgba(124,131,255,0.5)]'
                      : idx < 1 ? 'bg-crate-accent/50 border-crate-accent/50' : 'bg-crate-border border-crate-border'
                  }`} />
                </div>

                {/* Track Card */}
                <div
                  className={`flex-1 flex items-center gap-3 p-3 bg-crate-surface border rounded-[10px] ${
                    t.active
                      ? 'border-crate-accent/40 border-l-[3px] border-l-crate-accent'
                      : 'border-crate-border'
                  }`}
                >
                  <div className="w-[40px] h-[40px] rounded-[6px] bg-crate-elevated flex items-center justify-center shrink-0 relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-crate-accent/10 to-transparent" />
                    {t.active ? (
                      <div className="flex items-end gap-[2px] h-[16px]">
                        {eqBars.map((barH, bi) => (
                          <div
                            key={bi}
                            className="w-[2px] bg-crate-accent rounded-full animate-pulse"
                            style={{ height: `${barH}px`, animationDelay: `${bi * 0.15}s` }}
                          />
                        ))}
                      </div>
                    ) : (
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted relative z-10">
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
                    {/* Apple Music Badge */}
                    <div className="flex items-center gap-1.5 mt-1">
                      <div className="flex items-center gap-1 bg-crate-void/80 px-1.5 py-[1px] rounded">
                        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" className="text-[#FC3C44]">
                          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 14.19c-.18.28-.5.37-.78.19-2.15-1.31-4.85-1.61-8.04-.88-.31.07-.61-.12-.68-.43-.07-.31.12-.61.43-.68 3.49-.8 6.49-.45 8.88 1.02.28.18.37.5.19.78zm1.24-2.68c-.22.36-.69.47-1.05.25-2.46-1.51-6.2-1.95-9.1-1.07-.39.12-.8-.1-.92-.49-.12-.39.1-.8.49-.92 3.31-1.01 7.42-.52 10.22 1.22.36.22.47.69.36 1.01zm.11-2.79C14.56 8.89 8.77 8.69 5.47 9.63c-.46.14-.96-.13-1.1-.59-.13-.46.13-.95.59-1.1 3.79-1.08 10.08-.87 14.06 1.34.42.25.56.79.31 1.21-.25.42-.79.56-1.21.31h-.03z" fill="currentColor"/>
                        </svg>
                        <span className="text-[9px] font-medium text-crate-text-muted uppercase tracking-wider">Apple Music</span>
                      </div>
                      <span className="text-[10px] font-mono text-crate-text-muted">{t.duration}</span>
                    </div>
                  </div>
                  <span className="text-[11px] font-mono text-crate-text-muted bg-crate-void px-2 py-0.5 rounded shrink-0">
                    {t.timing}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Action bar */}
      <div className="flex items-center justify-around py-3 px-4 border-t border-crate-border bg-crate-surface">
        <button
          className={`transition-transform ${heartAnimating ? 'animate-heart-beat' : ''}`}
          onClick={() => {
            if (program) {
              setHeartAnimating(true);
              toggleFavorite(program.id);
              setTimeout(() => setHeartAnimating(false), 300);
            }
          }}
        >
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className={fav ? "text-crate-accent" : "text-crate-text-secondary"}>
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" fill={fav ? "currentColor" : "none"} stroke={fav ? "none" : "currentColor"} strokeWidth="2"/>
          </svg>
        </button>
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
