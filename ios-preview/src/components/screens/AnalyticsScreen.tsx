"use client";
import { useNavigation } from "../AppNavigator";

const weekBars = [
  { day: "M", height: 35 },
  { day: "T", height: 55 },
  { day: "W", height: 42 },
  { day: "T", height: 60 },
  { day: "F", height: 48 },
  { day: "S", height: 30 },
  { day: "S", height: 25 },
];

const topShows = [
  { rank: 1, title: "Late Night Chill Mix", plays: "3,421", percent: 80 },
  { rank: 2, title: "Morning Jazz Session", plays: "2,156", percent: 60 },
  { rank: 3, title: "Weekend Vibes", plays: "1,890", percent: 50 },
];

const demographics = [
  { label: "Peak Hour", value: "23:00" },
  { label: "Avg Listen", value: "18:30" },
  { label: "Completion", value: "72%" },
  { label: "New Listeners", value: "340" },
];

export default function AnalyticsScreen() {
  const { pop } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-center px-4 py-3 relative">
        <button className="absolute left-4 w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          ANALYTICS
        </span>
        <div className="absolute right-4">
          <span className="text-[11px] font-mono text-crate-text-secondary bg-crate-elevated border border-crate-border px-2.5 py-1 rounded-full">
            Last 30 days
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4 pt-2">
        {/* Big Stat */}
        <div className="mb-5">
          <p className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-1">
            TOTAL PLAYS
          </p>
          <p className="text-[28px] font-bold text-crate-text-primary leading-tight">12,847</p>
          <p className="text-[13px] text-crate-success mt-0.5">+23% from last month</p>
        </div>

        {/* Mini Bar Chart */}
        <div className="bg-crate-surface border border-crate-border rounded-[10px] p-3 mb-5">
          <div className="flex items-end justify-between gap-2 h-[60px]">
            {weekBars.map((bar, i) => (
              <div key={i} className="flex flex-col items-center gap-1.5 flex-1">
                <div
                  className="w-full rounded-[3px] bg-crate-accent"
                  style={{ height: `${bar.height}px` }}
                />
                <span className="text-[9px] font-mono text-crate-text-muted">{bar.day}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Top Shows */}
        <div className="mb-5">
          <p className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-3">
            TOP SHOWS
          </p>
          <div className="flex flex-col gap-3">
            {topShows.map((show) => (
              <div key={show.rank} className="flex items-center gap-3">
                <span className="text-[14px] font-mono font-bold text-crate-text-muted w-[20px] shrink-0">
                  #{show.rank}
                </span>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-[13px] font-medium text-crate-text-primary truncate">{show.title}</p>
                    <span className="text-[11px] font-mono text-crate-text-secondary shrink-0 ml-2">
                      {show.plays}
                    </span>
                  </div>
                  <div className="h-[4px] bg-crate-border rounded-full">
                    <div
                      className="h-full bg-crate-accent rounded-full"
                      style={{ width: `${show.percent}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Listener Demographics */}
        <div className="pb-6">
          <p className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-3">
            LISTENER DEMOGRAPHICS
          </p>
          <div className="grid grid-cols-2 gap-2">
            {demographics.map((d) => (
              <div
                key={d.label}
                className="bg-crate-surface border border-crate-border rounded-[10px] p-3"
              >
                <p className="text-[11px] text-crate-text-secondary mb-1">{d.label}</p>
                <p className="text-[18px] font-bold font-mono text-crate-text-primary">{d.value}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
