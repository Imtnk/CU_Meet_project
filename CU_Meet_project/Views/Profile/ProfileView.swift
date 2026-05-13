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
    @EnvironmentObject private var authManager: AuthManager
    #if DEBUG
    @State private var seedAlert: String?
    #endif

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if authManager.isLoggedIn {
                    // --- Logged In State ---
                    VStack(spacing: 15) {
                        AsyncImage(url: authManager.userProfile?.profile?.imageURL(withDimension: 200)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                            case .empty, .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

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

                        #if DEBUG
//                        Button {
//                            Task {
//                                do {
//                                    try await FirestoreService.shared.seedMockData(
//                                        currentUserID: authManager.currentUserID ?? ""
//                                    )
//                                    seedAlert = "Mock data seeded successfully."
//                                } catch {
//                                    seedAlert = "Seed failed: \(error.localizedDescription)"
//                                }
//                            }
//                        } label: {
//                            Text("Seed Mock Data")
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.orange.opacity(0.15))
//                                .cornerRadius(10)
//                        }
//                        .alert("Seed Mock Data", isPresented: Binding(
//                            get: { seedAlert != nil },
//                            set: { if !$0 { seedAlert = nil } }
//                        )) {
//                            Button("OK") {}
//                        } message: {
//                            Text(seedAlert ?? "")
//                        }
                        #endif
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
            .alert("Sign In Failed", isPresented: Binding(
                get: { authManager.signInError != nil },
                set: { if !$0 { authManager.signInError = nil } }
            )) {
                Button("OK") {}
            } message: {
                Text(authManager.signInError ?? "")
            }
        }
    }
}
