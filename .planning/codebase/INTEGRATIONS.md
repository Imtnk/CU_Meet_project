# External Integrations

**Analysis Date:** 2026-05-11

## APIs & External Services

**Google Identity:**
- Google Sign-In — OAuth 2.0 user authentication
  - SDK/Client: `GoogleSignIn` 9.1.0, `GoogleSignInSwift` 9.1.0
  - Auth: Client ID hardcoded as `71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76.apps.googleusercontent.com` in `CU_Meet_project/App/CU_Meet_projectApp.swift` and `CU-Meet-project-Info.plist`
  - URL scheme registered: `com.googleusercontent.apps.71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76` (in `CU-Meet-project-Info.plist` under `CFBundleURLSchemes`)
  - URL callback handled in `CU_Meet_project/App/CU_Meet_projectApp.swift` via `.onOpenURL { GIDSignIn.sharedInstance.handle(url) }`

**Maps:**
- Apple MapKit — Campus map display with room pin annotations
  - SDK/Client: `MapKit` (Apple system framework)
  - Auth: None required (no API key needed for MapKit on iOS)
  - Used in: `CU_Meet_project/Views/Home/RoomMapView.swift`, `CU_Meet_project/ViewModels/HomeViewModel.swift`
  - Map is centered on Chulalongkorn University campus (lat: 13.736717, lon: 100.533186)

## Data Storage

**Databases:**
- None — No external database or backend detected. All data is held in in-memory `ObservableObject` stores.
  - `BookingStore` in `CU_Meet_project/Models/BookingStore.swift` — runtime booking state, no persistence
  - `GroupStore` in `CU_Meet_project/Models/Group.swift` — runtime group state, no persistence

**File Storage:**
- Local filesystem only — Asset images stored in `CU_Meet_project/Resources/Assets.xcassets/`
- No cloud file storage detected

**Caching:**
- None — No caching layer detected. In-memory only.

**Persistence:**
- None detected — App state (bookings, groups) is lost on app termination. No `UserDefaults`, `CoreData`, `SwiftData`, or file-based persistence is used.

## Authentication & Identity

**Auth Provider:**
- Google Sign-In (OAuth 2.0 via `GoogleSignIn-iOS` SDK)
  - Implementation: `CU_Meet_project/Services/AuthManager.swift` — `ObservableObject` wrapping `GIDSignIn.sharedInstance`
  - Secondary ViewModel: `CU_Meet_project/Services/AuthViewModel.swift` — duplicate auth logic (also uses `GIDSignIn.sharedInstance`)
  - Sign-in UI: `GoogleSignInButton` SwiftUI component from `GoogleSignInSwift` used in `CU_Meet_project/Views/Profile/ProfileView.swift` and `CU_Meet_project/Views/Profile/LoginView.swift`
  - Restore session: `GIDSignIn.sharedInstance.hasPreviousSignIn()` / `restorePreviousSignIn()` called in `CU_Meet_project/Views/Profile/LoginView.swift`
  - User profile data accessed: `GIDGoogleUser.profile?.name`, `GIDGoogleUser.profile?.email`

**Custom Auth:**
- None — no custom JWT, session tokens, or backend auth

## Monitoring & Observability

**Error Tracking:**
- None — no Sentry, Crashlytics, or equivalent detected

**Logs:**
- `print()` statements only (e.g., `print("Log in failed: \(error.localizedDescription)")` in `CU_Meet_project/Services/AuthViewModel.swift`)
- No structured logging framework

## CI/CD & Deployment

**Hosting:**
- iOS App — distributed via Apple App Store or direct Xcode install
- No server hosting required (no backend)
- Development Team ID: `CYDDKJXD62` (in `CU_Meet_project.xcodeproj/project.pbxproj`)

**CI Pipeline:**
- None detected — no `.github/workflows/`, `Fastfile`, or CI config files

## Environment Configuration

**Required configuration:**
- Google OAuth Client ID: hardcoded in source — no runtime env vars needed
  - `CU_Meet_project/App/CU_Meet_projectApp.swift` line 19: `clientID: "71930476155-..."`
  - `CU-Meet-project-Info.plist`: `GIDClientID` key

**Secrets location:**
- Google Client ID is embedded directly in source code (not in a secrets file)
- No `.env` files, `secrets/` directories, or keychain usage detected

## Webhooks & Callbacks

**Incoming:**
- Google Sign-In OAuth redirect handled via custom URL scheme: `com.googleusercontent.apps.71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76`
  - Registered in `CU-Meet-project-Info.plist`
  - Handled in `CU_Meet_project/App/CU_Meet_projectApp.swift` via `onOpenURL`

**Outgoing:**
- None detected — no HTTP requests, webhooks, or push notification payloads sent from the app

---

*Integration audit: 2026-05-11*
