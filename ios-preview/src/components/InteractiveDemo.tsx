"use client";
import IPhoneFrame from "./IPhoneFrame";
import AppNavigator, { useNavigation } from "./AppNavigator";
import { StoreProvider } from "../lib/store";
import ScreenRouter from "./ScreenRouter";

function ScreenMap() {
  const { currentScreen, push, switchTab } = useNavigation();

  const sections = [
    { title: "TABS", items: [
      { id: "home", label: "Home", action: () => switchTab("home") },
      { id: "search", label: "Search", action: () => switchTab("search") },
      { id: "broadcast", label: "Broadcast Hub", action: () => switchTab("broadcast") },
      { id: "profile", label: "Profile", action: () => switchTab("profile") },
    ]},
    { title: "PLAYBACK", items: [
      { id: "program", label: "Now Playing", action: () => push("program") },
      { id: "nowPlayingFull", label: "Full Screen Player", action: () => push("nowPlayingFull") },
      { id: "trackTiming", label: "Track Timing", action: () => push("trackTiming") },
    ]},
    { title: "BROADCASTER", items: [
      { id: "audioUpload", label: "Audio Upload", action: () => push("audioUpload") },
      { id: "programEdit", label: "Program Edit", action: () => push("programEdit") },
      { id: "appleMusicSearch", label: "Apple Music Search", action: () => push("appleMusicSearch") },
      { id: "analytics", label: "Analytics", action: () => push("analytics") },
    ]},
    { title: "SOCIAL", items: [
      { id: "broadcaster", label: "Broadcaster", action: () => push("broadcaster") },
      { id: "favorites", label: "Favorites", action: () => push("favorites") },
      { id: "followList", label: "Following", action: () => push("followList") },
      { id: "notifications", label: "Notifications", action: () => push("notifications") },
      { id: "sharePreview", label: "Share Preview", action: () => push("sharePreview") },
    ]},
    { title: "SETTINGS", items: [
      { id: "settings", label: "Settings", action: () => push("settings") },
      { id: "profileEdit", label: "Edit Profile", action: () => push("profileEdit") },
      { id: "contact", label: "Contact", action: () => push("contact") },
    ]},
    { title: "AUTH", items: [
      { id: "signIn", label: "Sign In", action: () => push("signIn") },
      { id: "onboarding", label: "Onboarding", action: () => push("onboarding") },
    ]},
  ];

  return (
    <div className="flex flex-col gap-6">
      {sections.map(section => (
        <div key={section.title}>
          <span className="text-[10px] font-medium tracking-[2px] uppercase text-crate-text-muted">
            {section.title}
          </span>
          <div className="flex flex-col gap-1 mt-2">
            {section.items.map(item => (
              <button
                key={item.id}
                onClick={item.action}
                className={`text-left px-3 py-2 rounded-[8px] text-[13px] transition-colors ${
                  currentScreen === item.id
                    ? 'bg-crate-accent/15 text-crate-accent font-medium'
                    : 'text-crate-text-secondary hover:bg-crate-surface hover:text-crate-text-primary'
                }`}
              >
                {item.label}
              </button>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

export default function InteractiveDemo() {
  return (
    <StoreProvider>
    <AppNavigator>
      <div className="min-h-screen bg-crate-void flex">
        {/* Sidebar */}
        <aside className="w-[240px] border-r border-crate-border bg-crate-surface/30 p-6 flex flex-col shrink-0 h-screen sticky top-0 overflow-y-auto phone-scroll">
          <div className="mb-8">
            <h1 className="text-[22px] font-bold tracking-[4px]">CRATE</h1>
            <p className="text-[11px] text-crate-text-tertiary mt-1">Interactive Prototype</p>
            <div className="flex items-center gap-2 mt-2">
              <div className="w-1.5 h-1.5 rounded-full bg-crate-success animate-pulse" />
              <span className="text-[10px] font-mono text-crate-text-muted">21 screens</span>
            </div>
          </div>
          <ScreenMap />
          <div className="mt-auto pt-6 border-t border-crate-border">
            <p className="text-[10px] text-crate-text-muted leading-relaxed">
              Tap screens in the iPhone or use the sidebar to navigate. Mini player appears when music is playing.
            </p>
          </div>
        </aside>

        {/* Main: iPhone Frame */}
        <main className="flex-1 flex items-center justify-center p-8">
          <IPhoneFrame label="">
            <ScreenRouter />
          </IPhoneFrame>
        </main>
      </div>
    </AppNavigator>
    </StoreProvider>
  );
}
