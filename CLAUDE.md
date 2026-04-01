# CLAUDE.md — Music Radio App

> このファイルはClaude Codeがプロジェクトのコンテキストを理解し、一貫した開発を行うための指示書です。
> 要件の詳細は `REQUIREMENTS.md` を参照してください。

---

## プロジェクト概要

音楽ラジオ配信プラットフォーム。配信者がラジオ番組を配信し、番組内でApple Music楽曲を同時再生できるiOSアプリ。

**コアバリュー:** アーティストの音楽再生回数を伸ばす。

**最重要技術課題:** iOSアプリ内でAVAudioPlayer（ラジオ音声）とMusicKit ApplicationMusicPlayer（Apple Music楽曲）を同時再生する。

**開発対象:** iOS App (Swift/SwiftUI) + Backend API + Admin Web (Next.js)

---

## 技術スタック

### iOS App

| 項目 | 技術 |
|---|---|
| 言語 | Swift 5.9+ |
| UI | SwiftUI |
| 最小OS | iOS 16.0 |
| オーディオ | AVFoundation (AVAudioPlayer) |
| Apple Music | MusicKit for Swift |
| ネットワーク | URLSession + async/await |
| 画像 | Kingfisher or AsyncImage |
| アーキテクチャ | MVVM + Repository Pattern |
| DI | Swift Package (Environment) |
| テスト | XCTest + XCUITest |

### Backend API

| 項目 | 技術 |
|---|---|
| フレームワーク | FastAPI (Python 3.11+) or Rails 7 |
| DB | PostgreSQL |
| ストレージ | AWS S3 or Supabase Storage |
| 認証 | JWT (Access + Refresh Token) |
| メール | Resend or SendGrid |
| デプロイ | Railway or AWS ECS |

### Admin Web

| 項目 | 技術 |
|---|---|
| フレームワーク | Next.js 14+ (App Router) |
| UI | Tailwind CSS + shadcn/ui |
| 状態管理 | TanStack Query + Zustand |
| デプロイ | Vercel |

---

## ディレクトリ構成

### iOS App

```
MusicRadio/
├── MusicRadio.xcodeproj
├── MusicRadio/
│   ├── App/
│   │   ├── MusicRadioApp.swift          # エントリーポイント
│   │   └── AppDelegate.swift            # MusicKit認可等
│   │
│   ├── Core/
│   │   ├── Audio/
│   │   │   ├── AudioPlayerManager.swift      # AVAudioPlayer管理 ★最重要
│   │   │   ├── MusicKitManager.swift          # MusicKit管理 ★最重要
│   │   │   ├── AudioSessionManager.swift      # AVAudioSession設定
│   │   │   └── DualPlaybackCoordinator.swift  # 同時再生の統合制御 ★最重要
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   ├── Endpoints.swift
│   │   │   └── AuthManager.swift
│   │   ├── Storage/
│   │   │   └── KeychainManager.swift
│   │   └── Extensions/
│   │
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Program.swift
│   │   ├── ProgramTrack.swift
│   │   └── APIResponse.swift
│   │
│   ├── ViewModels/
│   │   ├── TopViewModel.swift
│   │   ├── ProgramViewModel.swift          # 番組再生ロジック ★
│   │   ├── BroadcasterViewModel.swift
│   │   ├── ProfileViewModel.swift
│   │   ├── ProgramEditViewModel.swift
│   │   ├── FavoritesViewModel.swift
│   │   ├── FollowsViewModel.swift
│   │   └── AuthViewModel.swift
│   │
│   ├── Views/
│   │   ├── Top/
│   │   │   ├── TopView.swift
│   │   │   ├── RecommendedSection.swift
│   │   │   └── FavoritesSection.swift
│   │   ├── Program/
│   │   │   ├── ProgramView.swift           # 番組画面 ★コア
│   │   │   ├── WaveformView.swift          # 波形表示
│   │   │   ├── TrackListView.swift         # Apple Music楽曲リスト
│   │   │   ├── TrackRow.swift              # 楽曲カード
│   │   │   └── MiniPlayerView.swift        # ミニプレイヤー ★
│   │   ├── Broadcaster/
│   │   │   ├── BroadcasterView.swift
│   │   │   └── BroadcasterProgramList.swift
│   │   ├── Profile/
│   │   │   ├── ProfileView.swift
│   │   │   └── ProfileEditView.swift
│   │   ├── Broadcasting/
│   │   │   ├── BroadcastingView.swift      # 番組配信入口
│   │   │   ├── AudioUploadView.swift       # 音声アップロード
│   │   │   ├── ProgramEditView.swift       # 番組編集
│   │   │   └── TrackTimingEditor.swift     # 楽曲タイミング設定 ★
│   │   ├── Lists/
│   │   │   ├── FavoriteProgramsView.swift
│   │   │   ├── FollowListView.swift
│   │   │   └── MyProgramsView.swift
│   │   ├── Auth/
│   │   │   ├── SignInView.swift
│   │   │   ├── SignUpView.swift
│   │   │   ├── EmailVerificationView.swift
│   │   │   ├── InitialRegistrationView.swift
│   │   │   └── PasswordResetView.swift
│   │   └── Shared/
│   │       ├── ProgramCard.swift
│   │       ├── BroadcasterCard.swift
│   │       ├── PlayButton.swift
│   │       ├── FavoriteButton.swift
│   │       ├── FollowButton.swift
│   │       └── ShareButton.swift
│   │
│   ├── Repositories/
│   │   ├── ProgramRepository.swift
│   │   ├── UserRepository.swift
│   │   ├── AuthRepository.swift
│   │   └── UploadRepository.swift
│   │
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
│
├── MusicRadioTests/
└── MusicRadioUITests/
```

### Backend API (FastAPI)

```
backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── dependencies.py
│   ├── routers/
│   │   ├── auth.py
│   │   ├── programs.py
│   │   ├── tracks.py
│   │   ├── users.py
│   │   ├── social.py         # favorites, follows
│   │   ├── upload.py
│   │   └── admin.py
│   ├── schemas/
│   ├── services/
│   ├── models/                # SQLAlchemy models
│   └── utils/
│       ├── auth.py
│       ├── apple_music.py    # Apple Music URL → Track ID変換
│       └── storage.py        # S3操作
├── migrations/
├── tests/
├── requirements.txt
└── Dockerfile
```

### Admin Web (Next.js)

```
admin/
├── src/
│   ├── app/
│   │   ├── (auth)/login/
│   │   ├── (main)/
│   │   │   ├── dashboard/
│   │   │   ├── users/
│   │   │   ├── programs/
│   │   │   ├── broadcasters/
│   │   │   ├── inquiries/
│   │   │   └── reports/
│   │   └── layout.tsx
│   ├── components/
│   ├── hooks/
│   ├── lib/
│   └── types/
├── next.config.ts
└── package.json
```

---

## iOS開発規約

### Swift スタイル

```swift
// MVVM: View → ViewModel → Repository → APIClient

// ViewModel: @Observable (iOS 17+) or ObservableObject
@Observable
final class ProgramViewModel {
    private let repository: ProgramRepository
    var program: Program?
    var isPlaying: Bool = false
    
    func loadProgram(id: String) async { ... }
    func togglePlay() { ... }
}

// View: SwiftUI
struct ProgramView: View {
    @State private var viewModel: ProgramViewModel
    var body: some View { ... }
}

// Repository: データ取得の抽象化
protocol ProgramRepositoryProtocol {
    func fetchProgram(id: String) async throws -> Program
    func fetchRecommended() async throws -> [Program]
}
```

### 命名規則

```swift
// 型: PascalCase
struct Program { ... }
class AudioPlayerManager { ... }

// プロパティ・メソッド: camelCase
var isPlaying: Bool
func togglePlay() { ... }

// 定数: camelCase or UPPER_SNAKE_CASE
let maxFileSize = 100 * 1024 * 1024
let API_BASE_URL = "https://api.example.com"
```

### ★ 同時再生の実装パターン（最重要）

```swift
// DualPlaybackCoordinator.swift
// ラジオ音声とApple Music楽曲の同時再生を統合管理

final class DualPlaybackCoordinator: ObservableObject {
    private let audioPlayer = AudioPlayerManager()       // ラジオ音声
    private let musicKit = MusicKitManager()              // Apple Music
    
    @Published var radioState: PlaybackState = .stopped
    @Published var musicState: PlaybackState = .stopped
    @Published var currentTrack: ProgramTrack?
    
    // ラジオ再生開始
    func playRadio(url: URL) async {
        AudioSessionManager.shared.configureForMixing()
        await audioPlayer.play(url: url)
        radioState = .playing
    }
    
    // Apple Music楽曲再生（ラジオと同時）
    func playAppleMusicTrack(_ track: ProgramTrack) async {
        guard let trackId = track.appleMusicTrackId else { return }
        do {
            try await musicKit.play(trackId: trackId)
            currentTrack = track
            musicState = .playing
        } catch MusicKitError.subscriptionRequired {
            // 30秒プレビューにフォールバック
            try await musicKit.playPreview(trackId: trackId)
        }
    }
    
    // 楽曲タイミング監視
    func monitorTrackTimings(tracks: [ProgramTrack]) {
        // audioPlayer の再生位置を監視し、
        // タイミングに合致した楽曲をハイライト
    }
}

// AudioSessionManager.swift
final class AudioSessionManager {
    static let shared = AudioSessionManager()
    
    func configureForMixing() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            options: [.mixWithOthers, .duckOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
```

---

## バックエンド開発規約

### APIレスポンス形式

```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 30,
    "total": 150,
    "has_next": true
  }
}
```

### エラーレスポンス

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "認証が必要です"
  }
}
```

### ページネーション

カーソルベース（推奨）or オフセットベース。一覧APIは全て30件ずつ。

### 音声ファイルアップロード

```
1. クライアント → POST /api/v1/upload/audio → presigned URL取得
2. クライアント → PUT (presigned URL) → S3に直接アップロード
3. クライアント → POST /api/v1/programs → audio_url を保存
```

---

## 開発フェーズ別タスク

### Phase 0: PoC（1-2週間）

```
□ Xcodeプロジェクト作成（SwiftUI, MusicKit entitlement追加）
□ AVAudioPlayer でサンプル音声再生
□ MusicKit ApplicationMusicPlayer でApple Music楽曲再生
□ ★ 両方を同時再生するPoCコード作成
□ ★ .mixWithOthers / .duckOthers の挙動検証
□ ★ バックグラウンド再生の検証
□ ★ サブスク未加入時の30秒プレビュー検証
□ PoC結果レポート作成（GO / NO-GO判断）
```

### Phase 1: 基盤構築（2週間）

```
□ [iOS] SwiftUIプロジェクト構造構築
□ [iOS] APIClient + AuthManager
□ [iOS] KeychainManager（トークン管理）
□ [BE] FastAPIプロジェクト初期化
□ [BE] DB マイグレーション（全テーブル）
□ [BE] 認証API（signup, login, verify, reset）
□ [BE] S3連携（presigned URL生成）
□ [iOS] 認証フロー（サインイン/サインアップ/PW再設定）全8画面
□ CI/CD設定（GitHub Actions + Fastlane）
```

### Phase 2: コア再生機能（3週間）★最重要

```
□ [BE] 番組 CRUD API
□ [BE] 楽曲 CRUD API
□ [BE] Apple Music URL → 楽曲情報取得API
□ [iOS] AudioPlayerManager（ラジオ音声再生）
□ [iOS] MusicKitManager（Apple Music再生）
□ [iOS] ★ DualPlaybackCoordinator（同時再生統合）
□ [iOS] AudioSessionManager（ミキシング設定）
□ [iOS] 番組画面（ProgramView）
□ [iOS] 波形表示（WaveformView）
□ [iOS] 楽曲リスト + Apple Music再生ボタン
□ [iOS] 楽曲タイミング連動（再生位置と楽曲ハイライト）
□ [iOS] ★ ミニプレイヤー（画面遷移中の再生維持）
□ [iOS] バックグラウンド再生対応
□ [iOS] サブスク未加入者の30秒プレビューフォールバック
```

### Phase 3: 配信者機能（2週間）

```
□ [iOS] 音声アップロード（進捗表示付き）
□ [iOS] 番組編集画面（ProgramEditView）
□ [iOS] 楽曲タイミング設定UI（TrackTimingEditor）
□ [iOS] 番組配信入口画面
□ [iOS] 配信中番組一覧
□ [BE] 音声アップロードAPI
□ [BE] 番組配信（公開/停止）API
□ [BE] 再生ログ記録API
```

### Phase 4: ソーシャル機能（2週間）

```
□ [BE] お気に入り API
□ [BE] フォロー API
□ [BE] おすすめ番組API（簡易レコメンド）
□ [BE] プロフィール更新API
□ [iOS] TOP画面
□ [iOS] 配信者画面
□ [iOS] プロフィール画面（編集含む）
□ [iOS] お気に入り一覧
□ [iOS] フォロー一覧
□ [iOS] シェア機能（ShareSheet）
```

### Phase 5: 管理画面（2週間）

```
□ [Admin] Next.jsプロジェクト初期化
□ [Admin] 認証（管理者ログイン）
□ [Admin] ダッシュボード（KPI表示）
□ [Admin] ユーザー管理（一覧、停止、削除）
□ [Admin] 番組管理（一覧、非公開化、削除）
□ [Admin] レポート画面（再生数推移、人気番組）
□ [BE] 管理系API
```

### Phase 6: 品質・リリース（2週間）

```
□ ユニットテスト（DualPlaybackCoordinator、ViewModel層）
□ UIテスト（主要フロー3本）
□ APIテスト（認証、番組CRUD、楽曲連携）
□ パフォーマンス最適化（音声ストリーミング、一覧スクロール）
□ App Store審査用メタデータ準備
□ スクリーンショット・プレビュー動画
□ Apple Music利用に関するApp Store審査対応
□ 本番環境デプロイ
□ App Store提出
```

---

## 注意事項・制約

1. **MusicKit PoCが最優先。** Phase 0でGO/NO-GOを判断。NOの場合は楽曲再生を外部リンク遷移に切り替え
2. **Apple Musicサブスク依存。** サブスク未加入者にも価値を提供するため、30秒プレビュー+Apple Music導線は必須
3. **App Store審査。** MusicKit利用アプリはApple Developer Guidelinesに準拠必須。審査リジェクトリスクあり
4. **音声ファイル。** S3直接アップロード（presigned URL）でバックエンド負荷を回避。ファイルサイズ上限100MB
5. **ライブ配信はMVP外。** ただし `programs.program_type` カラムで将来拡張に備える
6. **30件ずつの無限スクロール。** 全一覧画面で統一。LazyVStack + onAppear でページネーション
7. **バックグラウンド再生。** Info.plist の `UIBackgroundModes` に `audio` を追加必須
8. **波形表示。** サーバー側で音声ファイルから波形データ（JSON）を事前生成するか、クライアント側でリアルタイム描画するか、Phase 2で技術判断
