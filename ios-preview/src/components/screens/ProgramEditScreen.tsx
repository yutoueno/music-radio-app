"use client";
import { useNavigation } from "../AppNavigator";

const genres = [
  { label: "Lo-Fi", active: true },
  { label: "Jazz", active: false },
  { label: "Pop", active: false },
  { label: "Electronic", active: false },
  { label: "Ambient", active: false },
];

const steps = [
  { label: "Audio", completed: true },
  { label: "Details", current: true },
  { label: "Tracks", completed: false },
  { label: "Review", completed: false },
];

export default function ProgramEditScreen() {
  const { pop, push } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <span className="text-[14px] text-crate-text-secondary cursor-pointer" onClick={() => pop()}>Cancel</span>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          NEW SHOW
        </span>
        <span className="text-[12px] font-medium text-white bg-crate-accent px-2.5 py-1 rounded-full">
          2/4
        </span>
      </div>

      {/* Step Progress */}
      <div className="px-6 mt-1 mb-4">
        <div className="flex items-center justify-between relative">
          {/* Connecting line */}
          <div className="absolute top-[5px] left-[5px] right-[5px] h-[2px] bg-crate-border" />
          <div className="absolute top-[5px] left-[5px] h-[2px] bg-crate-accent" style={{ width: "30%" }} />
          {steps.map((step, i) => (
            <div key={i} className="flex flex-col items-center gap-1.5 relative z-10">
              <div
                className={`w-[10px] h-[10px] rounded-full ${
                  step.completed || step.current
                    ? "bg-crate-accent"
                    : "bg-crate-border"
                }`}
              />
              <span
                className={`text-[10px] ${
                  step.current
                    ? "text-crate-accent font-medium"
                    : step.completed
                    ? "text-crate-text-secondary"
                    : "text-crate-text-muted"
                }`}
              >
                {step.label}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          SHOW DETAILS
        </span>

        {/* Thumbnail + Title row */}
        <div className="flex gap-3 mt-3">
          {/* Thumbnail */}
          <div className="w-[80px] h-[80px] rounded-[12px] border-2 border-dashed border-crate-border flex flex-col items-center justify-center shrink-0 bg-crate-surface/30">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted">
              <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              <circle cx="12" cy="13" r="4" stroke="currentColor" strokeWidth="1.5" />
            </svg>
            <span className="text-[10px] text-crate-text-muted mt-1">Add Cover</span>
          </div>

          {/* Title Field */}
          <div className="flex-1">
            <label className="text-[11px] text-crate-text-muted mb-1.5 block">Episode Title</label>
            <div className="w-full px-3 py-2.5 bg-crate-elevated border border-crate-border rounded-[8px]">
              <span className="text-[14px] text-crate-text-primary">Late Night Chill Mix Vol.12</span>
            </div>
          </div>
        </div>

        {/* Description */}
        <div className="mt-4">
          <label className="text-[11px] text-crate-text-muted mb-1.5 block">Description</label>
          <div className="w-full px-3 py-2.5 bg-crate-elevated border border-crate-border rounded-[8px] min-h-[72px]">
            <span className="text-[14px] text-crate-text-primary leading-relaxed">
              Curated lo-fi beats for late night vibes. Featuring new tracks from...
            </span>
          </div>
        </div>

        {/* Genre Selector */}
        <div className="mt-4">
          <label className="text-[11px] text-crate-text-muted mb-2 block">Genre</label>
          <div className="flex flex-wrap gap-2">
            {genres.map((g) => (
              <span
                key={g.label}
                className={`px-3 py-1.5 rounded-full text-[13px] font-medium ${
                  g.active
                    ? "bg-crate-accent text-white"
                    : "bg-crate-surface border border-crate-border text-crate-text-secondary"
                }`}
              >
                {g.label}
              </span>
            ))}
          </div>
        </div>

        {/* Schedule Toggle */}
        <div className="mt-5 flex items-center justify-between p-3 bg-crate-surface border border-crate-border rounded-[10px]">
          <div>
            <p className="text-[14px] text-crate-text-primary">Schedule for later</p>
            <p className="text-[12px] text-crate-text-muted mt-0.5">Set a publish date &amp; time</p>
          </div>
          {/* Toggle - off state */}
          <div className="w-[44px] h-[26px] bg-crate-border rounded-full flex items-center px-[3px]">
            <div className="w-[20px] h-[20px] bg-crate-text-muted rounded-full" />
          </div>
        </div>

        <div className="h-4" />
      </div>

      {/* Next Button */}
      <div className="px-4 pb-6 pt-3">
        <button className="w-full py-3.5 bg-crate-accent rounded-[10px] text-[15px] font-semibold text-white flex items-center justify-center gap-2" onClick={() => push("trackTiming")}>
          Next: Add Tracks
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-white">
            <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
      </div>
    </div>
  );
}
