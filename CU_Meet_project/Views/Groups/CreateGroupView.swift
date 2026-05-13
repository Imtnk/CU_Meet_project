//
//  CreateGroupView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

struct CreateGroupView: View {

    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var groupName = ""
    @State private var createdGroup: Group?
    @State private var isCreating = false
    @State private var errorMessage: String?

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
