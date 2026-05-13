//
//  AuthManager.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userProfile: GIDGoogleUser?
    @Published var currentUserID: String?
    /// True only when Firebase Auth established a real session (not the Google-UID fallback).
    @Published var isFirebaseAuthenticated: Bool = false
    @Published var signInError: String?

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
                DispatchQueue.main.async { self?.signInError = error.localizedDescription }
                return
            }
            guard let self, let user = result?.user else { return }
            self.authenticateWithFirebase(googleUser: user) { [weak self] firebaseUID, didFirebaseSucceed in
                guard let self else { return }
                self.userProfile = user
                self.currentUserID = firebaseUID
                self.isFirebaseAuthenticated = didFirebaseSucceed
                self.isLoggedIn = true
                self.cacheCurrentUser(user, firebaseUID: firebaseUID)
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
        self.isLoggedIn = false
        self.userProfile = nil
        self.currentUserID = nil
        self.isFirebaseAuthenticated = false
    }

    private func restorePreviousSignIn() {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else { return }
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, _ in
            guard let self, let user else { return }
            self.authenticateWithFirebase(googleUser: user) { [weak self] firebaseUID, didFirebaseSucceed in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.userProfile = user
                    self.currentUserID = firebaseUID
                    self.isFirebaseAuthenticated = didFirebaseSucceed
                    self.isLoggedIn = true
                    self.cacheCurrentUser(user, firebaseUID: firebaseUID)
                }
            }
        }
    }

    // Exchanges Google tokens for a Firebase Auth session. Falls back to
    // Google userID if Firebase sign-in fails so the app stays functional.
    // completion receives (uid, didFirebaseSucceed).
    private func authenticateWithFirebase(googleUser: GIDGoogleUser,
                                          completion: @escaping (String, Bool) -> Void) {
        googleUser.refreshTokensIfNeeded { user, error in
            guard let user, error == nil, let idToken = user.idToken?.tokenString else {
                completion(googleUser.userID ?? "", false)
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    print("Firebase Auth failed: \(error.localizedDescription)")
                    completion(googleUser.userID ?? "", false)
                } else {
                    completion(result!.user.uid, true)
                }
            }
        }
    }

    private func cacheCurrentUser(_ user: GIDGoogleUser, firebaseUID: String) {
        let appUser = AppUser(
            id: firebaseUID,
            displayName: user.profile?.name ?? "",
            email: user.profile?.email,
            photoURL: user.profile?.imageURL(withDimension: 256)?.absoluteString
        )
        userStore.upsert(appUser)
        Task { try? await FirestoreService.shared.upsertUser(appUser) }
    }
}
