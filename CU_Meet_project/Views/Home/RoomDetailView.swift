//
//  RoomDetailView.swift
//  CU_Meet_project
//

import SwiftUI

/// Detailed view of a single meeting room with facilities, rating, and booking flow.
struct RoomDetailView: View {

    /// Room whose details are being displayed.
    let room: MeetingRoom
    /// View model used to load room data and submit star ratings.
    @StateObject private var viewModel = HomeViewModel()

    /// Star count chosen by the current user (0 = no rating yet).
    @State private var userRating: Int = 0
    /// True while a rating write is in flight.
    @State private var isSubmittingRating = false
    /// Non-nil when a rating submission fails.
    @State private var ratingError: String?
    /// True briefly after a successful rating write to show confirmation text.
    @State private var ratingUpdated = false
    /// Running average rating updated optimistically after each submission.
    @State private var liveRating: Double = 0
    /// Running review count updated optimistically after each submission.
    @State private var liveReviewCount: Int = 0

    /// Date chosen by the user for their booking.
    @State private var selectedDate = Date()
    /// Time slot chosen by the user (nil when none is selected).
    @State private var selectedTime: String? = nil
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    /// Group the user has selected to attach to the booking.
    @State private var selectedGroupID: String? = nil
    /// Controls presentation of the BookingConfirmationView sheet.
    @State private var showConfirmationSheet = false
    @Environment(\.dismiss) var dismiss

    private let timeSlots = [
        "09:00 - 10:00", "10:00 - 11:00", "11:00 - 12:00",
        "13:00 - 14:00", "14:00 - 15:00", "15:00 - 16:00"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Hero image — full bleed
                Rectangle()
                    .fill(Color.brandPinkDark)
                    .overlay(
                        Image(room.imageAssetName).resizable().scaledToFill()
                    )
                    .frame(height: 260)

                VStack(alignment: .leading, spacing: 12) {

                    // Name / capacity / rating
                    sectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(room.name)
                                .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)
                            HStack(spacing: 16) {
                                Label("\(room.capacity) people", systemImage: "person.2.fill")
                                    .font(.subheadline).foregroundColor(.mutedGray)
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.brandPink).font(.caption)
                                    Text(String(format: "%.1f", liveRating))
                                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.charcoal)
                                    Text("(\(liveReviewCount) reviews)")
                                        .font(.subheadline).foregroundColor(.mutedGray)
                                }
                            }
                        }
                    }

                    // Facilities
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Facilities")
                                .font(.headline).foregroundColor(.charcoal)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Facility.allCases) { facility in
                                    let available = room.facilities.contains(facility)
                                    HStack(spacing: 6) {
                                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle")
                                            .foregroundColor(available ? .brandPink : .mutedGray)
                                        Text(facility.rawValue)
                                            .font(.caption).foregroundColor(available ? .charcoal : .mutedGray)
                                        Spacer()
                                    }
                                    .opacity(available ? 1 : 0.5)
                                }
                            }
                        }
                    }

                    // Rate this room
                    sectionCard {
                        VStack(spacing: 12) {
                            Text(ratingUpdated ? "Rating updated!" : "Rate This Room")
                                .font(.headline).foregroundColor(.charcoal)

                            HStack(spacing: 14) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= userRating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(.brandPink)
                                        .opacity(isSubmittingRating ? 0.5 : 1)
                                        .onTapGesture {
                                            guard !isSubmittingRating else { return }
                                            userRating = star
                                            isSubmittingRating = true
                                            Task {
                                                do {
                                                    guard let userID = authManager.currentUserID else {
                                                        ratingError = "You must be signed in to rate rooms."
                                                        return
                                                    }

                                                    guard let userID = authManager.currentUserID else {
                                                        ratingError = "You must be signed in to rate."
                                                        return
                                                    }

                                                    let (newRating, newCount) = try await viewModel.rateRoom(
                                                        roomID: room.id,
                                                        userID: userID,
                                                        stars: star
                                                    )
                                                    liveRating = newRating
                                                    liveReviewCount = newCount
                                                    ratingUpdated = true
                                                    try await Task.sleep(nanoseconds: 2_000_000_000)
                                                    ratingUpdated = false
                                                } catch {
                                                    ratingError = error.localizedDescription
                                                    userRating = 0
                                                }
                                                isSubmittingRating = false
                                            }
                                        }
                                }
                                if isSubmittingRating {
                                    ProgressView().tint(.brandPink)
                                }
                            }

                            if let err = ratingError {
                                Text(err)
                                    .font(.caption).foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Booking
                    sectionCard { bookingSection }

                    Spacer(minLength: 32)
                }
                .padding(.top, 12)
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            liveRating = room.rating
            liveReviewCount = room.reviewCount

            if let userID = authManager.currentUserID {
                userRating = room.userRatings?[userID] ?? 0
            }
        }
        .sheet(isPresented: $showConfirmationSheet) {
            if let time = selectedTime, let groupID = selectedGroupID {
                BookingConfirmationView(
                    room: room,
                    selectedDate: selectedDate,
                    selectedTime: time,
                    groupID: groupID,
                    onComplete: { dismiss() }
                )
                .environmentObject(bookingStore)
                .environmentObject(groupStore)
            }
        }
    }

    // MARK: - Section container helper
    /// Wraps content in a white rounded card with a soft drop shadow.
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

    // MARK: - Booking section
    /// Date picker, group picker, time-slot grid, and reserve button composed together.
    private var bookingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Book This Room")
                .font(.headline).foregroundColor(.charcoal)

            DatePicker("Select Date", selection: $selectedDate, in: Date.now..., displayedComponents: .date)
                .tint(.brandPink)

            groupPickerSection

            if let id = selectedGroupID {
                Text("Members: \(groupStore.myGroups(currentUserID: authManager.currentUserID).first(where: { $0.id == id })?.memberCount ?? 0)")
                    .font(.caption).foregroundColor(.mutedGray)
            }

            Text("Select Time Slot")
                .font(.subheadline).fontWeight(.medium).foregroundColor(.charcoal)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                ForEach(timeSlots, id: \.self) { slot in
                    let past = isPastSlot(slot, on: selectedDate)
                    let booked = isBooked(slot: slot)
                    let unavailable = past || booked
                    Button {
                        if !unavailable { selectedTime = slot }
                    } label: {
                        Text(slot)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                unavailable ? Color.mutedGray.opacity(0.15)
                                : (selectedTime == slot ? Color.brandPink : Color(.systemGray6))
                            )
                            .foregroundColor(
                                unavailable ? .mutedGray
                                : (selectedTime == slot ? .white : .charcoal)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.chipRadius))
                            .font(.subheadline)
                    }
                    .disabled(unavailable)
                }
            }

            Button {
                guard canProceed else { return }
                showConfirmationSheet = true
            } label: {
                Text("Reserve Room")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.brandPink : Color.mutedGray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
            .disabled(!canProceed)
        }
    }

    // MARK: - Group picker
    /// Drop-down menu for choosing which group to attach to this booking.
    private var groupPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Group")
                .font(.subheadline).fontWeight(.medium).foregroundColor(.charcoal)

            Menu {
                ForEach(groupStore.myGroups(currentUserID: authManager.currentUserID)) { group in
                    Button { selectedGroupID = group.id } label: { Text(group.name) }
                }
            } label: {
                HStack {
                    Text(selectedGroupName)
                        .foregroundColor(selectedGroupID == nil ? .mutedGray : .charcoal)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.mutedGray)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }

            if selectedGroupID == nil {
                Text("Required to continue booking")
                    .font(.caption).foregroundColor(.brandPink)
            }
            if groupStore.myGroups(currentUserID: authManager.currentUserID).isEmpty {
                Text("Join or create a group to book")
                    .font(.caption).foregroundColor(.brandPink)
            }
        }
    }

    // MARK: - Helpers
    /// Display name for the selected group, or a placeholder when nothing is chosen.
    private var selectedGroupName: String {
        guard let id = selectedGroupID else { return "Choose a group" }
        return groupStore.groupName(for: id)
    }

    /// Returns true when the given slot's start time has already passed on `date`.
    private func isPastSlot(_ slot: String, on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let startTimeString = slot.split(separator: "-").first else { return false }
        let trimmed = startTimeString.trimmingCharacters(in: .whitespaces)
        guard let slotTime = formatter.date(from: trimmed) else { return false }
        let calendar = Calendar.current
        let slotComponents = calendar.dateComponents([.hour, .minute], from: slotTime)
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        guard let hour = slotComponents.hour, let minute = slotComponents.minute,
              let year = selectedComponents.year, let month = selectedComponents.month,
              let day = selectedComponents.day else { return false }
        let combined = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? Date()
        return combined < Date()
    }

    /// Returns true when this slot is already booked for the selected room and date.
    private func isBooked(slot: String) -> Bool {
        bookingStore.isBooked(roomID: room.id, date: selectedDate, timeSlot: slot)
    }

    /// True when both a time slot and a group have been selected.
    private var canProceed: Bool { selectedTime != nil && selectedGroupID != nil }
}
