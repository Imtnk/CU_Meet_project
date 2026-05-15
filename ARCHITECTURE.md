# CU Meet Project Architecture

## Overview

CU Meet is an iOS meeting room booking app that allows groups to reserve meeting facilities on campus. The app is built with SwiftUI and integrates with Firebase for backend services (Firestore database, Firebase Auth).

---

## Core Architecture Layers

### 1. **Services Layer** (Backend Integration)

Services handle all external API calls and data persistence. They're singletons injected as environment objects.

#### **FirestoreService** (`Services/FirestoreService.swift`)
- **Purpose:** Single source of truth for Firestore operations
- **Key Methods:**
  - `addBooking(_:)` — Save new booking to Firestore (auto-persists notes field)
  - `listenToBookings(completion:)` — Real-time listener for booking updates
  - `listenToGroups(completion:)` — Real-time group data
  - `listenToUsers(userIDs:completion:)` — Batch fetch user profiles
  - `updateBookingStatus(id:status:)` — Cancel a booking
  - `updateBookingNotes(id:notes:)` — Edit the notes/agenda field in-place
  - Group CRUD operations (create, join, update)
- **Why it matters:** All Firestore reads/writes go through one place, making it easy to debug data flow
- **Note on notes:** The `Booking` struct is `Codable`, so adding `notes: String?` field required zero changes to FirestoreService — persistence happens automatically

#### **AuthManager** (`Services/AuthManager.swift`)
- **Purpose:** Handles Google Sign-In + Firebase Auth
- **Key Methods:**
  - `signIn()` — Triggers Google Sign-In flow
  - `signOut()` — Clears session (user profile, tokens)
  - `restorePreviousSignIn()` — Re-establish session on app launch
  - `authenticateWithFirebase(googleUser:completion:)` — Create Firebase user from Google identity
- **Published Properties:**
  - `isLoggedIn` — Whether user has valid session
  - `currentUserID` — Firebase UID for data lookups
  - `isFirebaseAuthenticated` — Whether Firebase auth succeeded (vs. Google-only fallback)
- **Why dual auth?** Google provides user identity; Firebase secures Firestore access. If Firebase auth fails, the app still works with Google UID as a fallback

#### **NotificationManager** (`Services/NotificationManager.swift`)
- **Purpose:** Schedule local notifications for upcoming bookings
- **Key Methods:**
  - `scheduleReminder(for:)` — Queue notification X minutes before booking
  - `cancelReminder(for:)` — Remove notification for cancelled booking
- **Why it matters:** Users get reminders without needing push notifications (works offline, respects quiet hours)

#### **UserStore** (`Services/UserStore.swift`)
- **Purpose:** In-memory cache of `AppUser` objects keyed by Firebase UID; auto-fetches unknown users on demand
- **Methods:**
  - `upsert(_:)` — Merge a user into cache (existing fields absent from the incoming value are preserved)
  - `user(by:)` — Return cached user or trigger async fetch and return `nil` until data arrives
  - `displayName(for:)` — Return cached display name or "Unknown User" while fetching
- **Why it matters:** Avoids repeated Firestore fetches for the same user across the app

#### **GroupStore** (`Models/Group.swift`)
- **Purpose:** Real-time sync of the current user's groups via Firestore listener
- **Key Methods:**
  - `startListening(for:)` — Attach Firestore listener scoped to the user's groups
  - `stopListening()` — Detach listener and clear cached groups
  - `createGroup(name:creatorID:)` — Validate name, generate unique 6-digit code, persist to Firestore
  - `joinGroup(code:userID:)` — Look up group by join code, append user to member list
  - `leaveGroup(groupID:userID:)` — Remove user from members; delete group if last member
  - `myGroups(currentUserID:)` — Filter groups the current user belongs to
  - `groupName(for:)` — Convenience lookup for display
- **Why it matters:** Provides reactive group data so member lists, names, and join codes stay in sync

#### **AppError** (`Services/AppError.swift`)
- **Purpose:** Centralized domain errors with user-facing descriptions and recovery suggestions
- **Cases:**
  - `invalidGroupName(reason:)` — Group name fails validation
  - `invalidJoinCode` — Not exactly 6 digits
  - `groupNotFound` — No group for the given join code
  - `alreadyMember` — Current user already belongs to the group
  - `uniqueCodeGenerationFailed` — Could not generate non-colliding code
  - `bookingConflict` — Time slot overlaps an existing booking
  - `pastDateTime` — Booking time is in the past
  - `authRequired` — User must be signed in
  - `networkError` — Connectivity failure
  - `unknown(Error)` — Catch-all wrapper
- **Why it matters:** Every layer uses the same error type; views display consistent, actionable messages

---

### 2. **Models Layer** (Data Structures)

Models represent the domain objects. All are `Codable` for Firestore serialization.

#### **Booking** (`Models/BookingStore.swift`)
```swift
struct Booking {
    let id: String
    let roomID: String
    let roomName: String
    let groupID: String
    let date: Date
    let timeSlot: String         // "09:00 - 10:00"
    var status: BookingStatus    // .active or .cancelled
    var imageAssetName: String?
    /// Optional agenda or note attached to the booking; mutable for inline editing.
    var notes: String?
}
```
- **Lifecycle:** Created in BookingConfirmationView, persisted to Firestore, displayed and editable in BookingDetailView
- **Notes validation:** Max 200 chars, whitespace trimmed, stored as `nil` if empty
- **Notes editing:** Inline TextField in BookingDetailView with live validation and character counter; persisted via `FirestoreService.updateBookingNotes`
- **Persistence:** Firestore automatically handles `notes` field (no migration needed since it's optional)

#### **Group** (`Models/Group.swift`)
- Represents a team/project group that shares bookings
- Members tracked by ID; join via 6-digit code
- Firestore listener keeps all groups in sync

#### **AppUser** (`Models/AppUser.swift`)
- User profile (name, email, avatar URL)
- Loaded from Firestore + Google profile
- Cached in UserStore to avoid repeated fetches

#### **MeetingRoom** (`Models/MeetingRoom.swift`)
- Room metadata (name, capacity, location, features)
- Includes image asset name for display
- Static data (not real-time listener)

#### **Facility** (`Models/Facility.swift`)
- Enum of available room amenities (projector, whiteboard, TV screen, air conditioning, video conferencing, power outlets, Wi-Fi)
- Used for filtering and display in room detail views

#### **BookingStore** (`Models/BookingStore.swift` class)
- Published collection of all bookings
- Real-time listener via FirestoreService
- Methods:
  - `upcomingBookings()` — Filtered list for HomeView
  - `isBooked(roomID:date:timeSlot:)` — Availability check
  - `isUpcoming(_:)` — Check if booking hasn't passed yet
  - `updateNotes(bookingID:notes:)` — Persist edited notes via FirestoreService

---

### 3. **ViewModels Layer** (Business Logic)

ViewModels transform models into UI-ready data.

#### **HomeViewModel** (`ViewModels/HomeViewModel.swift`)
- **Purpose:** Owns map camera state, room data, zoom controls, and pin sizing
- **Published State:**
  - `region` — Visible map region driving camera position
  - `rooms` — Meeting rooms fetched from Firestore
  - `position` — Derived `MapCameraPosition` from region
  - `pinSize` — Annotation diameter scaled inversely with zoom level
- **Key Methods:**
  - `loadRooms()` — Fetch all rooms from Firestore
  - `rateRoom(roomID:userID:stars:)` — Submit star rating, re-fetch updated values
  - `zoomIn()` / `zoomOut()` — Halve / double map span
  - `resetView()` — Re-center on default CU campus region
  - `clampRegion()` — Constrain center within CU campus bounding box
- **Why it matters:** All map and room filtering logic is centralized and testable

---

### 4. **Utilities Layer** (Helpers)

#### **AppTheme** (`Utilities/AppTheme.swift`)
- Design tokens: six dynamic colors (`brandPink`, `brandPinkLight`, `brandPinkDark`, `charcoal`, `warmGray`, `mutedGray`), three corner radii (`cardRadius`, `chipRadius`, `buttonRadius`), and `cardBackground`
- Dark mode support via `UIColor.dynamicColor(lightHex:darkHex:)` — each color provides separate light/dark hex values, selected automatically based on the OS Appearance setting
- `Color` convenience extension exposes theme colors as static members and provides `init(hex:)` for CSS-style hex strings
- Single source of truth for visual style, used across all views

#### **ValidationHelpers** (`Utilities/ValidationHelpers.swift`)
- Pure validation functions returning `(isValid: Bool, error: String?)`
- Validates: group names (1–100 chars), join codes (6 digits), booking dates (not past), booking notes (max 200 chars)
- `String.nonEmpty` extension converts empty/whitespace strings to `nil`

---

### 5. **Views Layer** (UI)

Views are composed hierarchically, with environment objects injected at the top level.

#### **MainTabView** (`Views/MainTabView.swift`)
- Root tab navigation (Home, Groups, Profile)
- Injects environment objects: `BookingStore`, `GroupStore`, `UserStore`, `AuthManager`

#### **Home Tab** (`Views/Home/*.swift`)
- **HomeView:** Upcoming bookings list + quick-access room grid; shows user's display name in header
- **RoomDetailView:** Full room info sheet (facilities, rating, capacity), available time slots picker, group selector, and booking action
- **RoomMapView:** `MKMapView`-backed map with custom annotation pins sized by zoom level; search bar for filtering by name/facility; bottom sheet list view; zoom in/out buttons and reset camera
- **BookingConfirmationView:** Review-and-confirm sheet with room image, selected date/time/group, optional notes text field (200-char max with live validation and character counter), cancel/confirm buttons. Shows a "Booking Confirmed!" toast on success
- **BookingDetailView:** Hero image, room/time section, group info with full member list (tappable rows navigate to `MemberDetailView`), editable notes card with inline TextField (live validation, character counter, cancel/save — shows "Notes Saved!" toast), cancel booking with confirmation alert
- **AllBookingsView:** Scrollable list of all upcoming bookings filterable by group; each row is an `UpcomingBookingCard`
- **RoomDetailSheet:** Bottom sheet with room image, rating pill, capacity badge, and facility grid

#### **Groups Tab** (`Views/Groups/*.swift`)
- **GroupsView:** List of user's groups with pull-to-refresh
- **GroupDetailView:** Group name, member rows (`MemberRowView` with "You" badge), join code badge, leave group action, upcoming bookings for the group via sheet
- **CreateGroupView:** Form with group name field (validated), auto-generated join code, create action
- **JoinGroupView:** 6-digit code entry with length counter, validation feedback, join button. Success shows a toast; errors show an alert
- **GroupCard:** Reusable card showing group name, member count, and join code
- **BookingDetailView:** Shared booking detail used from both Home and Groups tabs

#### **Profile Tab** (`Views/Profile/*.swift`)
- **ProfileView:** Signed-in → avatar (AsyncImage), name, nickname, email, editable CU profile card, sign-out button. Signed-out → logo, welcome text, Google Sign-In button
- **EditProfileView:** Form sheet for editing CU profile fields (nickname, student ID with 10-digit validation, faculty, year of study picker, birthdate toggle, most active day picker). Shows a "Profile Saved!" toast before dismissing
- **MemberDetailView:** Full-screen detail for any group member — avatar (from `photoURL`), name/email, Account section (first/last name, email), CU Profile section (nickname, student ID, faculty, year), Personal section (birthdate, most active day). Data fetched from Firestore on appear

#### **Components** (`Views/Components/*.swift`)
- **MemberRowView:** Tappable row with avatar circle, display name, "You" badge for current user, chevron
- **UpcomingBookingCard:** Compact horizontal card showing group name, room, time slot, date, chevron
- **RoomFeatureCard:** Hero card with room image overlay, name, capacity label, rating pill
- **ToastModifier:** Reusable overlay modifier (`View.toast(isPresented:message:)`) — pink capsule banner that slides from the top, auto‑dismisses after 2s. Used for success feedback on booking confirmations, profile saves, notes edits, group creation, and group joining

#### **SplashView** & **CU_Meet_projectApp**
- **SplashView:** Branded overlay (pink background, logo, app name) with fade-out transition after 1.8s
- **CU_Meet_projectApp:** `@main` entry point — configures Firebase, Google Sign-In, `NotificationManager`; injects all stores as `@EnvironmentObject`; handles `onOpenURL` for Google Sign-In callbacks

---

## Data Flow Diagrams

### Booking Creation Flow
```
User selects room → date → time slot → group in RoomDetailView
    ↓
BookingConfirmationView opens with summary
    ↓
Optional notes entered (validated max 200 chars)
    ↓
Taps "Confirm"
    ↓
Booking created → FirestoreService.addBooking(booking)
    ↓
Firestore saves document → NotificationManager schedules reminder
    ↓
BookingStore listener fires → UI updates everywhere
```

### Real-Time Sync
```
FirestoreService.listenToBookings { [weak self] bookings in
    self?.bookings = bookings    ← Published property on BookingStore
}

GroupStore.startListening(for: userID) → Firestore query scoped to user's groups
    ↓
@Published groups changes
    ↓
@ObservedObject/@EnvironmentObject in views triggers re-render
    ↓
UI updates automatically
```

### Auth Flow
```
App launch → AuthManager.restorePreviousSignIn()
    ↓
User taps Google Sign-In button
    ↓
GIDSignIn presents consent UI → returns GIDGoogleUser
    ↓
AuthManager configures dual identity:
    ├── Google UID → isLoggedIn = true (immediate)
    └── Firebase Auth.authenticate(with:) → isFirebaseAuthenticated = true
    ↓
User profile saved to Firestore → extendedProfile populated
```

---

## Key Design Decisions

### 1. **Single AuthManager with Dual Auth**
- One source of truth for user identity, injected via `@EnvironmentObject`
- Google UID provides immediate identity (`isLoggedIn`); Firebase Auth secures Firestore access (`isFirebaseAuthenticated`)
- If Firebase auth fails, the app still works with Google UID as fallback

### 2. **Codable for Firestore**
- All model structs are `Codable` — Firestore handles serialization automatically
- Optional fields (`notes`, `photoURL`, etc.) are backward compatible, requiring zero migration

### 3. **Validation Helpers as Pure Functions**
- No side effects, easy to test
- UI calls validation in `.onChange` and updates state reactively

### 4. **Firestore Listeners (not REST)**
- Real-time two-way sync without polling
- `.onAppear`/`.onDisappear` lifecycle keeps listeners clean

### 5. **UserStore Lazy Fetch Pattern**
- `usersByID` dictionary caches fetched profiles in memory
- `user(by:)` and `displayName(for:)` trigger lazy Firestore fetches on cache miss,
  returning a placeholder (`nil` / "Unknown User") until data arrives
- Deduplication via `fetchingUserIDs` set prevents parallel requests for the same UID

### 6. **In-Memory Stores + Firestore**
- Stores (`BookingStore`, `GroupStore`, `UserStore`) are `@StateObject` at the root and
  injected as `@EnvironmentObject` — no singleton accessors, no service locator

### 7. **Dark Mode via Dynamic Colors**
- Every theme color is defined as a `UIColor(dynamicProvider:)` pair (light hex + dark hex)
- `AppTheme.cardBackground` replaces hardcoded `Color.white` across all card backgrounds
- System colors (`.green`, `.red`) adapt automatically in SwiftUI
- No `@Environment(\.colorScheme)` branching needed — the trait collection handles switching

---

## Testing Strategy

### Unit Tests (Would test)
- `ValidationHelpers.validateBookingNotes(_:)` — Max 200 chars, whitespace trimming
- `String.nonEmpty` — Empty → `nil`, non-empty → string
- `HomeViewModel.zoomIn()` / `zoomOut()` — Span halved / doubled
- `HomeViewModel.clampRegion()` — Center constrained within bounds
- `GroupStore.myGroups(currentUserID:)` — Filtering by membership
- `AppUser.unknownUser` — Fallback user has empty ID

### Integration Tests (Would test)
- Firestore round-trip: Create → read → cancel booking
- Real-time sync: Create booking in one view, see update in another
- Auth flow: Sign in → profile loaded → sign out → state reset

---

## File Dependency Map

```
CU_Meet_projectApp
    ├── MainTabView
    │   ├── HomeView
    │   │   ├── UpcomingBookingCard
    │   │   ├── RoomMapView → HomeViewModel
    │   │   │   ├── RoomDetailSheet
    │   │   │   └── RoomFeatureCard
    │   │   ├── RoomDetailView
    │   │   │   └── BookingConfirmationView → Booking created
    │   │   ├── BookingDetailView
    │   │   │   ├── MemberRowView → MemberDetailView
    │   │   │   └── GroupStore lookup
    │   │   └── AllBookingsView
    │   ├── GroupsView → GroupCard → GroupDetailView
    │   │   ├── CreateGroupView
    │   │   ├── JoinGroupView
    │   │   └── BookingDetailView (shared)
    │   └── ProfileView
    │       ├── EditProfileView
    │       └── MemberDetailView
    │
    └── Services (injected as @EnvironmentObject)
        ├── AuthManager
        ├── FirestoreService (singleton)
        ├── BookingStore
        ├── GroupStore
        ├── UserStore
        └── NotificationManager (singleton)
```

---

## Future Enhancements

1. **Group admin roles** — Designate group owners who can remove members
2. **Push notifications** — Remote push for booking reminders instead of local only
3. **Image uploads** — User-customizable avatars beyond Google profile photo
4. **Room reviews** — Aggregate and display user-submitted reviews with comments

## Summary

CU Meet follows a layered architecture: **Services** handle backend integration, **Models** represent domain objects, **ViewModels** transform data for UI, **Views** render the interface. Data flows reactively through `@Published` properties and Firestore listeners, with environment-injected stores connecting every layer. The design prioritizes offline-friendly patterns (in-memory caching, local notifications) and backward-compatible data evolution through optional Codable fields.
