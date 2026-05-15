//
//  MemberDetailView.swift
//  CU_Meet_project
//

import SwiftUI
import Foundation

/// Detail view for a group member, showing their Google account info, CU
/// profile fields, and personal details fetched from Firestore.
struct MemberDetailView: View {
    /// Firebase UID of the member to display.
    let memberID: String

    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    /// Whether a Firestore fetch for full member data is in progress.
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Avatar + name section
                    VStack(spacing: 12) {
                        AsyncImage(url: displayMember.photoURL.flatMap { URL(string: $0) }) { phase in
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

                        VStack(spacing: 4) {
                            Text(displayMember.displayName)
                                .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)
                            if let email = displayMember.email {
                                Text(email)
                                    .font(.caption).foregroundColor(.mutedGray)
                            }
                        }

                        if isLoading {
                            ProgressView()
                                .tint(.brandPink)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)

                    // Account section (always shown)
                    profileDetailsCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account")
                                .font(.headline).foregroundColor(.charcoal)

                            Divider()

                            if let firstName = displayMember.firstName {
                                profileRow(label: "First Name", value: firstName)
                            }
                            if let lastName = displayMember.lastName {
                                profileRow(label: "Last Name", value: lastName)
                            }
                            if let email = displayMember.email {
                                profileRow(label: "Email", value: email)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // CU Profile section
                    if hasCUProfileData {
                        profileDetailsCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("CU Profile")
                                    .font(.headline).foregroundColor(.charcoal)

                                Divider()

                                if let nickname = displayMember.nickname {
                                    profileRow(label: "Nickname", value: nickname)
                                }
                                if let studentID = displayMember.studentID {
                                    profileRow(label: "Student ID", value: studentID)
                                }
                                if let faculty = displayMember.faculty {
                                    profileRow(label: "Faculty", value: faculty)
                                }
                                if let year = displayMember.year {
                                    profileRow(label: "Year", value: year)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Personal section
                    if hasPersonalData {
                        profileDetailsCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Personal")
                                    .font(.headline).foregroundColor(.charcoal)

                                Divider()

                                if let birthdate = displayMember.birthdate {
                                    profileRow(label: "Birthdate", value: formatDate(birthdate))
                                }
                                if let mostActiveDay = displayMember.mostActiveDay {
                                    profileRow(label: "Most Active Day", value: mostActiveDay)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 16)
            }
            .background(Color.warmGray.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.brandPink)
                    }
                }
            }
            .task {
                await fetchFullMemberData()
            }
        }
    }

    /// The resolved `AppUser` for `memberID`, falling back to an unknown placeholder.
    private var displayMember: AppUser {
        userStore.user(by: memberID) ?? AppUser.unknownUser
    }

    /// Whether the member has any CU profile fields to display.
    private var hasCUProfileData: Bool {
        displayMember.nickname != nil || displayMember.studentID != nil ||
        displayMember.faculty != nil || displayMember.year != nil
    }

    /// Whether the member has any personal fields (birthdate, most active day) to display.
    private var hasPersonalData: Bool {
        displayMember.birthdate != nil || displayMember.mostActiveDay != nil
    }

    /// Fetches the full `AppUser` document from Firestore and upserts it into the store.
    private func fetchFullMemberData() async {

        isLoading = true

        defer {
            isLoading = false
        }

        do {

            if let fullUser =
                try await FirestoreService.shared.fetchUser(userID: memberID) {

                await MainActor.run {
                    userStore.upsert(fullUser)
                }
            }

        } catch {
            print("Failed to fetch member:", error)
        }
    }

    /// Reusable card wrapper with white background, rounded corners, and subtle shadow.
    @ViewBuilder
    private func profileDetailsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    /// Single info row: uppercase label above the value text.
    @ViewBuilder
    private func profileRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption).fontWeight(.semibold).foregroundColor(.mutedGray).textCase(.uppercase)
            Text(value)
                .font(.subheadline).foregroundColor(.charcoal)
        }
    }

    /// Formats a date using `.medium` style.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
