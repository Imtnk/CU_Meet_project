# Testing

## Status

**No formal test suite exists in this project.**

No XCTest targets, test files, or test framework configuration are present.

## Current Verification

- `#Preview` macro blocks in SwiftUI views provide visual verification during development
  - `MainTabView.swift`
  - `HomeView.swift`
  - `RoomMapView.swift`

## Implications for Development

- All feature verification is manual (run app, test in simulator/device)
- No regression protection — changes can silently break existing functionality
- UI previews are the only automated visual check

## Recommended Future Setup

- XCTest for unit testing stores/viewmodels
- Swift Testing framework (Swift 5.9+) as modern alternative to XCTest
- UI tests via XCUITest for critical user flows (booking, auth)

---
*Mapped: 2026-05-11*
