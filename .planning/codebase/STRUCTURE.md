# Structure

**Analysis Date:** 2026-05-11

## Repository Layout

```
CU_Meet_project/                          ← repository root
├── CU-Meet-project-Info.plist            ← app Info.plist (bundle ID, GIDClientID, URL schemes)
├── README.md
├── .gitignore
│
├── CU_Meet_project.xcodeproj/            ← Xcode project
│   ├── project.pbxproj                   ← build settings, target membership, SPM dependencies
│   └── project.xcworkspace/
│       └── xcshareddata/
│           └── swiftpm/Package.resolved  ← SPM lockfile (GoogleSignIn + transitive deps)
│
└── CU_Meet_project/                      ← app source root (single target)
    ├── App/
    │   └── CU_Meet_projectApp.swift      ← @main entry point
    ├── Models/
    │   ├── BookingStore.swift            ← Booking struct + BookingStore ObservableObject
    │   ├── Group.swift                   ← Group struct + GroupStore ObservableObject
    │   ├── MeetingRoom.swift             ← MeetingRoom struct + global `rooms` array
    │   └── Facility.swift                ← Facility enum (room amenities)
    ├── ViewModels/
    │   └── HomeViewModel.swift           ← map camera region + zoom + pin sizing
    ├── Services/
    │   ├── AuthManager.swift             ← Google Sign-In wrapper (used by ProfileView)
    │   └── AuthViewModel.swift           ← Google Sign-In wrapper (used by LoginView)
    ├── Views/
    │   ├── MainTabView.swift             ← TabView root; Tab enum (home/groups/profile)
    │   ├── Home/
    │   │   ├── HomeView.swift            ← home feed + upcoming bookings list
    │   │   ├── RoomMapView.swift         ← MapKit map with room pins
    │   │   ├── RoomDetailView.swift      ← full room detail + slot picker
    │   │   ├── RoomDetailSheet.swift     ← condensed sheet variant of room detail
    │   │   └── BookingConfirmationView.swift  ← confirm and commit booking
    │   ├── Groups/
    │   │   ├── GroupsView.swift          ← list of joined groups
    │   │   ├── GroupDetailView.swift     ← group info + members + bookings
    │   │   ├── CreateGroupView.swift     ← create group + display generated join code
    │   │   ├── JoinGroupView.swift       ← join by code input
    │   │   └── BookingDetailView.swift   ← booking detail presented from group context
    │   └── Profile/
    │       ├── ProfileView.swift         ← signed-in profile display + sign-out
    │       └── LoginView.swift           ← Google Sign-In button + auth trigger
    └── Resources/
        └── Assets.xcassets/
            ├── AppIcon.appiconset/
            ├── AccentColor.colorset/
            ├── logo_meet.imageset/       ← app logo (logo_meet.jpg)
            └── meeting_room1.imageset/   ← placeholder room image (meeting_room1.jpg)
```

## Key Locations

| What | Where |
|------|-------|
| App entry point (`@main`) | `CU_Meet_project/App/CU_Meet_projectApp.swift` |
| Root navigation (TabView) | `CU_Meet_project/Views/MainTabView.swift` |
| Booking state (source of truth) | `CU_Meet_project/Models/BookingStore.swift` |
| Group state (source of truth) | `CU_Meet_project/Models/Group.swift` (`GroupStore` class) |
| Static room data | `CU_Meet_project/Models/MeetingRoom.swift` (global `rooms: [MeetingRoom]`) |
| Room amenity enum | `CU_Meet_project/Models/Facility.swift` |
| Map camera / zoom logic | `CU_Meet_project/ViewModels/HomeViewModel.swift` |
| Google Sign-In (profile tab) | `CU_Meet_project/Services/AuthManager.swift` |
| Google Sign-In (login view) | `CU_Meet_project/Services/AuthViewModel.swift` |
| OAuth client ID | `CU-Meet-project-Info.plist` key `GIDClientID`; also hardcoded in `CU_Meet_projectApp.swift` |
| SPM lockfile | `CU_Meet_project.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` |
| Image assets | `CU_Meet_project/Resources/Assets.xcassets/` |
| Planning / codebase docs | `.planning/codebase/` |

## Directory Conventions

### Feature grouping
Views are grouped by feature tab under `Views/`:
- `Views/Home/` — map, room detail, booking confirmation
- `Views/Groups/` — list, detail, create, join
- `Views/Profile/` — signed-in view and login view
- `Views/MainTabView.swift` — tab shell lives directly under `Views/`

### Layer separation

| Layer | Directory | Responsibility |
|-------|-----------|----------------|
| App | `App/` | Entry point; injects `@EnvironmentObject`s at root |
| Models | `Models/` | Value types, ObservableObject stores, static data |
| ViewModels | `ViewModels/` | View-specific presentation logic |
| Services | `Services/` | External integrations (Google Sign-In) |
| Views | `Views/` | SwiftUI views only — no business logic |
| Resources | `Resources/` | Assets, images |

### Co-location rule
A store `ObservableObject` lives in the same file as its primary model type:
- `Group` struct and `GroupStore` class → `Models/Group.swift`
- `Booking` struct and `BookingStore` class → `Models/BookingStore.swift`

## Naming Conventions

| Pattern | Suffix | Examples |
|---------|--------|---------|
| Views | `View` | `HomeView`, `GroupDetailView`, `BookingConfirmationView` |
| Stores | `Store` | `BookingStore`, `GroupStore` |
| ViewModels | `ViewModel` | `HomeViewModel`, `AuthViewModel` |
| Managers | `Manager` | `AuthManager` |
| Enums | noun | `Facility`, `Tab` |

### Boolean state (show-prefix for visibility toggles)
- `showCreateGroup`, `showJoinSheet`, `showDeleteAlert`, `showConfirmation`

## State Injection Pattern

`BookingStore` and `GroupStore` are instantiated once in `CU_Meet_projectApp` as `@StateObject` and injected app-wide as `@EnvironmentObject`. `HomeViewModel` is created per `RoomMapView` as `@StateObject`. Auth objects (`AuthManager`, `AuthViewModel`) are created locally in their respective views — auth state is not propagated globally.

---
*Mapped: 2026-05-11*
