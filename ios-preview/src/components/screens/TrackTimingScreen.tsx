"use client";
import { useNavigation } from "../AppNavigator";

const totalDurationSec = 1935; // 32:15 in seconds

const tracks = [
  { id: 1, title: "Sunset Drive", artist: "Nujabes", startTime: "00:00", startSec: 0, duration: "4:30", durationSec: 270, color: "#7C83FF" },
  { id: 2, title: "Luv(sic) Part 3", artist: "Nujabes ft. Shing02", startTime: "04:30", startSec: 270, duration: "5:45", durationSec: 345, color: "#FF6B8A" },
  { id: 3, title: "Reflection Eternal", artist: "Nujabes", startTime: "09:15", startSec: 555, duration: "4:45", durationSec: 285, color: "#4DFF88" },
  { id: 4, title: "Feather", artist: "Nujabes ft. Cise Starr", startTime: "14:00", startSec: 840, duration: "6:12", durationSec: 372, color: "#FFB84D" },
  { id: 5, title: "Aruarian Dance", artist: "Nujabes", startTime: "20:12", startSec: 1212, duration: "5:03", durationSec: 303, color: "#83D9FF" },
];

// Time markers for the timeline
const timeMarkers = ["0:00", "5:00", "10:00", "15:00", "20:00", "25:00", "30:00"];

export default function TrackTimingScreen() {
  const { pop } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary cursor-pointer" onClick={() => pop()}>
          <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          TRACK TIMING
        </span>
        <button className="text-[14px] font-medium text-crate-accent" onClick={() => { pop(); pop(); pop(); }}>Save</button>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll">
        {/* Program Info Bar */}
        <div className="mx-4 p-3 bg-crate-surface border border-crate-border rounded-[10px] flex items-center gap-3">
          <div className="w-[44px] h-[44px] rounded-[8px] bg-crate-elevated border border-crate-border/50 flex items-center justify-center shrink-0 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-crate-accent/15 to-transparent" />
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary relative z-10">
              <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
              <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="1.5"/>
              <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-[14px] font-medium text-crate-text-primary truncate">Late Night Chill Mix</p>
            <p className="text-[12px] text-crate-text-secondary">DJ Kenta</p>
          </div>
          <div className="shrink-0 text-right">
            <span className="text-[12px] font-mono text-crate-text-muted">32:15</span>
            <p className="text-[10px] text-crate-text-tertiary">total</p>
          </div>
        </div>

        {/* Timeline Visualization */}
        <div className="mx-4 mt-5">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            TIMELINE
          </span>
          <div className="mt-3 relative">
            {/* Timeline bar background */}
            <div className="w-full h-[8px] bg-crate-border rounded-full relative overflow-hidden">
              {/* Track segments */}
              {tracks.map((t) => {
                const leftPct = (t.startSec / totalDurationSec) * 100;
                const widthPct = (t.durationSec / totalDurationSec) * 100;
                return (
                  <div
                    key={t.id}
                    className="absolute top-0 h-full rounded-full"
                    style={{
                      left: `${leftPct}%`,
                      width: `${widthPct}%`,
                      backgroundColor: `${t.color}88`,
                    }}
                  />
                );
              })}
            </div>
            {/* Time markers */}
            <div className="flex justify-between mt-1.5 px-0.5">
              {timeMarkers.map((m, i) => (
                <span key={i} className="text-[10px] font-mono text-crate-text-muted">{m}</span>
              ))}
            </div>
          </div>
        </div>

        {/* Track Cards with Timing */}
        <div className="px-4 mt-5 pb-4">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            TRACKS
          </span>
          <div className="flex flex-col gap-[10px] mt-3">
            {tracks.map((t) => (
              <div
                key={t.id}
                className="flex items-center gap-2.5 p-3 bg-crate-surface border border-crate-border rounded-[10px]"
              >
                {/* Drag Handle */}
                <div className="flex flex-col gap-[3px] shrink-0 cursor-grab">
                  <div className="flex gap-[3px]">
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                  </div>
                  <div className="flex gap-[3px]">
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                  </div>
                  <div className="flex gap-[3px]">
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                    <div className="w-[3px] h-[3px] rounded-full bg-crate-text-muted" />
                  </div>
                </div>

                {/* Artwork */}
                <div className="w-[38px] h-[38px] rounded-[6px] bg-crate-elevated flex items-center justify-center shrink-0 relative overflow-hidden">
                  <div className="absolute inset-0" style={{ backgroundColor: `${t.color}15` }} />
                  <div className="absolute bottom-0 left-0 w-full h-[3px] rounded-b-[6px]" style={{ backgroundColor: t.color }} />
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted relative z-10">
                    <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <p className="text-[13px] font-medium text-crate-text-primary truncate">{t.title}</p>
                  <p className="text-[11px] text-crate-text-secondary mt-0.5 truncate">{t.artist}</p>
                </div>

                {/* Start Time Input */}
                <div className="shrink-0 flex flex-col items-end gap-0.5">
                  <div className="bg-crate-void border border-crate-border rounded px-2 py-1">
                    <span className="text-[12px] font-mono text-crate-text-primary">{t.startTime}</span>
                  </div>
                  <span className="text-[9px] font-mono text-crate-text-muted">{t.duration}</span>
                </div>
              </div>
            ))}
          </div>

          {/* Add Track Button */}
          <button className="w-full mt-3 py-3 border-2 border-dashed border-crate-border rounded-[10px] flex items-center justify-center gap-2 hover:border-crate-accent/50 transition-colors">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
              <line x1="12" y1="5" x2="12" y2="19" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              <line x1="5" y1="12" x2="19" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
            </svg>
            <span className="text-[13px] font-medium text-crate-accent">Add Track</span>
          </button>

          {/* Help Text */}
          <p className="text-[11px] text-crate-text-muted text-center mt-4 px-4 leading-relaxed pb-16">
            Drag tracks or edit start times to set when Apple Music tracks play during your show
          </p>
        </div>
      </div>
    </div>
  );
}
