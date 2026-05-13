//
//  GroupDetailView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

struct GroupDetailView: View {
    let group: Group
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss

    @State private var showLeaveAlert = false
    @State private var errorMessage: String?

    private var currentGroup: Group? {
        groupStore.groups.first(where: { $0.id == group.id })
    }

    var body: some View {
        List {
            Section(header: Text("Group Info")) {
                HStack {
                    Text("Join Code")
                    Spacer()
                    Text(currentGroup?.joinCode ?? "")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                HStack {
                    Text("Total Members")
                    Spacer()
                    Text("\(currentGroup?.memberCount ?? 0)")
                }
            }

            Section(header: Text("Members")) {
                if let memberIDs = currentGroup?.memberIDs {
                    ForEach(memberIDs, id: \.self) { memberID in
                        Label(userStore.displayName(for: memberID), systemImage: "person.circle")
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showLeaveAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Leave Group")
                        Spacer()
                    }
                }
            }
            .alert("Leave Group?", isPresented: $showLeaveAlert) {
                Button("Leave", role: .destructive) {
                    Task {
                        do {
                            try await groupStore.leaveGroup(
                                groupID: group.id,
                                userID: authManager.currentUserID ?? ""
                            )
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You will be removed from this group.")
            }
        }
        .navigationTitle(currentGroup?.name ?? "Detail")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
