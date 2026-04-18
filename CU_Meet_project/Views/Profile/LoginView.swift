//
//  LoginView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if authViewModel.isLoggedIn {
                Text("Welcome, \(authViewModel.userName)!")
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("CU Meet Project")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Google's official SwiftUI button
                GoogleSignInButton(action: authViewModel.handleSignIn)
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 280, height: 45)
            }
        }
        .padding()
        .onAppear {
            // Check if user is already signed in
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let user = user {
                        self.authViewModel.userName = user.profile?.name ?? "User"
                        self.authViewModel.isLoggedIn = true
                    }
                }
            }
        }
    }
}
