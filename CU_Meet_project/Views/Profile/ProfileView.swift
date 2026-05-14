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

                    VStack(spacing: 16) {
                        AsyncImage(url: authManager.userProfile?.profile?.imageURL(withDimension: 200)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                            case .empty, .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.mutedGray)
                            @unknown default:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.mutedGray)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.brandPink, lineWidth: 3)
                        )
                        .shadow(color: .brandPink.opacity(0.3), radius: 8)

                        Text(authManager.userProfile?.profile?.name ?? "User Name")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.charcoal)

                        Text(authManager.userProfile?.profile?.email ?? "No Email")
                            .foregroundColor(.mutedGray)

                        Button(role: .destructive) {
                            authManager.signOut()
                        } label: {
                            Text("Sign Out")
                                .fontWeight(.semibold)
                                .foregroundColor(.brandPink)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                                        .stroke(Color.brandPink, lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)

                } else {

                    Spacer()

                    Image("logo_meet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(color: .brandPink.opacity(0.3), radius: 10)

                    Text("Welcome to CU Meet")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.charcoal)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Sign in to manage your profile and groups")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.mutedGray)
                        .padding(.horizontal)

                    GoogleSignInButton(action: authManager.signIn)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 280, height: 45)
                        .padding()

                    Spacer()
                }
            }
            .background(Color.warmGray.ignoresSafeArea())
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
