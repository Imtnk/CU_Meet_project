//
//  ProfileView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

/// Profile screen showing the signed‑in user's avatar, Google account info,
/// editable CU profile fields, and a sign‑out button. When not logged in it
/// displays a welcome message and Google Sign‑In button.
struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    /// Whether the edit-profile sheet is presented.
    @State private var showEditProfile = false
    #if DEBUG
    @State private var seedAlert: String?
    #endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                        Text("Manage your account")
                            .font(.subheadline)
                            .foregroundColor(.mutedGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

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
                            .overlay(Circle().stroke(Color.brandPink, lineWidth: 3))
                            .shadow(color: .brandPink.opacity(0.3), radius: 8)

                            Text(authManager.userProfile?.profile?.name ?? "User Name")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.charcoal)

                            if let nickname = authManager.extendedProfile?.nickname, !nickname.isEmpty {
                                Text("\"\(nickname)\"")
                                    .font(.subheadline)
                                    .foregroundColor(.brandPink)
                            }

                            Text(authManager.userProfile?.profile?.email ?? "No Email")
                                .foregroundColor(.mutedGray)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .center)

                        if let profile = authManager.extendedProfile, hasDetails(profile) {
                            profileDetailsCard(profile)
                                .padding(.horizontal, 20)
                        }

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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if authManager.isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showEditProfile = true } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.brandPink)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .alert("Sign In Failed", isPresented: Binding(
                get: { authManager.signInError != nil },
                set: { if !$0 { authManager.signInError = nil } }
            )) {
                Button("OK") {}
            } message: {
                Text(authManager.signInError ?? "")
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
    }

    /// Whether the user has any non‑empty optional profile fields to display.
    private func hasDetails(_ p: AppUser) -> Bool {
        [p.studentID, p.faculty, p.year, p.mostActiveDay].contains(where: { $0?.isEmpty == false })
        || p.birthdate != nil
    }

    /// Card listing the user's optional CU profile and personal details.
    @ViewBuilder
    private func profileDetailsCard(_ p: AppUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let sid = p.studentID, !sid.isEmpty {
                profileRow(icon: "studentdesk", label: "Student ID", value: sid)
            }
            if let faculty = p.faculty, !faculty.isEmpty {
                profileRow(icon: "building.columns", label: "Faculty", value: faculty)
            }
            if let year = p.year, !year.isEmpty {
                profileRow(icon: "graduationcap", label: "Year", value: year)
            }
            if let day = p.mostActiveDay, !day.isEmpty {
                profileRow(icon: "calendar", label: "Most Active", value: day)
            }
            if let bd = p.birthdate {
                profileRow(icon: "gift", label: "Birthday", value: birthdayString(bd))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    /// Single row inside a details card: icon, label, and value.
    @ViewBuilder
    private func profileRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.brandPink)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.mutedGray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.charcoal)
        }
    }

    /// Formats a date as "dd MMM yyyy".
    private func birthdayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: date)
    }
}
