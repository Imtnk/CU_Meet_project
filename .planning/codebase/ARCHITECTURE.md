# Architecture

**Analysis Date:** 2026-05-11

## Pattern Overview

**Overall:** MVVM (Model-View-ViewModel) with SwiftUI and in-memory ObservableObject stores

**Key Characteristics:**
- Views consume shared state via `@EnvironmentObject` injected at app root
- Business/domain logic lives in `ObservableObject` store classes (Models layer) and ViewModels
- Navigation uses SwiftUI `NavigationStack` with `NavigationLink` and modal `.sheet` presentations
- No persistence layer — all state is in-memory and resets on app launch
- Authentication is handled by a separate service layer (`Services/`) using Google Sign-In

## Layers

**App Layer:**
- Purpose: App entry point; creates and injects root ObservableObjects into the environment
- Location: `CU_Meet_project/App/CU_Meet_projectApp.swift`
- Contains: `@main` struct, `@StateObject` instantiation of `BookingStore` and `GroupStore`, Google Sign-In configuration, URL handler for OAuth callback
- Depends on: Models, Views
- Used by: iOS runtime

**Models Layer:**
- Purpose: Domain data structures and in-memory stores that hold and mutate application state
- Location: `CU_Meet_project/Models/`
- Contains: Value types (`Booking`, `MeetingRoom`, `Group`, `Facility`), ObservableObject stores (`BookingStore`, `GroupStore`), static data (`rooms` global array)
- Depends on: Foundation, Combine, CoreLocation, MapKit
- Used by: ViewModels, Views

**Services Layer:**
- Purpose: External service integration (authentication); thin wrappers around Google Sign-In SDK
- Location: `CU_Meet_project/Services/`
- Contains: `AuthManager` (used by `ProfileView` directly), `AuthViewModel` (used by `LoginView` directly)
- Depends on: GoogleSignIn, Combine
- Used by: Profile views

**ViewModels Layer:**
- Purpose: View-specific presentation logic that does not belong in Views
- Location: `CU_Meet_project/ViewModels/`
- Contains: `HomeViewModel` — manages MapKit camera region, zoom controls, pin sizing
- Depends on: MapKit, Combine
- Used by: `RoomMapView`

**Views Layer:**
- Purpose: All UI rendering and user interaction
- Location: `CU_Meet_project/Views/`
- Contains: Feature-grouped SwiftUI Views
- Depends on: Models (via `@EnvironmentObject`), ViewModels (via `@StateObject`), Services (via local `@StateObject`)
- Used by: App layer (root is `MainTabView`)

## Data Flow

**Booking Flow:**

1. User taps "Book Now" on `HomeView` → navigates to `RoomMapView` via `NavigationLink`
2. `RoomMapView` displays map pins from static `rooms` array; user taps a pin → navigates to `RoomDetailView(room:)`
3. `RoomDetailView` reads `bookingStore.isBooked(roomID:date:timeSlot:)` to disable already-booked slots
4. User selects date, group, and time slot → taps "Reserve Room" → `.sheet` presents `BookingConfirmationView`
5. User confirms → `bookingStore.addBooking(_:)` appends a `Booking` to `@Published var bookings`
6. `HomeView.upcomingSection` re-renders via Combine `@Published` binding, showing the new booking

**Group Flow:**

1. `GroupsView` reads `groupStore.myGroups` (filtered `@Published var groups`) to list joined groups
2. "Create Group" sheet → `CreateGroupView` calls `groupStore.createGroup(name:)` → new `Group` appended, join code displayed
3. "Join Group" sheet → `JoinGroupView` calls `groupStore.joinGroup(code:)` → returns `JoinResult` enum case
4. Tap group in list → `GroupDetailView` reads live state via `groupStore.groups.first(where:)` computed property
5. "Leave Group" → `groupStore.leaveGroup(groupID:)` removes member; removes group if empty

**Authentication Flow:**

1. `ProfileView` instantiates `AuthManager` as local `@StateObject`
2. `LoginView` instantiates `AuthViewModel` as local `@StateObject`
3. Google Sign-In OAuth flow is triggered via `GIDSignIn.sharedInstance.signIn(withPresenting:)`
4. App entry point (`CU_Meet_projectApp`) handles the OAuth callback URL via `.onOpenURL`
5. Auth state is local to the profile tab — not shared app-wide via environment

**State Management:**
- `BookingStore` and `GroupStore` are instantiated once at app root and injected as `@EnvironmentObject` — all views share the same instance
- `HomeViewModel` is created per `RoomMapView` instance with `@StateObject`
- `AuthManager` / `AuthViewModel` are created per-view with `@StateObject` — auth state is not shared globally

## Key Abstractions

**BookingStore:**
- Purpose: Source of truth for all room bookings
- Examples: `CU_Meet_project/Models/BookingStore.swift`
- Pattern: `ObservableObject` with `@Published var bookings: [Booking]`; provides query methods (`isBooked`, `upcomingBookings`) and mutating methods (`addBooking`, `cancelBooking`)

**GroupStore:**
- Purpose: Source of truth for all groups and membership
- Examples: `CU_Meet_project/Models/Group.swift`
- Pattern: `ObservableObject` with `@Published var groups: [Group]`; co-located with `Group` struct in the same file; provides `JoinResult` enum for join outcomes

**MeetingRoom + rooms:**
- Purpose: Static data model for bookable rooms
- Examples: `CU_Meet_project/Models/MeetingRoom.swift`
- Pattern: `struct` with CoreLocation coordinates; global `let rooms: [MeetingRoom]` array provides all room data (no remote fetch)

**Facility:**
- Purpose: Enumeration of room amenities for display and filtering
- Examples: `CU_Meet_project/Models/Facility.swift`
- Pattern: `enum` conforming to `String`, `CaseIterable`, `Identifiable`

**HomeViewModel:**
- Purpose: Map camera state management with derived presentation values
- Examples: `CU_Meet_project/ViewModels/HomeViewModel.swift`
- Pattern: `ObservableObject` with `@Published var region: MKCoordinateRegion`; computed `pinSize` scales marker size based on zoom level

## Entry Points

**App Entry:**
- Location: `CU_Meet_project/App/CU_Meet_projectApp.swift`
- Triggers: iOS app launch (`@main`)
- Responsibilities: Creates `BookingStore` and `GroupStore` as `@StateObject`, configures Google Sign-In client ID, injects stores as `@EnvironmentObject` into `MainTabView`, registers URL handler

**Main Tab Navigation:**
- Location: `CU_Meet_project/Views/MainTabView.swift`
- Triggers: Rendered by `CU_Meet_projectApp`
- Responsibilities: Hosts three tabs — Home, Groups, Profile — using SwiftUI `TabView` with a typed `Tab` enum

## Error Handling

**Strategy:** Minimal; user-facing errors surfaced through SwiftUI `.alert` modifiers and inline `Text` labels

**Patterns:**
- `GroupStore.joinGroup` returns a `JoinResult` enum (`success`, `alreadyMember`, `notFound`) — caller switches on the result to construct an alert message
- `RoomDetailView` disables booking slots that fail `isPastSlot` or `isBooked` checks — no thrown errors
- Auth failures print to console via `print("Log in failed: \(error.localizedDescription)")` in `AuthViewModel`
- No global error handling or error state propagation across the app

## Cross-Cutting Concerns

**Logging:** `print()` statements only; no structured logging framework
**Validation:** Inline guard conditions in views (e.g., `canProceed` computed property requiring both `selectedTime` and `selectedGroupID`)
**Authentication:** Handled locally in the Profile tab; not enforced app-wide — Home and Groups tabs are accessible without signing in

---

*Architecture analysis: 2026-05-11*
