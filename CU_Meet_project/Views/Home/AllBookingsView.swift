//
//  AllBookingsView.swift
//  CU_Meet_project
//

import SwiftUI

/// Scrollable list of all upcoming bookings, filterable by group.
struct AllBookingsView: View {

    /// Source of upcoming booking data.
    @EnvironmentObject var bookingStore: BookingStore
    /// Provides group name lookup and membership.
    @EnvironmentObject var groupStore: GroupStore
    /// Identifies the current user for group scoping.
    @EnvironmentObject var authManager: AuthManager

    /// Group ID selected in the filter bar; nil shows all groups.
    @State private var selectedGroupID: String? = nil

    /// Groups the current user belongs to.
    private var myGroups: [Group] {
        groupStore.myGroups(currentUserID: authManager.currentUserID)
    }

    /// Upcoming bookings scoped to the user's groups, narrowed by `selectedGroupID` when set.
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

/// Pill-shaped toggle button used in the group filter bar.
private struct FilterChip: View {
    /// Text shown inside the chip.
    let label: String
    /// When true, renders with the brand-pink fill.
    let isSelected: Bool
    /// Called when the chip is tapped.
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
