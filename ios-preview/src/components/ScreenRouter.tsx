"use client";
import { useNavigation } from "./AppNavigator";
import { useState, useEffect, useRef } from "react";
import TopScreen from "./screens/TopScreen";
import ProgramScreen from "./screens/ProgramScreen";
import SearchScreen from "./screens/SearchScreen";
import ProfileScreen from "./screens/ProfileScreen";
import BroadcasterScreen from "./screens/BroadcasterScreen";
import NowPlayingFullScreen from "./screens/NowPlayingFullScreen";
import BroadcastHubScreen from "./screens/BroadcastHubScreen";
import FavoritesScreen from "./screens/FavoritesScreen";
import FollowListScreen from "./screens/FollowListScreen";
import NotificationsScreen from "./screens/NotificationsScreen";
import AnalyticsScreen from "./screens/AnalyticsScreen";
import AudioUploadScreen from "./screens/AudioUploadScreen";
import ProgramEditScreen from "./screens/ProgramEditScreen";
import TrackTimingScreen from "./screens/TrackTimingScreen";
import SignInScreen from "./screens/SignInScreen";
import SettingsScreen from "./screens/SettingsScreen";
import ProfileEditScreen from "./screens/ProfileEditScreen";
import OnboardingScreen from "./screens/OnboardingScreen";
import AppleMusicSearchScreen from "./screens/AppleMusicSearchScreen";
import ContactScreen from "./screens/ContactScreen";
import SharePreviewScreen from "./screens/SharePreviewScreen";
import TabBar from "./TabBar";
import MiniPlayer from "./MiniPlayer";

const tabScreens = ["home", "search", "broadcast", "profile"];

// Screens that slide up from bottom (modal style)
const modalScreens = ["nowPlayingFull", "settings", "contact"];

function getScreen(id: string) {
  const screenMap: Record<string, React.ReactNode> = {
    home: <TopScreen />,
    search: <SearchScreen />,
    broadcast: <BroadcastHubScreen />,
    profile: <ProfileScreen />,
    program: <ProgramScreen />,
    broadcaster: <BroadcasterScreen />,
    nowPlayingFull: <NowPlayingFullScreen />,
    favorites: <FavoritesScreen />,
    followList: <FollowListScreen />,
    notifications: <NotificationsScreen />,
    analytics: <AnalyticsScreen />,
    audioUpload: <AudioUploadScreen />,
    programEdit: <ProgramEditScreen />,
    trackTiming: <TrackTimingScreen />,
    signIn: <SignInScreen />,
    settings: <SettingsScreen />,
    profileEdit: <ProfileEditScreen />,
    onboarding: <OnboardingScreen />,
    appleMusicSearch: <AppleMusicSearchScreen />,
    contact: <ContactScreen />,
    sharePreview: <SharePreviewScreen />,
  };
  return screenMap[id] || <TopScreen />;
}

export default function ScreenRouter() {
  const { currentScreen, previousScreen, transitionDirection } = useNavigation();
  const [displayScreen, setDisplayScreen] = useState(currentScreen);
  const [animState, setAnimState] = useState<"idle" | "entering">("idle");
  const prevScreenRef = useRef(currentScreen);

  useEffect(() => {
    if (prevScreenRef.current !== currentScreen) {
      setAnimState("entering");
      setDisplayScreen(currentScreen);
      const timer = setTimeout(() => setAnimState("idle"), 300);
      prevScreenRef.current = currentScreen;
      return () => clearTimeout(timer);
    }
  }, [currentScreen]);

  const isTabScreen = tabScreens.includes(currentScreen);
  const isModal = modalScreens.includes(currentScreen);

  let animClass = "";
  if (animState === "entering") {
    if (isModal) {
      animClass = "animate-slide-up";
    } else if (transitionDirection === "push") {
      animClass = "animate-slide-in-right";
    } else if (transitionDirection === "pop") {
      animClass = "animate-slide-in-left";
    } else {
      animClass = "animate-fade-in";
    }
  }

  return (
    <div className="flex flex-col h-full bg-crate-void">
      <div className={`flex-1 overflow-hidden ${animClass}`}>
        {getScreen(displayScreen)}
      </div>
      <MiniPlayer />
      {isTabScreen && <TabBar />}
    </div>
  );
}
