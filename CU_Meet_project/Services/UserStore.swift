//
//  UserStore.swift
//  CU_Meet_project
//
//  Created 2026-05-12 as part of the Firebase data model refactor.
//

import Foundation
import Combine

final class UserStore: ObservableObject {

    @Published private(set) var usersByID: [String: AppUser] = [:]

    init(seed: [AppUser] = AppUser.devSeed) {
        seed.forEach { upsert($0) }
    }

    func upsert(_ user: AppUser) {
        usersByID[user.id] = user
    }

    func displayName(for userID: String) -> String {
        usersByID[userID]?.displayName ?? "Unknown User"
    }
}
