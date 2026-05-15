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
    static let devSeed: [AppUser] = [
        AppUser(
            id: "u1",
            displayName: "Alice Johnson",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice@example.com",
            photoURL: nil,
            nickname: "AJ",
            studentID: "1234567890",
            birthdate: Date(timeIntervalSince1970: 924201600),
            mostActiveDay: "Monday",
            faculty: "Engineering",
            year: "Year 3"
        ),
        AppUser(
            id: "u2",
            displayName: "Bob Smith",
            firstName: "Bob",
            lastName: "Smith",
            email: "bob@example.com",
            photoURL: nil,
            nickname: "Bobby",
            studentID: "9876543210",
            birthdate: Date(timeIntervalSince1970: 950448000),
            mostActiveDay: "Wednesday",
            faculty: "Business",
            year: "Year 2"
        ),
        AppUser(
            id: "u3",
            displayName: "Carol Davis",
            firstName: "Carol",
            lastName: "Davis",
            email: "carol@example.com",
            photoURL: nil,
            nickname: "CD",
            studentID: "5555555555",
            birthdate: Date(timeIntervalSince1970: 975283200),
            mostActiveDay: "Friday",
            faculty: "Science",
            year: "Year 1"
        ),
        AppUser(
            id: "alice_uid",
            displayName: "Alice",
            firstName: "Alice",
            lastName: "Johnson",
            email: "alice@example.com",
            photoURL: nil,
            nickname: "AJ",
            studentID: "1234567890",
            birthdate: Date(timeIntervalSince1970: 924201600),
            mostActiveDay: "Monday",
            faculty: "Engineering",
            year: "Year 3"
        ),
        AppUser(
            id: "bob_uid",
            displayName: "Bob",
            firstName: "Bob",
            lastName: "Smith",
            email: "bob@example.com",
            photoURL: nil,
            nickname: "Bobby",
            studentID: "9876543210",
            birthdate: Date(timeIntervalSince1970: 950448000),
            mostActiveDay: "Wednesday",
            faculty: "Business",
            year: "Year 2"
        ),
    ]

    static func fallbackUser(id: String) -> AppUser {
        // Extract a meaningful name from the ID
        let displayName: String
        if id.contains("_") {
            // For IDs like "mock_user_alice" or "current_user_bob", extract the last part
            let parts = id.split(separator: "_")
            if let lastPart = parts.last {
                displayName = String(lastPart).capitalized
            } else {
                displayName = id
            }
        } else {
            displayName = id
        }

        return AppUser(
            id: id,
            displayName: displayName,
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
}
