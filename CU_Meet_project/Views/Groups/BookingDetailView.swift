//
//  BookingDetailView.swift
//  CU_Meet_project
//

import SwiftUI

struct BookingDetailView: View {

    let booking: Booking

    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var showCancelAlert = false
    @State private var errorMessage: String?

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
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(Color.brandPinkLight)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.caption).foregroundColor(.brandPink)
                                            )
                                        Text(userStore.displayName(for: memberID))
                                            .font(.subheadline).foregroundColor(.charcoal)
                                    }
                                }
                            } else {
                                Text("Group not found")
                                    .font(.subheadline).foregroundColor(.mutedGray)
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
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var currentGroup: Group? {
        groupStore.groups.first { $0.id == booking.groupID }
    }
}
