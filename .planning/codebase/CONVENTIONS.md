# Conventions

## Language & Runtime

- **Language:** Swift 5.x
- **UI Framework:** SwiftUI
- **Minimum Target:** iOS (project-specific version via Xcode settings)

## Naming Conventions

### Types
- PascalCase for all types: `struct`, `class`, `enum`, `protocol`
- Examples: `GroupDetailView`, `BookingStore`, `AuthViewModel`

### Methods & Properties
- camelCase for methods and properties
- Examples: `fetchGroups()`, `currentUser`, `isLoading`

### Boolean Properties
- `show`-prefix convention for visibility toggles
- Examples: `showCreateGroup`, `showJoinSheet`, `showDeleteAlert`

### Files
- Files are co-located with their primary type (model + store in same directory)
- View files end in `View` suffix: `HomeView.swift`, `GroupDetailView.swift`
- Store/ViewModel files end in `Store` or `ViewModel`: `BookingStore.swift`, `AuthViewModel.swift`

## Property Wrappers

| Wrapper | Usage |
|---------|-------|
| `@StateObject` | Owned observable objects (created by the view) |
| `@EnvironmentObject` | Shared objects passed down the view hierarchy |
| `@State` | Local view state (booleans, strings, simple values) |
| `@Published` | Observable properties inside `ObservableObject` classes |

## View Composition

- View bodies are decomposed into `private var` sub-sections for readability
- Complex views broken into smaller `private var someSection: some View` computed properties
- `#Preview` macro used for SwiftUI previews at bottom of each view file

## Error Handling

- `guard`/`if-let` patterns for optional unwrapping
- Async/await used for network calls
- Errors surfaced via `@Published` error state properties on stores

## Code Organization

- Views paired with their data store/viewmodel in the same feature directory
- Firebase calls encapsulated in store/service classes
- Views are thin — business logic lives in stores

---
*Mapped: 2026-05-11*
