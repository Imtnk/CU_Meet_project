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
    private var fetchingUserIDs: Set<String> = []

    init(seed: [AppUser] = AppUser.devSeed) {
        seed.forEach { upsert($0) }
    }

    func upsert(_ user: AppUser) {

        if let existing = usersByID[user.id] {

            usersByID[user.id] = AppUser(
                id: user.id,
                displayName: user.displayName,

                firstName: user.firstName ?? existing.firstName,
                lastName: user.lastName ?? existing.lastName,
                email: user.email ?? existing.email,
                photoURL: user.photoURL ?? existing.photoURL,

                nickname: user.nickname ?? existing.nickname,
                studentID: user.studentID ?? existing.studentID,
                birthdate: user.birthdate ?? existing.birthdate,
                mostActiveDay: user.mostActiveDay ?? existing.mostActiveDay,
                faculty: user.faculty ?? existing.faculty,
                year: user.year ?? existing.year
            )

        } else {

            usersByID[user.id] = user
        }
    }

    func displayName(for userID: String) -> String {

        if let user = usersByID[userID] {
            return user.displayName
        }

        // Start async fetch if needed
        if !fetchingUserIDs.contains(userID) {

            fetchingUserIDs.insert(userID)

            Task {
                do {
                    if let user = try await FirestoreService.shared.fetchUser(userID: userID) {

                        await MainActor.run {
                            self.upsert(user)
                        }
                    }
                } catch {
                    print("Failed to fetch user:", error)
                }

                await MainActor.run {
                    self.fetchingUserIDs.remove(userID)
                }
            }
        }

        // Use seeded fallback instead of generic "User"
        return AppUser.devSeed
            .first(where: { $0.id == userID })?
            .displayName
            ?? AppUser.fallbackUser(id: userID).displayName
    }

    func user(by userID: String) -> AppUser? {

        // Already loaded
        if let user = usersByID[userID] {
            return user
        }

        // IMPORTANT:
        // Return seeded mock user immediately
        if let mockUser =
            AppUser.devSeed.first(where: { $0.id == userID }) {

            return mockUser
        }

        // Fetch real Firestore user if needed
        if !fetchingUserIDs.contains(userID) {

            fetchingUserIDs.insert(userID)

            Task {

                do {

                    if let user =
                        try await FirestoreService.shared.fetchUser(userID: userID) {

                        await MainActor.run {
                            self.upsert(user)
                        }
                    }

                } catch {
                    print("Failed to fetch user:", error)
                }

                await MainActor.run {
                    self.fetchingUserIDs.remove(userID)
                }
            }
        }

        // Last fallback only
        return AppUser.fallbackUser(id: userID)
    }
}
