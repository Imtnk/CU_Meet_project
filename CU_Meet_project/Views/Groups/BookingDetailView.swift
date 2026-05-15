//
//  BookingDetailView.swift
//  CU_Meet_project
//

import SwiftUI

/// Full‑screen detail view for a single booking: hero image, room info,
/// group member list, notes, and cancel action.
struct BookingDetailView: View {

    /// The booking to display.
    let booking: Booking

    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showCancelAlert = false
    @State private var errorMessage: String?
    @State private var selectedMember: AppUser?
    @State private var showMemberDetail = false
    /// Whether the notes inline editor is active.
    @State private var isEditingNotes = false
    /// Temporary buffer for the notes text while editing.
    @State private var editedNotes: String = ""
    /// Validation error from the notes text field.
    @State private var notesError: String?
    /// Shows a success toast after notes are saved.
    @State private var showNotesToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Hero image — full bleed
                Rectangle()
                    .fill(Color.brandPinkDark)
                    .overlay(
                        Image(booking.imageAssetName ?? "meeting_room1")
                            .resizable().scaledToFill()
                    )
                    .frame(height: 240)

                VStack(alignment: .leading, spacing: 12) {

                    // Room + time/date
                    sectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(booking.roomName)
                                .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)

                            HStack(spacing: 16) {
                                Label(booking.timeSlot, systemImage: "clock.fill")
                                    .font(.subheadline).foregroundColor(.brandPink)
                                Label(formattedDate(booking.date), systemImage: "calendar")
                                    .font(.subheadline).foregroundColor(.mutedGray)
                            }
                        }
                    }

                    // Group + members
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group")
                                .font(.headline).foregroundColor(.charcoal)

                            if let group = currentGroup {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(group.name)
                                            .font(.subheadline).fontWeight(.semibold).foregroundColor(.charcoal)
                                        Text("\(group.memberCount) members")
                                            .font(.caption).foregroundColor(.mutedGray)
                                    }
                                    Spacer()
                                    Text(group.joinCode)
                                        .font(.caption).fontWeight(.bold)
                                        .foregroundColor(.brandPink)
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(Color.brandPinkLight)
                                        .clipShape(Capsule())
                                }

                                Divider()

                                Text("Members")
                                    .font(.subheadline).fontWeight(.medium).foregroundColor(.charcoal)

                                ForEach(group.memberIDs, id: \.self) { memberID in
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
                            } else {
                                Text("Group not found")
                                    .font(.subheadline).foregroundColor(.mutedGray)
                            }
                        }
                    }

                    // Notes section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Notes")
                                    .font(.headline).foregroundColor(.charcoal)
                                Spacer()
                                if bookingStore.isUpcoming(booking) && !isEditingNotes && booking.creatorID == authManager.currentUserID {
                                    Button("Edit") {
                                        editedNotes = booking.notes ?? ""
                                        isEditingNotes = true
                                    }
                                    .font(.caption).fontWeight(.semibold)
                                    .foregroundColor(.brandPink)
                                }
                            }

                            if isEditingNotes {
                                TextField("Agenda / notes", text: $editedNotes, axis: .vertical)
                                    .lineLimit(3...6)
                                    .padding(10)
                                    .background(Color.mutedGray.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onChange(of: editedNotes) { _, val in
                                        let result = ValidationHelpers.validateBookingNotes(val)
                                        notesError = result.isValid ? nil : result.error
                                    }

                                HStack {
                                    if let err = notesError {
                                        Text(err)
                                            .font(.caption).foregroundColor(.red)
                                    }
                                    Spacer()
                                    Text("\(editedNotes.trimmingCharacters(in: .whitespacesAndNewlines).count)/200")
                                        .font(.caption)
                                        .foregroundColor(notesError != nil ? .red : .mutedGray)
                                }

                                HStack(spacing: 12) {
                                    Button("Cancel") {
                                        isEditingNotes = false
                                        editedNotes = ""
                                        notesError = nil
                                    }
                                    .font(.subheadline).foregroundColor(.mutedGray)

                                    Button("Save") {
                                        saveNotes()
                                    }
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.brandPink)
                                    .disabled(notesError != nil)
                                }
                            } else if let notes = booking.notes {
                                Text(notes)
                                    .font(.subheadline).foregroundColor(.mutedGray)
                            } else {
                                Text("No notes")
                                    .font(.subheadline).foregroundColor(.mutedGray.opacity(0.6))
                                    .italic()
                            }
                        }
                    }

                    // Cancel button (only for upcoming bookings)
                    if bookingStore.isUpcoming(booking) {
                        Button {
                            showCancelAlert = true
                        } label: {
                            Text("Cancel Booking")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.red)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.buttonRadius)
                                        .stroke(Color.red.opacity(0.6), lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 12)
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
        .toast(isPresented: $showNotesToast, message: "Notes Saved!")
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMemberDetail) {
            if let member = selectedMember {
                MemberDetailView(memberID: member.id)
                    .environmentObject(userStore)
            }
        }
        .alert("Cancel Booking?", isPresented: $showCancelAlert) {
            Button("Cancel Booking", role: .destructive) {
                Task {
                    do {
                        try await bookingStore.cancelBooking(booking)
                        NotificationManager.shared.cancelReminder(for: booking.id)
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            Button("Keep", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
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

    /// Reusable card wrapper with white background, rounded corners, and subtle shadow.
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

    /// The group associated with this booking, if available in the store.
    private var currentGroup: Group? {
        groupStore.groups.first { $0.id == booking.groupID }
    }

    /// Persists the edited notes to Firestore and exits edit mode.
    private func saveNotes() {
        let trimmed = editedNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesToSave = trimmed.isEmpty ? nil : trimmed
        Task {
            do {
                try await bookingStore.updateNotes(bookingID: booking.id, notes: notesToSave)
                await MainActor.run {
                    isEditingNotes = false
                    notesError = nil
                    showNotesToast = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
