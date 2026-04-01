"use client";
import { useNavigation } from "../AppNavigator";

const waveformBars = [
  14, 8, 18, 12, 6, 16, 10, 20, 7, 15, 11, 19, 5, 13, 17, 9, 20, 6, 14, 11,
  18, 8, 16, 12, 7, 19, 10, 15, 13, 5,
];

export default function AudioUploadScreen() {
  const { pop, push } = useNavigation();
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary cursor-pointer" onClick={() => pop()}>
          <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
          UPLOAD AUDIO
        </span>
        <div className="w-5" />
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Upload Area */}
        <div className="mt-2 flex flex-col items-center justify-center h-[200px] border-2 border-dashed border-crate-accent/40 rounded-[16px] bg-crate-surface/30">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
            <path d="M12 16V4m0 0l-4 4m4-4l4 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M20 16.7V19a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2.3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M8 14a4 4 0 0 1-.87-7.9A5.5 5.5 0 0 1 17.5 8h.5a3 3 0 0 1 2 5.24" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
          <p className="text-[15px] text-crate-text-secondary mt-3">Tap to select audio file</p>
          <p className="text-[12px] text-crate-text-muted mt-1">MP3, WAV, M4A &bull; Max 100MB</p>
        </div>

        {/* Upload Progress */}
        <div className="mt-5 p-4 bg-crate-surface border border-crate-border rounded-[10px]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5 min-w-0">
              <div className="w-[36px] h-[36px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                  <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                  <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2" />
                  <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2" />
                </svg>
              </div>
              <div className="min-w-0">
                <p className="text-[14px] font-medium text-crate-text-primary truncate">recording_2024_ep12.m4a</p>
                <p className="text-[12px] text-crate-text-secondary mt-0.5">42.3 MB</p>
              </div>
            </div>
            <span className="text-[14px] font-mono font-medium text-crate-accent shrink-0 ml-3">68%</span>
          </div>
          <div className="mt-3 w-full h-[6px] bg-crate-border rounded-full overflow-hidden">
            <div className="h-full bg-crate-accent rounded-full" style={{ width: "68%" }} />
          </div>
          <p className="text-[11px] font-mono text-crate-text-muted mt-2">2.1 MB/s &bull; ~15s remaining</p>
        </div>

        {/* File Details */}
        <div className="mt-4 p-4 bg-crate-surface border border-crate-border rounded-[10px]">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">
            FILE DETAILS
          </span>
          <div className="flex items-center gap-6 mt-3">
            <div>
              <p className="text-[11px] text-crate-text-muted">Duration</p>
              <p className="text-[15px] font-mono font-medium text-crate-text-primary mt-0.5">32:15</p>
            </div>
            <div>
              <p className="text-[11px] text-crate-text-muted">Format</p>
              <p className="text-[14px] text-crate-text-primary mt-0.5">M4A / AAC 256kbps</p>
            </div>
          </div>

          {/* Mini Waveform */}
          <div className="mt-4">
            <p className="text-[11px] text-crate-text-muted mb-2">Waveform Preview</p>
            <div className="flex items-end gap-[3px] h-[20px]">
              {waveformBars.map((h, i) => (
                <div
                  key={i}
                  className="w-[4px] rounded-full bg-crate-accent"
                  style={{ height: `${h}px` }}
                />
              ))}
            </div>
          </div>
        </div>

        <div className="h-4" />
      </div>

      {/* Continue Button */}
      <div className="px-4 pb-6 pt-3">
        <button className="w-full py-3.5 bg-crate-accent rounded-[10px] text-[15px] font-semibold text-white" onClick={() => push("programEdit")}>
          Continue
        </button>
      </div>
    </div>
  );
}
