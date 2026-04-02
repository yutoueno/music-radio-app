"use client";
import { useNavigation } from "../AppNavigator";
import { useState } from "react";

export default function ProfileEditScreen() {
  const { pop } = useNavigation();
  const [nickname, setNickname] = useState("DJ Kenta");
  const [bio, setBio] = useState("Lo-fi beats & chill vibes. Broadcasting from Tokyo.");
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => { setSaved(false); pop(); }, 800);
  };

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Nav */}
      <div className="flex items-center justify-between px-4 py-3">
        <button className="text-[15px] text-crate-text-secondary" onClick={() => pop()}>Cancel</button>
        <span className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary">EDIT PROFILE</span>
        <button className={`text-[15px] font-medium transition-colors ${saved ? 'text-crate-success' : 'text-crate-accent'}`} onClick={handleSave}>
          {saved ? "Saved!" : "Save"}
        </button>
      </div>

      <div className="flex-1 overflow-y-auto phone-scroll px-4 pb-20">
        {/* Avatar */}
        <div className="flex justify-center mt-6">
          <div className="relative">
            <div className="w-[100px] h-[100px] rounded-full bg-crate-elevated border-2 border-crate-accent/30 flex items-center justify-center">
              <svg width="36" height="36" viewBox="0 0 24 24" fill="none" className="text-crate-text-tertiary">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="1.5"/>
                <circle cx="12" cy="7" r="4" stroke="currentColor" strokeWidth="1.5"/>
              </svg>
            </div>
            <button className="absolute bottom-0 right-0 w-[32px] h-[32px] rounded-full bg-crate-accent flex items-center justify-center border-2 border-crate-void">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="white">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" stroke="white" strokeWidth="2" fill="none"/>
                <circle cx="12" cy="13" r="4" stroke="white" strokeWidth="2" fill="none"/>
              </svg>
            </button>
          </div>
        </div>

        {/* Form Fields */}
        <div className="mt-8 space-y-5">
          {/* Nickname */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">NICKNAME</label>
            <input
              type="text"
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              className="w-full mt-2 px-4 py-3 bg-crate-surface border border-crate-border rounded-[10px] text-[15px] text-crate-text-primary outline-none focus:border-crate-accent transition-colors"
              placeholder="Your name"
            />
            <p className="text-[11px] text-crate-text-muted mt-1 ml-1">{nickname.length}/30</p>
          </div>

          {/* Bio */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">BIO</label>
            <textarea
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              rows={4}
              className="w-full mt-2 px-4 py-3 bg-crate-surface border border-crate-border rounded-[10px] text-[15px] text-crate-text-primary outline-none focus:border-crate-accent transition-colors resize-none"
              placeholder="Tell listeners about yourself..."
            />
            <p className="text-[11px] text-crate-text-muted mt-1 ml-1">{bio.length}/200</p>
          </div>

          {/* Wallpaper */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">WALLPAPER</label>
            <div className="mt-2 h-[120px] bg-crate-surface border border-dashed border-crate-border rounded-[10px] flex items-center justify-center cursor-pointer hover:border-crate-accent transition-colors">
              <div className="text-center">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-crate-text-muted mx-auto">
                  <rect x="3" y="3" width="18" height="18" rx="2" stroke="currentColor" strokeWidth="2"/>
                  <circle cx="8.5" cy="8.5" r="1.5" fill="currentColor"/>
                  <path d="m21 15-5-5L5 21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
                <p className="text-[12px] text-crate-text-muted mt-2">Tap to upload</p>
              </div>
            </div>
          </div>

          {/* Genre Preferences */}
          <div>
            <label className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-muted ml-1">FAVORITE GENRES</label>
            <div className="flex flex-wrap gap-2 mt-2">
              {["Lo-Fi", "Jazz", "Pop", "Electronic", "Hip-Hop", "R&B", "Ambient", "Classical"].map((g, i) => (
                <button
                  key={g}
                  className={`px-3 py-1.5 rounded-full text-[13px] border transition-colors ${
                    i < 3 ? 'border-crate-accent bg-crate-accent/15 text-crate-accent' : 'border-crate-border text-crate-text-secondary hover:border-crate-accent/50'
                  }`}
                >
                  {g}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
