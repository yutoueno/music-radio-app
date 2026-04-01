import IPhoneFrame from "@/components/IPhoneFrame";
import TopScreen from "@/components/screens/TopScreen";
import ProgramScreen from "@/components/screens/ProgramScreen";
import SearchScreen from "@/components/screens/SearchScreen";
import ProfileScreen from "@/components/screens/ProfileScreen";
import BroadcasterScreen from "@/components/screens/BroadcasterScreen";
import SignInScreen from "@/components/screens/SignInScreen";
import NowPlayingFullScreen from "@/components/screens/NowPlayingFullScreen";
import TrackTimingScreen from "@/components/screens/TrackTimingScreen";
import AudioUploadScreen from "@/components/screens/AudioUploadScreen";
import ProgramEditScreen from "@/components/screens/ProgramEditScreen";
import BroadcastHubScreen from "@/components/screens/BroadcastHubScreen";
import FavoritesScreen from "@/components/screens/FavoritesScreen";
import FollowListScreen from "@/components/screens/FollowListScreen";
import NotificationsScreen from "@/components/screens/NotificationsScreen";
import AnalyticsScreen from "@/components/screens/AnalyticsScreen";

export default function Home() {
  return (
    <div className="min-h-screen bg-crate-void">
      {/* Header */}
      <header className="border-b border-crate-border bg-crate-surface/50 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-[1800px] mx-auto px-8 py-5 flex items-center justify-between">
          <div>
            <h1 className="text-[28px] font-bold tracking-[4px]">CRATE</h1>
            <p className="text-[13px] text-crate-text-secondary mt-0.5">iOS App Screen Preview</p>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-[11px] font-mono text-crate-text-muted">15 screens</span>
            <div className="w-2 h-2 rounded-full bg-crate-success animate-pulse" />
          </div>
        </div>
      </header>

      {/* Screen Gallery */}
      <main className="max-w-[1800px] mx-auto px-8 py-12">
        {/* Row 1: Main Screens */}
        <section className="mb-16">
          <h2 className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-8">
            Main Screens
          </h2>
          <div className="flex flex-wrap gap-12 justify-center">
            <IPhoneFrame label="Home">
              <TopScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Now Playing">
              <ProgramScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Search">
              <SearchScreen />
            </IPhoneFrame>
          </div>
        </section>

        {/* Row 2: Secondary Screens */}
        <section className="mb-16">
          <h2 className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-8">
            Secondary Screens
          </h2>
          <div className="flex flex-wrap gap-12 justify-center">
            <IPhoneFrame label="Profile">
              <ProfileScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Broadcaster">
              <BroadcasterScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Sign In">
              <SignInScreen />
            </IPhoneFrame>
          </div>
        </section>

        {/* Row 3: Playback Screens */}
        <section className="mb-16">
          <h2 className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-8">
            Playback Screens
          </h2>
          <div className="flex flex-wrap gap-12 justify-center">
            <IPhoneFrame label="Full Screen Player">
              <NowPlayingFullScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Track Timing Editor">
              <TrackTimingScreen />
            </IPhoneFrame>
          </div>
        </section>

        {/* Row 4: Broadcaster Screens */}
        <section className="mb-16">
          <h2 className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-8">
            Broadcaster Screens
          </h2>
          <div className="flex flex-wrap gap-12 justify-center">
            <IPhoneFrame label="Broadcast Hub">
              <BroadcastHubScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Audio Upload">
              <AudioUploadScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Program Edit">
              <ProgramEditScreen />
            </IPhoneFrame>
          </div>
        </section>

        {/* Row 5: Social & Utility Screens */}
        <section>
          <h2 className="text-[11px] font-medium tracking-[2px] uppercase text-crate-text-tertiary mb-8">
            Social & Utility Screens
          </h2>
          <div className="flex flex-wrap gap-12 justify-center">
            <IPhoneFrame label="Favorites">
              <FavoritesScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Following">
              <FollowListScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Notifications">
              <NotificationsScreen />
            </IPhoneFrame>
            <IPhoneFrame label="Analytics">
              <AnalyticsScreen />
            </IPhoneFrame>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-crate-border py-6 text-center">
        <p className="text-[12px] text-crate-text-muted">
          CRATE Music Radio — iOS App Preview
        </p>
      </footer>
    </div>
  );
}
