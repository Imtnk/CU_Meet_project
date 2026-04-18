//
//  AuthViewModel.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import Foundation
import GoogleSignIn
import Combine

class AuthViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var isLoggedIn: Bool = false
    
    func handleSignIn() {
        // Use the root view controller to present the login screen
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Log in failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user else { return }
            
            self.userName = user.profile?.name ?? "User"
            self.isLoggedIn = true
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isLoggedIn = false
        self.userName = ""
    }
}
