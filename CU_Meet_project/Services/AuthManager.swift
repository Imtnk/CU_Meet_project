//
//  AuthManager.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import Foundation
import GoogleSignIn
import Combine
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userProfile: GIDGoogleUser?

    private let userStore: UserStore

    init(userStore: UserStore) {
        self.userStore = userStore
        restorePreviousSignIn()
    }

    func signIn() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                print("Sign in failed: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self?.userProfile = user
                self?.isLoggedIn = true
                self?.cacheCurrentUser(user)
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isLoggedIn = false
        self.userProfile = nil
    }

    private func restorePreviousSignIn() {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else { return }
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, _ in
            guard let self, let user else { return }
            self.userProfile = user
            self.isLoggedIn = true
            self.cacheCurrentUser(user)
        }
    }

    private func cacheCurrentUser(_ user: GIDGoogleUser) {
        let appUser = AppUser(
            id: user.userID ?? "",
            displayName: user.profile?.name ?? "",
            email: user.profile?.email,
            photoURL: user.profile?.imageURL(withDimension: 256)?.absoluteString
        )
        userStore.upsert(appUser)
        Task { try? await FirestoreService.shared.upsertUser(appUser) }
    }
}
