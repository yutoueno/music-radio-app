"use client";
import { useNavigation } from "../AppNavigator";
import { useState } from "react";

const steps = [
  {
    title: "Discover Shows",
    description: "Find radio shows from creators you love. Curated music, commentary, and vibes.",
    icon: "radio",
    color: "#7C83FF",
  },
  {
    title: "Listen Together",
    description: "Apple Music tracks play in sync with the show. Every listen counts for the artist.",
    icon: "music",
    color: "#FF6B8A",
  },
  {
    title: "Start Broadcasting",
    description: "Create your own shows, upload audio, and share your music taste with the world.",
    icon: "mic",
    color: "#4DFF88",
  },
];

export default function OnboardingScreen() {
  const { switchTab } = useNavigation();
  const [step, setStep] = useState(0);

  const current = steps[step];
  const isLast = step === steps.length - 1;

  return (
    <div className="flex flex-col h-full bg-crate-void">
      {/* Skip */}
      <div className="flex justify-end px-4 py-3">
        <button className="text-[13px] text-crate-text-muted" onClick={() => switchTab("home")}>Skip</button>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center px-8">
        {/* Icon */}
        <div className="w-[120px] h-[120px] rounded-[30px] flex items-center justify-center mb-8" style={{ background: `${current.color}15`, border: `2px solid ${current.color}33` }}>
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" style={{ color: current.color }}>
            {current.icon === "radio" && <><circle cx="12" cy="12" r="2" stroke="currentColor" strokeWidth="2"/><path d="M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-8.49a6 6 0 0 0 0 8.49" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M4.93 4.93a10 10 0 0 0 0 14.14" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></>}
            {current.icon === "music" && <><path d="M9 18V5l12-2v13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/><circle cx="6" cy="18" r="3" stroke="currentColor" strokeWidth="2"/><circle cx="18" cy="16" r="3" stroke="currentColor" strokeWidth="2"/></>}
            {current.icon === "mic" && <><rect x="9" y="1" width="6" height="11" rx="3" stroke="currentColor" strokeWidth="2"/><path d="M19 10v1a7 7 0 0 1-14 0v-1" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/><line x1="12" y1="19" x2="12" y2="23" stroke="currentColor" strokeWidth="2"/><line x1="8" y1="23" x2="16" y2="23" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></>}
          </svg>
        </div>

        {/* Text */}
        <h2 className="text-[26px] font-bold text-center">{current.title}</h2>
        <p className="text-[15px] text-crate-text-secondary text-center mt-3 leading-relaxed">{current.description}</p>

        {/* Dots */}
        <div className="flex gap-2 mt-8">
          {steps.map((_, i) => (
            <div key={i} className={`h-[6px] rounded-full transition-all duration-300 ${i === step ? 'w-[24px] bg-crate-accent' : 'w-[6px] bg-crate-border'}`} />
          ))}
        </div>
      </div>

      {/* Button */}
      <div className="px-6 pb-8">
        <button
          className="w-full py-3.5 bg-crate-accent rounded-[12px] text-[16px] font-semibold text-white"
          onClick={() => isLast ? switchTab("home") : setStep(s => s + 1)}
        >
          {isLast ? "Get Started" : "Continue"}
        </button>
      </div>
    </div>
  );
}
