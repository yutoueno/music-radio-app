"use client";
import { useState, useCallback, createContext, useContext, ReactNode } from "react";

type Screen =
  | "home" | "search" | "broadcast" | "profile"  // tab screens
  | "program" | "broadcaster" | "nowPlayingFull"  // push screens
  | "favorites" | "followList" | "notifications" | "analytics"
  | "audioUpload" | "programEdit" | "trackTiming"
  | "signIn";

type Tab = "home" | "search" | "broadcast" | "profile";

interface NavContext {
  currentScreen: Screen;
  currentTab: Tab;
  push: (screen: Screen) => void;
  pop: () => void;
  switchTab: (tab: Tab) => void;
  isPlaying: boolean;
  setIsPlaying: (v: boolean) => void;
  showMiniPlayer: boolean;
}

const NavigationContext = createContext<NavContext | null>(null);

export function useNavigation() {
  const ctx = useContext(NavigationContext);
  if (!ctx) throw new Error("useNavigation must be used within AppNavigator");
  return ctx;
}

export default function AppNavigator({ children }: { children: ReactNode }) {
  const [currentTab, setCurrentTab] = useState<Tab>("home");
  const [stack, setStack] = useState<Screen[]>(["home"]);
  const [isPlaying, setIsPlaying] = useState(true);

  const currentScreen = stack[stack.length - 1];

  const push = useCallback((screen: Screen) => {
    setStack(prev => [...prev, screen]);
  }, []);

  const pop = useCallback(() => {
    setStack(prev => prev.length > 1 ? prev.slice(0, -1) : prev);
  }, []);

  const switchTab = useCallback((tab: Tab) => {
    setCurrentTab(tab);
    const screenMap: Record<Tab, Screen> = {
      home: "home",
      search: "search",
      broadcast: "broadcast",
      profile: "profile",
    };
    setStack([screenMap[tab]]);
  }, []);

  const noMiniPlayerScreens: Screen[] = ["signIn", "nowPlayingFull", "audioUpload", "programEdit", "trackTiming"];
  const showMiniPlayer = isPlaying && !noMiniPlayerScreens.includes(currentScreen);

  return (
    <NavigationContext.Provider value={{ currentScreen, currentTab, push, pop, switchTab, isPlaying, setIsPlaying, showMiniPlayer }}>
      {children}
    </NavigationContext.Provider>
  );
}
