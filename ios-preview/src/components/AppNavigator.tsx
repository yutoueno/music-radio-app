"use client";
import { useState, useCallback, createContext, useContext, ReactNode, useRef } from "react";

export type Screen =
  | "home" | "search" | "broadcast" | "profile"
  | "program" | "broadcaster" | "nowPlayingFull"
  | "favorites" | "followList" | "notifications" | "analytics"
  | "audioUpload" | "programEdit" | "trackTiming"
  | "signIn"
  | "settings" | "profileEdit" | "onboarding" | "appleMusicSearch" | "contact" | "sharePreview";

type Tab = "home" | "search" | "broadcast" | "profile";

interface NavContext {
  currentScreen: Screen;
  previousScreen: Screen | null;
  currentTab: Tab;
  transitionDirection: "push" | "pop" | "tab" | null;
  push: (screen: Screen) => void;
  pop: () => void;
  switchTab: (tab: Tab) => void;
  isPlaying: boolean;
  setIsPlaying: (v: boolean) => void;
  showMiniPlayer: boolean;
  screenStack: Screen[];
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
  const [transitionDirection, setTransitionDirection] = useState<"push" | "pop" | "tab" | null>(null);
  const [previousScreen, setPreviousScreen] = useState<Screen | null>(null);

  const currentScreen = stack[stack.length - 1];

  const push = useCallback((screen: Screen) => {
    setPreviousScreen(stack[stack.length - 1]);
    setTransitionDirection("push");
    setStack(prev => [...prev, screen]);
  }, [stack]);

  const pop = useCallback(() => {
    if (stack.length > 1) {
      setPreviousScreen(stack[stack.length - 1]);
      setTransitionDirection("pop");
      setStack(prev => prev.slice(0, -1));
    }
  }, [stack]);

  const switchTab = useCallback((tab: Tab) => {
    setPreviousScreen(stack[stack.length - 1]);
    setTransitionDirection("tab");
    setCurrentTab(tab);
    const screenMap: Record<Tab, Screen> = {
      home: "home",
      search: "search",
      broadcast: "broadcast",
      profile: "profile",
    };
    setStack([screenMap[tab]]);
  }, [stack]);

  const noMiniPlayerScreens: Screen[] = ["signIn", "nowPlayingFull", "audioUpload", "programEdit", "trackTiming", "onboarding"];
  const showMiniPlayer = isPlaying && !noMiniPlayerScreens.includes(currentScreen);

  return (
    <NavigationContext.Provider value={{
      currentScreen, previousScreen, currentTab, transitionDirection,
      push, pop, switchTab, isPlaying, setIsPlaying, showMiniPlayer,
      screenStack: stack,
    }}>
      {children}
    </NavigationContext.Provider>
  );
}
