//
//  AppUser.swift
//  CU_Meet_project
//
//  Created 2026-05-12 as part of the Firebase data model refactor.
//

import Foundation

/// Profile data for an authenticated app user.
struct AppUser: Identifiable, Codable, Equatable {
    /// Firebase UID.
    let id: String
    var displayName: String
    var firstName: String?
    var lastName: String?
    var email: String?
    /// Google CDN URL for the user's avatar image.
    var photoURL: String?

    var nickname: String?
    /// 10-digit student identifier.
    var studentID: String?
    var birthdate: Date?
    /// Day of the week the user is most active, e.g. `"Monday"`.
    var mostActiveDay: String?
    var faculty: String?
    /// Academic year label, e.g. `"Year 1"` through `"Year 4"` or `"Graduate"`.
    var year: String?
}

extension AppUser {
    /// Placeholder returned when a user ID cannot be resolved.
    static let unknownUser = AppUser(
        id: "",
        displayName: "Unknown User",
        firstName: nil,
        lastName: nil,
        email: nil,
        photoURL: nil,
        nickname: nil,
        studentID: nil,
        birthdate: nil,
        mostActiveDay: nil,
        faculty: nil,
        year: nil
    )
}
