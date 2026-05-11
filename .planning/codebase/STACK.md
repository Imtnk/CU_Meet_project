# Technology Stack

**Analysis Date:** 2026-05-11

## Languages

**Primary:**
- Swift 5.0 - All application source code (`.swift` files throughout `CU_Meet_project/`)

**Secondary:**
- None detected

## Runtime

**Environment:**
- iOS / iPadOS native application
- Targeted device family: iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)

**Package Manager:**
- Swift Package Manager (SPM) via Xcode
- Resolved lockfile: `CU_Meet_project.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

## Frameworks

**Core UI:**
- SwiftUI - All views and UI composition (`CU_Meet_project/Views/`, `CU_Meet_project/App/`)
- Combine - Reactive state propagation via `@Published`, `ObservableObject` (`CU_Meet_project/Services/`, `CU_Meet_project/Models/`, `CU_Meet_project/ViewModels/`)

**Mapping:**
- MapKit - Interactive map display and coordinate handling (`CU_Meet_project/Views/Home/RoomMapView.swift`, `CU_Meet_project/ViewModels/HomeViewModel.swift`, `CU_Meet_project/Models/MeetingRoom.swift`)
- CoreLocation - GPS coordinate types (`CLLocationCoordinate2D` in `CU_Meet_project/Models/MeetingRoom.swift`)

**Authentication:**
- GoogleSignIn 9.1.0 - OAuth sign-in flow (`CU_Meet_project/Services/AuthManager.swift`, `CU_Meet_project/Services/AuthViewModel.swift`)
- GoogleSignInSwift 9.1.0 - SwiftUI button component (`CU_Meet_project/Views/Profile/LoginView.swift`, `CU_Meet_project/Views/Profile/ProfileView.swift`)

**Testing:**
- Not detected (no test targets or test files found)

**Build/Dev:**
- Xcode (project file: `CU_Meet_project.xcodeproj/project.pbxproj`)
- Xcode version: Built with Xcode 26.4 (`CreatedOnToolsVersion = 26.4`)

## Key Dependencies

**Direct (declared in project.pbxproj):**
- `GoogleSignIn-iOS` >= 9.1.0 (upToNextMajorVersion) — OAuth 2.0 authentication via Google
  - Source: `https://github.com/google/GoogleSignIn-iOS`

**Transitive (resolved in Package.resolved):**
- `app-check` 11.2.0 — Google App Check (`https://github.com/google/app-check.git`)
- `appauth-ios` 2.0.0 — OpenID Connect / OAuth 2.0 base (`https://github.com/openid/AppAuth-iOS.git`)
- `googleutilities` 8.1.0 — Google shared utilities (`https://github.com/google/GoogleUtilities.git`)
- `gtm-session-fetcher` 3.5.0 — HTTP networking for Google SDKs (`https://github.com/google/gtm-session-fetcher.git`)
- `gtmappauth` 5.0.0 — GTM OAuth token management (`https://github.com/google/GTMAppAuth.git`)
- `promises` 2.4.0 — Async promises utility (`https://github.com/google/promises.git`)

**Standard Apple Frameworks (no SPM entry, linked via Xcode):**
- Foundation — Data types, Date, UUID, Calendar, etc.
- SwiftUI — Declarative UI
- MapKit — Map rendering
- CoreLocation — Location coordinate types
- Combine — Reactive publishers and subscribers

## Configuration

**Environment:**
- No `.env` files detected
- Google OAuth Client ID is hardcoded in `CU_Meet_project/App/CU_Meet_projectApp.swift`:
  `GIDConfiguration(clientID: "71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76.apps.googleusercontent.com")`
- Client ID is also declared in `CU-Meet-project-Info.plist` under key `GIDClientID`

**Build:**
- Project file: `CU_Meet_project.xcodeproj/project.pbxproj`
- Info.plist: `CU-Meet-project-Info.plist`
- Assets: `CU_Meet_project/Resources/Assets.xcassets/`
- Bundle ID: `imm.CU-Meet-project`
- Marketing version: 1.0 / Build 1

## Platform Requirements

**Development:**
- Xcode 26.4 or later
- Swift 5.0
- macOS with Xcode for building

**Production:**
- iOS deployment target: 26.0 (minimum), 26.4 (recommended)
- Supports iPhone and iPad (universal)
- No server-side component detected — fully client-side app with in-memory state

---

*Stack analysis: 2026-05-11*
