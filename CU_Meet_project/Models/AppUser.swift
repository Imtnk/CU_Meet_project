//
//  AppUser.swift
//  CU_Meet_project
//
//  Created 2026-05-12 as part of the Firebase data model refactor.
//

import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var photoURL: String?   // Google CDN URL

    // Optional profile fields (user-editable)
    var nickname: String?
    var studentID: String?      // 10-digit string
    var birthdate: Date?
    var mostActiveDay: String?  // "Monday"..."Sunday"
    var faculty: String?
    var year: String?           // "Year 1"..."Year 4", "Graduate"
}

extension AppUser {
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
