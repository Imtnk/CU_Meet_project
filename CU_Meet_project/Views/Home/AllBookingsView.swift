//
//  AllBookingsView.swift
//  CU_Meet_project
//

import SwiftUI

struct AllBookingsView: View {

    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager

    @State private var selectedGroupID: String? = nil

    private var myGroups: [Group] {
        groupStore.myGroups(currentUserID: authManager.currentUserID)
    }

    private var filteredBookings: [Booking] {
        let myGroupIDs = Set(myGroups.map { $0.id })
        let base = bookingStore.upcomingBookings()
            .filter { myGroupIDs.contains($0.groupID) }
        guard let gid = selectedGroupID else { return base }
        return base.filter { $0.groupID == gid }
    }

    var body: some View {
        VStack(spacing: 0) {
            if myGroups.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All", isSelected: selectedGroupID == nil) {
                            selectedGroupID = nil
                        }
                        ForEach(myGroups) { group in
                            FilterChip(
                                label: group.name,
                                isSelected: selectedGroupID == group.id
                            ) {
                                selectedGroupID = selectedGroupID == group.id ? nil : group.id
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            }

            if filteredBookings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundColor(.mutedGray)
                    Text(selectedGroupID == nil ? "No upcoming bookings" : "No bookings for this group")
                        .font(.subheadline)
                        .foregroundColor(.mutedGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 80)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredBookings) { booking in
                            NavigationLink(destination: BookingDetailView(booking: booking)) {
                                UpcomingBookingCard(
                                    groupName: groupStore.groupName(for: booking.groupID),
                                    roomName: booking.roomName,
                                    timeSlot: booking.timeSlot,
                                    date: booking.date
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
        .navigationTitle("Upcoming Bookings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .charcoal)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.brandPink : Color(.systemGray5))
                .clipShape(Capsule())
        }
    }
}
