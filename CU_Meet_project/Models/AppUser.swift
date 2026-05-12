//
//  AppUser.swift
//  CU_Meet_project
//
//  Created 2026-05-12 as part of the Firebase data model refactor.
//

import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String          // Google userID
    var displayName: String
    var email: String?
    var photoURL: String?   // Google CDN URL
}

extension AppUser {
    static let devSeed: [AppUser] = [
        AppUser(id: "alice_uid", displayName: "Alice", email: nil, photoURL: nil),
        AppUser(id: "bob_uid",   displayName: "Bob",   email: nil, photoURL: nil),
    ]
}
