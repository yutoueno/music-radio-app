"use client";
import { useNavigation } from "../AppNavigator";
import { useStore } from "../../lib/store";

export default function BroadcasterScreen() {
  const { pop, push } = useNavigation();
  const { getBroadcaster, getProgramsByBroadcaster, isFollowing, toggleFollow, setCurrentProgram } = useStore();
  const broadcaster = getBroadcaster("5") || { id: "5", name: "Ryo", color: "#83D9FF", bio: "Hip-hop heads unite. Daily beats and bars.", followerCount: 3400, followingCount: 85, showCount: 22, isFollowing: false };
  const shows = getProgramsByBroadcaster(broadcaster.id);
  const following = isFollowing(broadcaster.id);
  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Hero */}
      <div className="relative h-[200px] bg-crate-elevated overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b to-crate-void" style={{ backgroundImage: `linear-gradient(to bottom, ${broadcaster.color}25, var(--crate-void, #0a0a0f))` }} />
        <div className="absolute top-3 left-3 cursor-pointer" onClick={() => pop()}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-primary">
            <path d="M15 18l-6-6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <div className="absolute bottom-4 left-4 flex items-end gap-3">
          <div
            className="w-[52px] h-[52px] rounded-full border-2 flex items-center justify-center text-[20px] font-bold"
            style={{ background: `${broadcaster.color}25`, color: broadcaster.color, borderColor: `${broadcaster.color}60` }}
          >
            {broadcaster.name.charAt(0)}
          </div>
          <div>
            <h2 className="text-[17px] font-semibold">{broadcaster.name}</h2>
            <p className="text-[13px] text-crate-text-secondary">{broadcaster.followerCount >= 1000 ? `${(broadcaster.followerCount / 1000).toFixed(1)}K` : broadcaster.followerCount} followers</p>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4">
        {/* Follow */}
        <div className="mt-4">
          <button
            className={`px-6 py-2 rounded-full text-[14px] font-medium transition-colors ${
              following
                ? 'bg-crate-accent text-white'
                : 'border border-crate-text-tertiary text-crate-text-secondary'
            }`}
            onClick={() => toggleFollow(broadcaster.id)}
          >
            {following ? "Following" : "Follow"}
          </button>
        </div>

        {/* Bio */}
        <p className="text-[15px] text-crate-text-secondary mt-3 leading-relaxed">
          {broadcaster.bio}
        </p>

        {/* Shows */}
        <div className="mt-6 pb-8">
          <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">SHOWS</span>
          <div className="flex flex-col gap-[10px] mt-3">
            {shows.map((s) => (
              <div key={s.id} className="flex items-center gap-3 p-3 bg-crate-surface border border-crate-border rounded-[10px] cursor-pointer" onClick={() => { setCurrentProgram(s.id); push("program"); }}>
                <div className="w-[52px] h-[52px] rounded-[8px] bg-crate-elevated flex items-center justify-center shrink-0">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                    <path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    <circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/>
                    <circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[15px] font-medium truncate">{s.title}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[11px] font-mono text-crate-text-muted">{s.duration}</span>
                    <span className="text-[11px] text-crate-accent bg-crate-accent/10 px-1.5 py-0.5 rounded">{s.genre}</span>
                  </div>
                </div>
                <button className="w-[36px] h-[36px] rounded-full bg-crate-accent flex items-center justify-center shrink-0" onClick={(e) => { e.stopPropagation(); setCurrentProgram(s.id); push("program"); }}>
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="white"><polygon points="6,3 20,12 6,21"/></svg>
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
