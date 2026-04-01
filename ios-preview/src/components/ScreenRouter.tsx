"use client";
import { useNavigation } from "./AppNavigator";
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
import TabBar from "./TabBar";
import MiniPlayer from "./MiniPlayer";

const tabScreens = ["home", "search", "broadcast", "profile"];

export default function ScreenRouter() {
  const { currentScreen } = useNavigation();

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
  };

  const isTabScreen = tabScreens.includes(currentScreen);

  return (
    <div className="flex flex-col h-full bg-crate-void">
      <div className="flex-1 overflow-hidden">
        {screenMap[currentScreen] || <TopScreen />}
      </div>
      <MiniPlayer />
      {isTabScreen && <TabBar />}
    </div>
  );
}
