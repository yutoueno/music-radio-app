"use client";
import { useNavigation } from "../AppNavigator";

const creators = [
  { id: 1, name: "DJ Kenta", followers: "1.2K", color: "#7C83FF", initial: "K" },
  { id: 2, name: "Yuki", followers: "890", color: "#FF6B8A", initial: "Y" },
  { id: 3, name: "Taro", followers: "2.1K", color: "#4DFF88", initial: "T" },
  { id: 4, name: "Mika", followers: "654", color: "#FFB84D", initial: "M" },
  { id: 5, name: "Ryo", followers: "1.5K", color: "#83D9FF", initial: "R" },
];

export default function FollowListScreen() {
  const { pop, push } = useNavigation();
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
          FOLLOWING
        </span>
        <div className="w-8" />
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Count */}
        <div className="flex justify-end mb-3">
          <span className="text-[12px] font-mono text-crate-text-muted">48 creators</span>
        </div>

        {/* Creator Rows */}
        <div className="flex flex-col">
          {creators.map((c, i) => (
            <div key={c.id}>
              <div className="flex items-center gap-3 py-3 cursor-pointer" onClick={() => push("broadcaster")}>
                <div
                  className="w-[44px] h-[44px] rounded-full flex items-center justify-center shrink-0 text-[16px] font-bold"
                  style={{ background: `${c.color}25`, color: c.color }}
                >
                  {c.initial}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[15px] font-medium text-crate-text-primary">{c.name}</p>
                  <p className="text-[13px] text-crate-text-secondary">{c.followers} followers</p>
                </div>
                <button className="px-4 py-1.5 rounded-full border border-crate-text-tertiary shrink-0">
                  <span className="text-[12px] text-crate-text-tertiary">Following</span>
                </button>
              </div>
              {i < creators.length - 1 && (
                <div className="h-px bg-crate-border ml-[56px]" />
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
