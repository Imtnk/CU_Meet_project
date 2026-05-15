//
//  HomeView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import GoogleSignIn

/// Home screen showing a time-based greeting, room search, featured rooms carousel, and upcoming bookings.
struct HomeView: View {

    /// Provides booking data and loading state.
    @EnvironmentObject var bookingStore: BookingStore
    /// Provides the user's group memberships.
    @EnvironmentObject var groupStore: GroupStore
    /// Provides the signed-in user's identity and profile.
    @EnvironmentObject var authManager: AuthManager
    /// Loads and holds the list of rooms for the Explore section.
    @StateObject private var viewModel = HomeViewModel()
    /// Current page index in the auto-advancing featured rooms carousel.
    @State private var featureIndex = 0
    #if DEBUG
    /// Tracks whether a test notification was recently triggered, to briefly show a checkmark.
    @State private var testNotificationScheduled = false
    #endif

    /// The user's first given name, or "there" if unavailable.
    private var firstName: String {
        authManager.userProfile?.profile?.name
            .components(separatedBy: " ").first ?? "there"
    }

    /// Time-of-day greeting based on the current hour.
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    /// Upcoming bookings filtered to the user's groups, capped at two entries.
    private var upcomingBookings: [Booking] {
        let myGroupIDs = Set(
            groupStore.myGroups(currentUserID: authManager.currentUserID).map { $0.id }
        )
        return Array(
            bookingStore.upcomingBookings()
                .filter { myGroupIDs.contains($0.groupID) }
                .prefix(2)
        )
    }

    /// First five rooms shown in the Explore carousel.
    private var featureRooms: [MeetingRoom] {
        Array(viewModel.rooms.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(greeting), \(firstName)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                        Text("Where would you like to meet?")
                            .font(.subheadline)
                            .foregroundColor(.mutedGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Search bar (navigates to RoomMapView)
                    NavigationLink(destination: RoomMapView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.mutedGray)
                            Text("Search rooms…")
                                .foregroundColor(.mutedGray)
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    // Explore — rotating feature cards
                    if !featureRooms.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Explore")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                                .padding(.horizontal, 20)

                            TabView(selection: $featureIndex) {
                                ForEach(Array(featureRooms.enumerated()), id: \.offset) { index, room in
                                    NavigationLink(destination: RoomDetailView(room: room)) {
                                        RoomFeatureCard(room: room)
                                            .padding(.horizontal, 20)
                                    }
                                    .buttonStyle(.plain)
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .always))
                            .frame(height: 240)
                            .task {
                                while !Task.isCancelled {
                                    try? await Task.sleep(for: .seconds(5))
                                    guard !featureRooms.isEmpty else { continue }
                                    let isLastCard = featureIndex == featureRooms.count - 1
                                    if isLastCard {
                                        // Reset without animation to avoid jump effect
                                        featureIndex = 0
                                    } else {
                                        withAnimation(.easeInOut(duration: 1)) {
                                            featureIndex += 1
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Upcoming bookings
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Upcoming")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                            Spacer()
                            if !upcomingBookings.isEmpty {
                                NavigationLink(destination: AllBookingsView()) {
                                    Text("See all")
                                        .font(.subheadline)
                                        .foregroundColor(.brandPink)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        if bookingStore.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if upcomingBookings.isEmpty {
                            Text("No upcoming bookings")
                                .font(.subheadline)
                                .foregroundColor(.mutedGray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(upcomingBookings) { booking in
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
                        }
                    }

                    Spacer(minLength: 20)
                }
            }
            .background(Color.warmGray.ignoresSafeArea())
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadRooms() }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        NotificationManager.shared.scheduleTestReminder()
                        testNotificationScheduled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            testNotificationScheduled = false
                        }
                    } label: {
                        Image(systemName: testNotificationScheduled
                              ? "checkmark.circle.fill" : "bell.badge")
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    let userStore = UserStore()
    HomeView()
        .environmentObject(BookingStore())
        .environmentObject(GroupStore())
        .environmentObject(AuthManager(userStore: userStore))
}
