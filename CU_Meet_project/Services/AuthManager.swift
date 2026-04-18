//
//  AuthManager.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import Foundation
import GoogleSignIn
import Combine

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userProfile: GIDGoogleUser?

    func signIn() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let user = result?.user {
                self.userProfile = user
                self.isLoggedIn = true
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isLoggedIn = false
        self.userProfile = nil
    }
}
