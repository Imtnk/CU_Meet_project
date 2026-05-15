//
//  GroupDetailView.swift
//  CU_Meet_project
//

import SwiftUI

/// Detail view for a single group showing members, join code, and leave action.
struct GroupDetailView: View {
    /// Group snapshot passed in at navigation time.
    let group: Group
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var bookingStore: BookingStore
    @Environment(\.dismiss) var dismiss

    /// Controls presentation of the leave-group confirmation alert.
    @State private var showLeaveAlert = false
    /// Controls presentation of the delete-group confirmation alert.
    @State private var showDeleteAlert = false
    /// True while the leave-group network call is in flight.
    @State private var isLeaving = false
    /// True while the delete-group network call is in flight.
    @State private var isDeleting = false
    /// Non-nil when a network call fails.
    @State private var errorMessage: String?
    /// True briefly after the join code is copied to the clipboard.
    @State private var codeCopied = false
    /// Member tapped to view their detail sheet.
    @State private var selectedMember: AppUser?
    /// Controls presentation of the MemberDetailView sheet.
    @State private var showMemberDetail = false
    /// Whether the group name inline editor is active.
    @State private var isEditingName = false
    /// Temporary buffer for the group name while editing.
    @State private var editedName: String = ""
    /// Validation error for the group name field.
    @State private var nameError: String?
    /// Shows a success toast after the group name is saved.
    @State private var showNameSavedToast = false

    /// Live version of the group from the store, falling back to the passed-in snapshot.
    private var currentGroup: Group? {
        groupStore.groups.first(where: { $0.id == group.id })
    }

    /// Upcoming bookings for this group, sorted by date then time.
    private var groupBookings: [Booking] {
        bookingStore.bookings
            .filter { $0.groupID == group.id && $0.status == .active && bookingStore.isUpcoming($0) }
            .sorted {
                if $0.date == $1.date { return $0.timeSlot < $1.timeSlot }
                return $0.date < $1.date
            }
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
                        HStack {
                            if isEditingName {
                                TextField("Group name", text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title2).fontWeight(.bold)
                                    .onChange(of: editedName) { _, val in
                                        let trimmed = val.trimmingCharacters(in: .whitespaces)
                                        if trimmed.isEmpty || trimmed.count > 100 {
                                            nameError = trimmed.isEmpty ? "Name cannot be empty" : "Max 100 characters"
                                        } else {
                                            nameError = nil
                                        }
                                    }
                            } else {
                                Text(currentGroup?.name ?? group.name)
                                    .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)
                            }

                            if let creatorID = currentGroup?.creatorID ?? group.creatorID,
                               creatorID == authManager.currentUserID && !isEditingName {
                                Button("Edit") {
                                    editedName = currentGroup?.name ?? group.name
                                    isEditingName = true
                                }
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(.brandPink)
                            }
                        }

                        if isEditingName {
                            HStack {
                                if let err = nameError {
                                    Text(err)
                                        .font(.caption).foregroundColor(.red)
                                }
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    isEditingName = false
                                    editedName = ""
                                    nameError = nil
                                }
                                .font(.subheadline).foregroundColor(.mutedGray)

                                Button("Save") {
                                    saveGroupName()
                                }
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.brandPink)
                                .disabled(nameError != nil)
                            }
                        }

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
                    .background(Color.cardBackground)
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
                                        ?? AppUser.unknownUser

                                    showMemberDetail = true
                                }
                            )
                        }
                    }
                }

                // Upcoming bookings section
                sectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upcoming Bookings")
                            .font(.headline).foregroundColor(.charcoal)

                        if groupBookings.isEmpty {
                            Text("No upcoming bookings")
                                .font(.subheadline).foregroundColor(.mutedGray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(groupBookings) { booking in
                                NavigationLink(destination: BookingDetailView(booking: booking)
                                    .environmentObject(bookingStore)
                                    .environmentObject(groupStore)
                                    .environmentObject(userStore)
                                    .environmentObject(authManager)
                                ) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(booking.roomName)
                                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.charcoal)
                                            Text(booking.timeSlot)
                                                .font(.caption).foregroundColor(.mutedGray)
                                        }
                                        Spacer()
                                        Text(formattedDate(booking.date))
                                            .font(.caption).fontWeight(.medium).foregroundColor(.brandPink)
                                        Image(systemName: "chevron.right")
                                            .font(.caption).foregroundColor(.mutedGray)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                                if booking.id != groupBookings.last?.id {
                                    Divider()
                                }
                            }
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

                // Delete group button (creator only)
                if let creatorID = currentGroup?.creatorID ?? group.creatorID,
                   creatorID == authManager.currentUserID {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            if isDeleting {
                                ProgressView().tint(.red)
                            } else {
                                Image(systemName: "trash")
                                Text("Delete Group")
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
                    .disabled(isDeleting)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

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
        .alert("Delete Group?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                isDeleting = true
                Task {
                    do {
                        try await groupStore.deleteGroup(id: group.id)
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                        isDeleting = false
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete the group and all its bookings. This cannot be undone.")
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
        .toast(isPresented: $showNameSavedToast, message: "Name Updated!")
    }

    /// Wraps content in a white rounded card with a soft drop shadow.
    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
    }

    /// Formats a date using `.medium` style.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Persists the edited group name to Firestore and exits edit mode.
    private func saveGroupName() {
        Task {
            do {
                try await groupStore.updateGroupName(id: group.id, name: editedName)
                await MainActor.run {
                    isEditingName = false
                    nameError = nil
                    showNameSavedToast = true
                }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
        }
    }
}
