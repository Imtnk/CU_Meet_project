//
//  ProfileView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct ProfileView: View {
    // Access the global auth state
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authManager.isLoggedIn {
                    // --- Logged In State ---
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text(authManager.userProfile?.profile?.name ?? "User Name")
                            .font(.title2)
                            .bold()
                        
                        Text(authManager.userProfile?.profile?.email ?? "No Email")
                            .foregroundColor(.secondary)
                        
                        Button(role: .destructive) {
                            authManager.signOut()
                        } label: {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                } else {
                    // --- Signed Out State (Login Page) ---
                    Spacer()
                    
                    Image(systemName: "shield.lefthalf.filled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .foregroundColor(.blue)
                    
                    Text("Join CU Meet")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Sign in to manage your profile and groups")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    GoogleSignInButton(action: authManager.signIn)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 280, height: 45)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
        }
    }
}
