# Concerns

**Analysis Date:** 2026-05-11

## Bugs

### Leave Group confirmation never triggers
- **File:** `CU_Meet_project/Views/Groups/GroupDetailView.swift`
- **Issue:** The confirmation alert is declared but never triggered — group is left immediately on button tap with no confirmation step shown to the user.
- **Severity:** High (UX/data loss risk)

### Orphaned LoginView
- **File:** `CU_Meet_project/Views/Profile/LoginView.swift`
- **Issue:** Session restore logic lives in `LoginView`, but it is never navigated to in the current app flow. Users who relaunch the app always start unauthenticated.
- **Severity:** High (broken auth persistence)

### Hardcoded "You" identity
- **Files:** `GroupDetailView.swift`, `GroupsView.swift`, `Group.swift`
- **Issue:** Group membership uses the string literal `"You"` as a user identifier instead of a real user ID. This means the app cannot distinguish between users and will break any multi-user scenario.
- **Severity:** High (fundamental identity gap)

## Technical Debt

### Duplicate auth classes
- **Files:** `CU_Meet_project/Services/AuthManager.swift`, `CU_Meet_project/Services/AuthViewModel.swift`
- **Issue:** Two separate Google Sign-In wrapper classes exist (`AuthManager` used by `ProfileView`, `AuthViewModel` used by `LoginView`). Auth state is not unified. `AuthManager` is a local `@StateObject` in `ProfileView` instead of a root environment object.
- **Severity:** Medium

### No persistence layer
- **Scope:** Entire app (`BookingStore`, `GroupStore`)
- **Issue:** All bookings and groups are in-memory only — they are erased on every app relaunch. No UserDefaults, CoreData, or network backend.
- **Severity:** High (all user data lost on relaunch)

### Google OAuth Client ID hardcoded in source
- **File:** `CU_Meet_project/App/CU_Meet_projectApp.swift` (line 19)
- **Issue:** Client ID is also hardcoded in Swift source in addition to `Info.plist`. It should be read exclusively from `Info.plist`.
- **Severity:** Low (credential hygiene)

### DateFormatter created per render
- **Files:** Multiple view files (4 locations)
- **Issue:** `DateFormatter` instances are created inline inside view bodies, which means a new formatter is allocated on every render. Should be a static or `@State` property.
- **Severity:** Low (performance)

## Dead Code

### RoomDetailSheet
- **File:** `CU_Meet_project/Views/Home/RoomDetailSheet.swift`
- **Issue:** Contains hardcoded placeholder text (`"667K Ratings"`). Appears to be an unused condensed variant of `RoomDetailView`. Not navigated to from any current flow.
- **Severity:** Low (cleanup)

## Test Coverage

- **Zero test coverage** — no XCTest target exists in the project
- No unit tests, no UI tests, no snapshot tests
- `#Preview` macros are the only form of verification

## Security

- Google OAuth Client ID duplicated in source (see above)
- No secrets scanning in CI (no CI exists)
- All user data is local and in-memory — no network security surface currently

---
*Mapped: 2026-05-11*
