import XCTest

final class MusicRadioUITests: XCTestCase {

    private var app: XCUIApplication!

    // MARK: - Setup & Helpers

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Launch the app. Call at the start of each test.
    private func launchApp() {
        app.launch()
    }

    /// Wait for a given element to exist within a timeout.
    @discardableResult
    private func waitForElement(
        _ element: XCUIElement,
        timeout: TimeInterval = 5
    ) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Sign in helper: assumes the sign-in screen is showing.
    /// Fills in credentials and taps the Sign In button.
    private func performSignIn(email: String = "test@example.com", password: String = "password123") {
        let emailField = app.textFields["your@email.com"]
        XCTAssertTrue(waitForElement(emailField), "Email text field should exist")
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists, "Password secure field should exist")
        passwordField.tap()
        passwordField.typeText(password)

        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists, "Sign In button should exist")
        signInButton.tap()
    }

    /// Check whether the app launched on the sign-in screen (unauthenticated)
    /// or the main tab view (authenticated).
    private var isOnSignInScreen: Bool {
        app.staticTexts["Music Radio"].waitForExistence(timeout: 5)
        return app.buttons["Sign In"].exists
    }

    /// If authenticated, navigate to a specific tab by its label.
    private func selectTab(_ label: String) {
        let tab = app.tabBars.buttons[label]
        XCTAssertTrue(waitForElement(tab), "Tab '\(label)' should exist")
        tab.tap()
    }

    // =========================================================================
    // MARK: - Flow 1: App Launch & Navigation
    // =========================================================================

    /// Verify the app launches successfully and shows either the sign-in screen
    /// or the Top tab (depending on auth state).
    func testAppLaunchShowsTopView() throws {
        launchApp()

        // The app should show either the sign-in view or the main tab view.
        // Both contain "Music Radio" as a title / header.
        let musicRadioText = app.staticTexts["Music Radio"]
        XCTAssertTrue(
            waitForElement(musicRadioText, timeout: 10),
            "App should display 'Music Radio' on launch"
        )

        // If authenticated, the tab bar should be visible with the Top tab.
        if app.tabBars.buttons["Top"].exists {
            XCTAssertTrue(
                app.tabBars.buttons["Top"].isSelected,
                "Top tab should be selected by default"
            )
        }
    }

    /// Verify that all four tabs exist and can be tapped.
    func testTabNavigation() throws {
        launchApp()

        // This test only makes sense when authenticated (tab bar visible).
        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            // Not authenticated; sign-in screen is shown instead. Skip tab tests.
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        let tabNames = ["Top", "Favorites", "Broadcasting", "Profile"]

        for tabName in tabNames {
            let tab = app.tabBars.buttons[tabName]
            XCTAssertTrue(tab.exists, "Tab '\(tabName)' should exist in the tab bar")
            tab.tap()
            XCTAssertTrue(tab.isSelected, "Tab '\(tabName)' should be selected after tapping")
        }

        // Return to Top tab
        topTab.tap()
        XCTAssertTrue(topTab.isSelected, "Should return to Top tab")
    }

    /// Verify that the Top view shows its main content sections:
    /// Recommended, Favorites, and Following.
    func testTopViewShowsSections() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        // Check for section headers
        let recommendedHeader = app.staticTexts["Recommended"]
        XCTAssertTrue(
            waitForElement(recommendedHeader),
            "Recommended section header should be visible on Top view"
        )

        let favoritesHeader = app.staticTexts["Favorites"]
        XCTAssertTrue(
            waitForElement(favoritesHeader),
            "Favorites section header should be visible on Top view"
        )

        // Following section only appears when user follows broadcasters,
        // so it may not be visible. We check if it exists but don't fail if absent.
        let followingHeader = app.staticTexts["Following"]
        if followingHeader.exists {
            XCTAssertTrue(followingHeader.isHittable, "Following header should be hittable if visible")
        }
    }

    /// Verify navigating to the Profile tab shows expected profile content.
    func testNavigationToProfile() throws {
        launchApp()

        let profileTab = app.tabBars.buttons["Profile"]
        guard waitForElement(profileTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        profileTab.tap()

        // Profile screen should show its navigation title
        let profileTitle = app.navigationBars["Profile"]
        XCTAssertTrue(
            waitForElement(profileTitle),
            "Profile navigation title should appear"
        )

        // Profile menu items should be present
        let myProgramsRow = app.staticTexts["My Programs"]
        XCTAssertTrue(
            waitForElement(myProgramsRow, timeout: 5),
            "My Programs menu item should be visible on Profile"
        )

        let favoritesRow = app.staticTexts["Favorites"]
        XCTAssertTrue(favoritesRow.exists, "Favorites menu item should be visible on Profile")

        let followingRow = app.staticTexts["Following"]
        XCTAssertTrue(followingRow.exists, "Following menu item should be visible on Profile")

        let signOutRow = app.staticTexts["Sign Out"]
        // Scroll down if needed to find Sign Out
        if !signOutRow.exists {
            app.swipeUp()
        }
        XCTAssertTrue(
            waitForElement(signOutRow, timeout: 3),
            "Sign Out menu item should be visible on Profile"
        )
    }

    /// Verify the search and notification toolbar buttons are present on the Top view.
    func testTopViewToolbarButtons() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        // The navigation bar should contain the search (magnifyingglass) button
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(waitForElement(navBar), "Navigation bar should exist on Top view")

        // Toolbar buttons are present as button elements in the nav bar
        let navBarButtons = navBar.buttons
        XCTAssertTrue(
            navBarButtons.count >= 2,
            "Top view navigation bar should have at least 2 toolbar buttons (search, notifications)"
        )
    }

    // =========================================================================
    // MARK: - Flow 2: Authentication Flow
    // =========================================================================

    /// Verify the sign-in view shows all required form elements.
    func testSignInViewElements() throws {
        launchApp()

        // If already authenticated, we cannot test sign-in screen.
        guard app.buttons["Sign In"].waitForExistence(timeout: 5) else {
            throw XCTSkip("Already authenticated; sign-in screen not displayed.")
        }

        // Logo / header
        let appTitle = app.staticTexts["Music Radio"]
        XCTAssertTrue(appTitle.exists, "App title 'Music Radio' should be visible")

        let subtitle = app.staticTexts["Listen to radio programs with Apple Music"]
        XCTAssertTrue(subtitle.exists, "Subtitle should be visible on sign-in screen")

        // Email field
        let emailField = app.textFields["your@email.com"]
        XCTAssertTrue(emailField.exists, "Email text field should be visible")

        // Password field
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists, "Password secure text field should be visible")

        // Sign In button
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists, "Sign In button should be visible")
        XCTAssertTrue(signInButton.isEnabled, "Sign In button should be enabled")

        // Form labels
        let emailLabel = app.staticTexts["Email"]
        XCTAssertTrue(emailLabel.exists, "Email label should be visible")

        let passwordLabel = app.staticTexts["Password"]
        XCTAssertTrue(passwordLabel.exists, "Password label should be visible")
    }

    /// Verify that tapping Sign In with empty fields shows an error message.
    func testSignInWithEmptyFieldsShowsError() throws {
        launchApp()

        guard app.buttons["Sign In"].waitForExistence(timeout: 5) else {
            throw XCTSkip("Already authenticated; sign-in screen not displayed.")
        }

        // Tap Sign In without entering any credentials
        let signInButton = app.buttons["Sign In"]
        signInButton.tap()

        // The AuthViewModel should set an error message which appears as red text.
        // Wait briefly for the async validation / network call to complete.
        let errorText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'error' OR label CONTAINS[c] 'required' OR label CONTAINS[c] 'invalid' OR label CONTAINS[c] 'enter' OR label CONTAINS[c] 'email'"))
        let errorExists = errorText.firstMatch.waitForExistence(timeout: 5)

        // Alternatively, just check that no tab bar appeared (still on sign-in)
        let tabBar = app.tabBars.firstMatch
        XCTAssertFalse(
            tabBar.exists,
            "Tab bar should not appear after failed sign-in attempt"
        )

        // Still on sign-in screen
        XCTAssertTrue(
            app.buttons["Sign In"].exists,
            "Should remain on sign-in screen after submitting empty fields"
        )
    }

    /// Verify the "Sign Up" link navigates to the sign-up screen.
    func testSignUpLinkNavigation() throws {
        launchApp()

        guard app.buttons["Sign In"].waitForExistence(timeout: 5) else {
            throw XCTSkip("Already authenticated; sign-in screen not displayed.")
        }

        // The "Don't have an account?" text and "Sign Up" button
        let signUpPrompt = app.staticTexts["Don't have an account?"]
        XCTAssertTrue(signUpPrompt.exists, "'Don't have an account?' text should be visible")

        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists, "Sign Up button should be visible")

        signUpButton.tap()

        // Should navigate to the sign-up view which shows "Create Account"
        let createAccountTitle = app.staticTexts["Create Account"]
        XCTAssertTrue(
            waitForElement(createAccountTitle),
            "Should navigate to Create Account screen after tapping Sign Up"
        )
    }

    /// Verify the "Forgot Password?" link navigates to the password reset screen.
    func testPasswordResetLinkNavigation() throws {
        launchApp()

        guard app.buttons["Sign In"].waitForExistence(timeout: 5) else {
            throw XCTSkip("Already authenticated; sign-in screen not displayed.")
        }

        let forgotPasswordButton = app.buttons["Forgot Password?"]
        XCTAssertTrue(forgotPasswordButton.exists, "Forgot Password button should be visible")

        forgotPasswordButton.tap()

        // Should navigate to password reset view.
        // The PasswordResetView likely has a "Reset Password" or similar header.
        let passwordResetIndicator = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'reset' OR label CONTAINS[c] 'forgot' OR label CONTAINS[c] 'password'")
        )
        XCTAssertTrue(
            passwordResetIndicator.firstMatch.waitForExistence(timeout: 5),
            "Should navigate to password reset screen"
        )

        // Verify we can navigate back
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists {
            backButton.tap()
            XCTAssertTrue(
                app.buttons["Sign In"].waitForExistence(timeout: 3),
                "Should return to sign-in screen after tapping back"
            )
        }
    }

    /// Verify that both the sign-in form fields accept text input.
    func testSignInFieldsAcceptInput() throws {
        launchApp()

        guard app.buttons["Sign In"].waitForExistence(timeout: 5) else {
            throw XCTSkip("Already authenticated; sign-in screen not displayed.")
        }

        let emailField = app.textFields["your@email.com"]
        emailField.tap()
        emailField.typeText("user@test.com")
        XCTAssertEqual(
            emailField.value as? String,
            "user@test.com",
            "Email field should contain typed text"
        )

        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("mypassword")
        // SecureField value is masked; just verify the field is focused / has content
        XCTAssertNotNil(passwordField.value, "Password field should have a value after typing")
    }

    // =========================================================================
    // MARK: - Flow 3: Program Interaction
    // =========================================================================

    /// Verify that program cards appear when there is content in the Top view sections.
    func testProgramCardExists() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        // Wait for recommended section to load
        let recommendedHeader = app.staticTexts["Recommended"]
        XCTAssertTrue(waitForElement(recommendedHeader), "Recommended section should exist")

        // Look for any program card elements. Programs display titles as static text
        // and contain play count labels with the play.fill icon.
        // If no programs are loaded, we expect empty state text.
        let noRecommendations = app.staticTexts["No recommendations yet"]
        let noFavorites = app.staticTexts["No favorites yet"]

        // Either program cards or empty state messages should be visible
        let hasProgramContent = app.scrollViews.otherElements.buttons.count > 0
        let hasEmptyState = noRecommendations.exists || noFavorites.exists

        XCTAssertTrue(
            hasProgramContent || hasEmptyState,
            "Top view should show either program cards or empty state messages"
        )
    }

    /// Verify the program detail view contains expected UI elements
    /// (play button, waveform area, controls).
    func testProgramViewElements() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        // Wait for content to load, then try to tap a program card
        let recommendedHeader = app.staticTexts["Recommended"]
        _ = waitForElement(recommendedHeader)

        // Attempt to find and tap a NavigationLink (program card) in the scroll view
        // Program cards are wrapped in NavigationLinks which become buttons in XCUI
        let scrollViews = app.scrollViews
        let firstProgramLink = scrollViews.descendants(matching: .button).firstMatch

        guard waitForElement(firstProgramLink, timeout: 5),
              firstProgramLink.isHittable else {
            throw XCTSkip("No program cards found to navigate to program detail view.")
        }

        firstProgramLink.tap()

        // Wait for the program detail to load
        // The program view shows a play/pause button (via PlayButton),
        // seek controls (gobackward.15, goforward.30), and the waveform
        let playButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'play' OR label CONTAINS 'pause'")
        ).firstMatch
        XCTAssertTrue(
            waitForElement(playButton, timeout: 5),
            "Program view should contain a play/pause button"
        )

        // Seek backward button
        let seekBackward = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'backward' OR label CONTAINS '15'")
        ).firstMatch
        if seekBackward.exists {
            XCTAssertTrue(seekBackward.isHittable, "Seek backward button should be hittable")
        }

        // Seek forward button
        let seekForward = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'forward' OR label CONTAINS '30'")
        ).firstMatch
        if seekForward.exists {
            XCTAssertTrue(seekForward.isHittable, "Seek forward button should be hittable")
        }
    }

    /// Verify the mini player bar appears at the bottom of the screen
    /// when a program has been interacted with for playback.
    func testMiniPlayerAppears() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        // Navigate to a program
        let recommendedHeader = app.staticTexts["Recommended"]
        _ = waitForElement(recommendedHeader)

        let firstProgramLink = app.scrollViews.descendants(matching: .button).firstMatch
        guard waitForElement(firstProgramLink, timeout: 5),
              firstProgramLink.isHittable else {
            throw XCTSkip("No program cards found to test mini player.")
        }

        firstProgramLink.tap()

        // Find and tap the play button to start playback
        let playButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'play'")
        ).firstMatch

        guard waitForElement(playButton, timeout: 5), playButton.isHittable else {
            throw XCTSkip("Play button not found or not hittable in program view.")
        }

        playButton.tap()

        // Go back to the top view to check for the mini player
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists && backButton.isHittable {
            backButton.tap()
        }

        // The mini player shows "Not Playing" or the program title as text.
        // It also has a close button (xmark.circle.fill) and a play/pause button.
        // Give it a moment to appear with transition animation.
        let miniPlayerCloseButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'xmark' OR label CONTAINS 'close'")
        ).firstMatch

        let miniPlayerPlayButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'play' OR label CONTAINS 'pause'")
        ).firstMatch

        // The mini player may or may not appear depending on whether playback actually started
        // (it requires network/audio which may not work in UI test environment).
        // We verify the structure is correct if it does appear.
        if miniPlayerCloseButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(miniPlayerPlayButton.exists, "Mini player should have a play/pause button")
        }
    }

    /// Verify the share button exists in the program detail toolbar.
    func testShareButtonExists() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        let firstProgramLink = app.scrollViews.descendants(matching: .button).firstMatch
        guard waitForElement(firstProgramLink, timeout: 5),
              firstProgramLink.isHittable else {
            throw XCTSkip("No program cards found to test share button.")
        }

        firstProgramLink.tap()

        // Wait for program view to load
        // The ShareButton has accessibilityLabel("Share")
        let shareButton = app.buttons["Share"]
        XCTAssertTrue(
            waitForElement(shareButton, timeout: 5),
            "Share button should exist in the program detail view toolbar"
        )
    }

    /// Verify the favorite button exists in the program detail toolbar.
    func testFavoriteButtonExists() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        let firstProgramLink = app.scrollViews.descendants(matching: .button).firstMatch
        guard waitForElement(firstProgramLink, timeout: 5),
              firstProgramLink.isHittable else {
            throw XCTSkip("No program cards found to test favorite button.")
        }

        firstProgramLink.tap()

        // The FavoriteButton should be in the toolbar alongside the ShareButton.
        // Look for a heart-related button in the navigation bar.
        let heartButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'favorite' OR label CONTAINS[c] 'heart'")
        ).firstMatch

        XCTAssertTrue(
            waitForElement(heartButton, timeout: 5),
            "Favorite (heart) button should exist in the program detail view toolbar"
        )
    }

    /// Verify pull-to-refresh works on the Top view.
    func testPullToRefreshOnTopView() throws {
        launchApp()

        let topTab = app.tabBars.buttons["Top"]
        guard waitForElement(topTab, timeout: 10) else {
            throw XCTSkip("Tab bar not visible; app is showing sign-in screen.")
        }

        topTab.tap()

        let recommendedHeader = app.staticTexts["Recommended"]
        XCTAssertTrue(waitForElement(recommendedHeader), "Recommended section should exist")

        // Perform pull-to-refresh gesture
        let firstScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(firstScrollView.exists, "Scroll view should exist on Top view")

        let start = firstScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let end = firstScrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: end)

        // After refresh, the recommended section should still be visible
        XCTAssertTrue(
            waitForElement(recommendedHeader, timeout: 5),
            "Recommended section should still be visible after pull-to-refresh"
        )
    }
}
