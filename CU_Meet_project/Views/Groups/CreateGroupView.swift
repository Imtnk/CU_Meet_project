//
//  CreateGroupView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

/// Sheet for creating a new group; reveals the generated join code on success.
struct CreateGroupView: View {

    /// Performs the group creation request.
    @EnvironmentObject var groupStore: GroupStore
    /// Supplies the creator's user ID.
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    /// Text entered by the user as the group name.
    @State private var groupName = ""
    /// Populated after a successful creation to show the join code.
    @State private var createdGroup: Group?
    /// True while the async create request is in-flight.
    @State private var isCreating = false
    /// Non-nil when group creation fails; drives the error alert.
    @State private var errorMessage: String?
    /// Shows a success toast after the group is created.
    @State private var showSuccessToast = false

    /// True when the trimmed name is non-empty and at most 100 characters.
    var isValidName: Bool {
        let trimmed = groupName.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 100
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Create Group")
                .font(.title)

            VStack(alignment: .leading, spacing: 8) {
                TextField("Group Name", text: $groupName)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text("\(groupName.count)/100")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if !isValidName && !groupName.isEmpty {
                        Text("Invalid name")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .padding()

            Button("Create") {
                isCreating = true
                Task {
                    do {
                        createdGroup = try await groupStore.createGroup(
                            name: groupName,
                            creatorID: authManager.currentUserID ?? ""
                        )
                        showSuccessToast = true
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    isCreating = false
                }
            }
            .disabled(!isValidName || isCreating)

            if let group = createdGroup {
                VStack(spacing: 10) {
                    Text("Group Created")
                        .font(.headline)
                    Text("Name: \(group.name)")
                    Text("Join Code: \(group.joinCode)")
                        .font(.title2)
                        .bold()
                    Button("Done") { dismiss() }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .toast(isPresented: $showSuccessToast, message: "Group Created!")
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
