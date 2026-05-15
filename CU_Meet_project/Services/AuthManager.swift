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
    /// Full profile including optional fields loaded from Firestore.
    @Published var extendedProfile: AppUser?

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
        self.extendedProfile = nil
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
        let baseUser = AppUser(
            id: firebaseUID,
            displayName: user.profile?.name ?? "",
            firstName: user.profile?.givenName,
            lastName: user.profile?.familyName,
            email: user.profile?.email,
            photoURL: user.profile?.imageURL(withDimension: 256)?.absoluteString
        )
        userStore.upsert(baseUser)
        Task {
            try? await FirestoreService.shared.upsertUser(baseUser)
            await fetchAndMergeExtendedProfile(base: baseUser)
        }
    }

    private func fetchAndMergeExtendedProfile(base: AppUser) async {
        let stored = try? await FirestoreService.shared.fetchUser(userID: base.id)
        var merged = base
        if let stored {
            merged.nickname = stored.nickname
            merged.studentID = stored.studentID
            merged.birthdate = stored.birthdate
            merged.mostActiveDay = stored.mostActiveDay
            merged.faculty = stored.faculty
            merged.year = stored.year
        }
        await MainActor.run { extendedProfile = merged }
    }

    func saveProfile(
        nickname: String?,
        studentID: String?,
        birthdate: Date?,
        mostActiveDay: String?,
        faculty: String?,
        year: String?
    ) async throws {
        guard let userID = currentUserID else { return }

        let trimNickname  = nickname?.trimmingCharacters(in: .whitespaces).nonEmpty
        let trimStudentID = studentID?.trimmingCharacters(in: .whitespaces).nonEmpty
        let trimFaculty   = faculty?.trimmingCharacters(in: .whitespaces).nonEmpty

        var fields: [String: Any] = [:]
        fields["nickname"]      = trimNickname    as Any? ?? FieldValue.delete()
        fields["studentID"]     = trimStudentID   as Any? ?? FieldValue.delete()
        fields["birthdate"]     = birthdate       as Any? ?? FieldValue.delete()
        fields["mostActiveDay"] = mostActiveDay   as Any? ?? FieldValue.delete()
        fields["faculty"]       = trimFaculty     as Any? ?? FieldValue.delete()
        fields["year"]          = year            as Any? ?? FieldValue.delete()

        try await FirestoreService.shared.updateUserFields(userID: userID, fields: fields)

        await MainActor.run {
            extendedProfile?.nickname      = trimNickname
            extendedProfile?.studentID     = trimStudentID
            extendedProfile?.birthdate     = birthdate
            extendedProfile?.mostActiveDay = mostActiveDay
            extendedProfile?.faculty       = trimFaculty
            extendedProfile?.year          = year
        }
    }
}
