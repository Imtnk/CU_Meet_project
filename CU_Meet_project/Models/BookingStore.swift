//
//  BookingStore.swift
//  CU_Meet_project
//

import Foundation
import Combine
import FirebaseFirestore

enum BookingStatus: String, Codable {
    case active
    case cancelled
}

struct Booking: Identifiable, Codable, Equatable {
    let id: String
    let roomID: String
    let roomName: String
    let groupID: String
    let date: Date
    let timeSlot: String
    var status: BookingStatus = .active
    let imageAssetName: String?
}

class BookingStore: ObservableObject {

    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    func startListening() {
        listener?.remove()
        isLoading = true
        listener = FirestoreService.shared.listenToBookings { [weak self] bookings in
            self?.bookings = bookings
            self?.isLoading = false
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        bookings = []
        isLoading = false
    }

    func isBooked(roomID: String, date: Date, timeSlot: String) -> Bool {
        bookings.contains {
            $0.roomID == roomID &&
            Calendar.current.isDate($0.date, inSameDayAs: date) &&
            $0.timeSlot == timeSlot &&
            $0.status == .active
        }
    }

    func addBooking(_ booking: Booking) async throws {
        try await FirestoreService.shared.addBooking(booking)
    }

    func cancelBooking(_ booking: Booking) async throws {
        try await FirestoreService.shared.updateBookingStatus(id: booking.id, status: .cancelled)
    }

    func upcomingBookings() -> [Booking] {
        let now = Date()
        return bookings
            .filter { $0.status == .active && endDateTime(for: $0) > now }
            .sorted {
                if Calendar.current.isDate($0.date, inSameDayAs: $1.date) {
                    return $0.timeSlot < $1.timeSlot
                }
                return $0.date < $1.date
            }
    }

    func isUpcoming(_ booking: Booking) -> Bool {
        endDateTime(for: booking) > Date()
    }

    // Parses the end time from a "HH:mm - HH:mm" timeSlot and combines it with the booking date.
    private func endDateTime(for booking: Booking) -> Date {
        let parts = booking.timeSlot.components(separatedBy: " - ")
        guard let endPart = parts.last,
              parts.count == 2 else { return booking.date }
        let timeParts = endPart.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else { return booking.date }
        return Calendar.current.date(
            bySettingHour: hour, minute: minute, second: 0, of: booking.date
        ) ?? booking.date
    }
}
