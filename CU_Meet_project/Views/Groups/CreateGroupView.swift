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
        VStack(spacing: 16) {

            Text("Create Group")
                .font(.title2).fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 6) {
                TextField("Group Name", text: $groupName)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text("\(groupName.count)/100")
                        .font(.caption)
                        .foregroundColor(.mutedGray)

                    if !isValidName && !groupName.isEmpty {
                        Text("Name must be 1–100 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .padding(14)
//            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .padding(.horizontal, 20)

            Button(action: {
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
            }) {
                Text(isCreating ? "Creating…" : "Create")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(isCreating || !isValidName ? Color.brandPink.opacity(0.4) : Color.brandPink)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
            .disabled(!isValidName || isCreating)
            .padding(.horizontal, 20)

            if let group = createdGroup {
                VStack(spacing: 8) {
                    Text("Group Created")
                        .font(.headline).foregroundColor(.charcoal)
                    Text("Name: \(group.name)")
                        .font(.subheadline).foregroundColor(.mutedGray)
                    Text(group.joinCode)
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(.brandPink)
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPink)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.warmGray.ignoresSafeArea())
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
