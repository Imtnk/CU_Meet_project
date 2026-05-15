# CU Meet — Feature Showcase

## Authentication

- Google Sign-In with Firebase Auth dual-path (Google UID immediate, Firebase Auth for Firestore security)
- Session restore on app launch
- Sign-out with one tap
- Signed-out state shows welcome screen with branded logo and sign-in prompt

## Room Discovery

- **Map view** with interactive `MKMapView` annotations, zoom-to-fit CU campus region
- **Search** rooms by name
- **Filter** by required facilities (projector, whiteboard, TV screen, AC, video conferencing, power outlets, Wi‑Fi) and minimum capacity
- **Zoom controls**: zoom in, zoom out, reset to default campus view
- **Recent rooms**: last three tapped rooms shown below the map
- **Room detail sheet**: image, name, rating, capacity, facility grid
- **Room detail page**: full info, rating submission, available time slots, group booking flow
- **Room feature cards**: hero-style cards with image overlay, name, capacity, rating pill
- **Star rating**: submit 1–5 star ratings per user; rating/review count updated via Firestore transaction

## Booking Management

- **Create booking**: select room → date → time slot → group → optional notes → confirm
- **Cancel booking**: upcoming bookings can be cancelled with a confirmation alert
- **Edit notes**: inline TextField with live 200‑char validation and character counter; Save/Cancel controls
- **Booking detail**: hero image, room info, date/time, group members list, notes card, cancel action
- **Upcoming bookings list** on home screen and in group detail
- **All bookings view**: filterable by group, scrollable list
- **Real-time sync**: Firestore listener updates all views automatically
- **Success toast**: "Booking Confirmed!" banner on creation

## Group Management

- **Create group**: name input with validation (1–100 chars), auto-generated 6‑digit join code
- **Join group**: enter 6‑digit code, success toast on join, alerts for duplicate/not-found
- **Leave group**: with confirmation alert
- **Delete group** (creator only): permanently deletes group and all associated bookings with confirmation alert
- **Edit group name** (creator only): inline TextField with validation and Save/Cancel
- **Member list**: tappable rows with display name, "You" badge for current user
- **Member detail**: view any member's profile (name, email, CU fields, personal info)
- **Copy join code**: tap to copy code to clipboard with checkmark feedback
- **Upcoming bookings per group**: filtered list with tappable rows to booking detail

## Profile

- **Google profile display**: avatar (AsyncImage with fallback), name, email
- **CU profile editing**: nickname, student ID (10‑digit validation), faculty, year of study, birthdate, most active day
- **Profile save toast**: "Profile Saved!" on successful update
- **Member detail view**: Account, CU Profile, and Personal sections; data fetched from Firestore on appear
- **Profile photo**: per‑member avatar via Google CDN URL with pink circle stroke and shadow

## User Experience

- **Dark mode**: all theme colors adapt automatically via `UIColor(dynamicProvider:)` based on OS Appearance setting
- **Success toasts**: pink capsule banners with slide-in animation for booking, profile, notes, group create, and group join actions
- **Real-time validation**: character counters, error messages, submit button disable logic on all forms
- **Pull-to-refresh**: on groups list
- **Splash screen**: branded pink launch overlay with logo, fades out after 1.8s
- **Consistent design system**: themed colors, corner radii, card shadows, button styles via `AppTheme`

## Notifications

- **Local booking reminders**: scheduled 15 minutes before each booking start time
- **Foreground presentation**: banners shown even when the app is in the foreground
- **Permission request**: alert/sound/badge authorization on first launch

## Data Architecture

- **Firestore real-time listeners**: bookings, groups, and user profiles sync without polling
- **In-memory caching**: `UserStore` caches `AppUser` objects, lazy-fetches on cache miss
- **Codable persistence**: all models are `Codable` — optional fields (`notes`, `photoURL`, `creatorID`) are backward compatible with zero migration
- **Batched deletes**: deleting a group atomically removes all its bookings in one Firestore batch write
- **Firestore security rules**: scoped by authentication, membership, and field-level constraints (see `firebaseRule.md`)

## Error Handling

- **Centralized `AppError`**: 10 domain-specific error cases with user-facing descriptions and recovery suggestions
- **Error alerts**: displayed consistently via `.alert` modifier
- **Validation helpers**: pure functions returning `(isValid, error?)` used across all input forms
