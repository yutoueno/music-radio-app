"use client";
import { useNavigation } from "../AppNavigator";

export default function SharePreviewScreen() {
  const { pop } = useNavigation();

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3 relative">
        <button className="w-8 h-8 flex items-center justify-center" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span className="absolute left-1/2 -translate-x-1/2 text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">SHARE</span>
        <div className="w-8" />
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4 pb-20">
        <h2 className="text-[18px] font-bold mt-2">Share this show</h2>
        <p className="text-[13px] text-crate-text-secondary mt-1">Choose how to share</p>

        {/* OGP Preview Card */}
        <div className="mt-6 bg-crate-surface border border-crate-border rounded-[14px] overflow-hidden">
          {/* Preview Image */}
          <div className="h-[180px] bg-gradient-to-br from-crate-accent/30 via-crate-elevated to-crate-surface flex items-center justify-center">
            <div className="text-center">
              <div className="w-[80px] h-[80px] rounded-[16px] bg-crate-elevated mx-auto flex items-center justify-center border border-crate-border">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" className="text-crate-accent">
                  <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                  <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                </svg>
              </div>
              <p className="text-[13px] font-bold mt-3">Late Night Chill Mix</p>
              <p className="text-[11px] text-crate-text-secondary mt-0.5">by DJ Kenta</p>
            </div>
          </div>
          {/* OGP Meta */}
          <div className="p-4">
            <p className="text-[11px] font-mono text-crate-text-muted">crate.fm</p>
            <p className="text-[15px] font-medium mt-1">Late Night Chill Mix - CRATE</p>
            <p className="text-[13px] text-crate-text-secondary mt-1">A curated selection of lo-fi beats perfect for late night coding sessions. Listen on CRATE.</p>
          </div>
        </div>

        {/* Share Options */}
        <div className="mt-6">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted">SHARE VIA</span>
          <div className="grid grid-cols-4 gap-3 mt-3">
            {[
              { label: "Copy Link", icon: "link", color: "#7C83FF" },
              { label: "Twitter", icon: "twitter", color: "#1DA1F2" },
              { label: "LINE", icon: "line", color: "#06C755" },
              { label: "More", icon: "more", color: "#888888" },
            ].map(opt => (
              <button key={opt.label} className="flex flex-col items-center gap-2 py-3 bg-crate-surface border border-crate-border rounded-[10px]">
                <div className="w-[40px] h-[40px] rounded-full flex items-center justify-center" style={{ background: `${opt.color}22` }}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" style={{ color: opt.color }}>
                    {opt.icon === "link" && <><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></>}
                    {opt.icon === "twitter" && <path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z" stroke="currentColor" strokeWidth="2"/>}
                    {opt.icon === "line" && <><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" stroke="currentColor" strokeWidth="2"/></>}
                    {opt.icon === "more" && <><circle cx="12" cy="12" r="1" fill="currentColor"/><circle cx="19" cy="12" r="1" fill="currentColor"/><circle cx="5" cy="12" r="1" fill="currentColor"/></>}
                  </svg>
                </div>
                <span className="text-[10px] text-crate-text-secondary">{opt.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* URL Bar */}
        <div className="mt-6 flex items-center gap-2 px-3 py-2.5 bg-crate-surface border border-crate-border rounded-[10px]">
          <span className="text-[13px] text-crate-text-muted flex-1 truncate font-mono">https://crate.fm/shows/late-night-chill-mix</span>
          <button className="px-3 py-1 bg-crate-accent/15 text-crate-accent text-[12px] rounded-[6px] font-medium shrink-0">Copy</button>
        </div>
      </div>
    </div>
  );
}
