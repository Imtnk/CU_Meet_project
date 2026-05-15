//
//  GroupDetailView.swift
//  CU_Meet_project
//

import SwiftUI

struct GroupDetailView: View {
    let group: Group
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss

    @State private var showLeaveAlert = false
    @State private var isLeaving = false
    @State private var errorMessage: String?
    @State private var codeCopied = false
    @State private var selectedMember: AppUser?
    @State private var showMemberDetail = false

    private var currentGroup: Group? {
        groupStore.groups.first(where: { $0.id == group.id })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Header card — name, code, member count
                VStack(spacing: 0) {
                    // Pink banner
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandPinkDark, Color.brandPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.25))
                        )

                    VStack(alignment: .leading, spacing: 10) {
                        Text(currentGroup?.name ?? group.name)
                            .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)

                        HStack(spacing: 12) {
                            Label("\(currentGroup?.memberCount ?? group.memberCount) members",
                                  systemImage: "person.2.fill")
                                .font(.subheadline).foregroundColor(.mutedGray)

                            Spacer()

                            // Join code with copy
                            Button {
                                UIPasteboard.general.string = currentGroup?.joinCode ?? group.joinCode
                                codeCopied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { codeCopied = false }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                                        .font(.caption)
                                    Text(codeCopied ? "Copied!" : (currentGroup?.joinCode ?? group.joinCode))
                                        .font(.caption).fontWeight(.bold)
                                }
                                .foregroundColor(.brandPink)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.brandPinkLight)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 16)

                // Members section
                sectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Members")
                            .font(.headline).foregroundColor(.charcoal)

                        let memberIDs = currentGroup?.memberIDs ?? group.memberIDs
                        ForEach(memberIDs, id: \.self) { memberID in
                            MemberRowView(
                                memberID: memberID,
                                displayName: userStore.displayName(for: memberID),
                                isCurrentUser: memberID == authManager.currentUserID,
                                onTap: {
                                    selectedMember =
                                        userStore.user(by: memberID)
                                        ?? AppUser.fallbackUser(id: memberID)

                                    showMemberDetail = true
                                }
                            )
                        }
                    }
                }

                // Leave group button
                Button {
                    showLeaveAlert = true
                } label: {
                    HStack {
                        if isLeaving {
                            ProgressView().tint(.red)
                        } else {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Leave Group")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.red)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                            .stroke(Color.red.opacity(0.5), lineWidth: 1.5)
                    )
                }
                .disabled(isLeaving)
                .padding(.horizontal, 16)
                .padding(.top, 4)

                Spacer(minLength: 32)
            }
            .padding(.top, 16)
        }
        .background(Color.warmGray.ignoresSafeArea())
        .navigationTitle(currentGroup?.name ?? group.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMemberDetail) {
            if let member = selectedMember {
                MemberDetailView(memberID: member.id)
                    .environmentObject(userStore)
            }
        }
        .alert("Leave Group?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) {
                isLeaving = true
                Task {
                    do {
                        try await groupStore.leaveGroup(
                            groupID: group.id,
                            userID: authManager.currentUserID ?? ""
                        )
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                        isLeaving = false
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You will be removed from this group.")
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
    }
}
