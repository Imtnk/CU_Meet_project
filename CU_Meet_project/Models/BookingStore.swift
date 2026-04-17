//
//  BookingStore.swift
//  CU_Meet_project
//
//  Created by Imtnk on 17/4/2569 BE.
//

import Foundation
import Combine

struct Booking: Identifiable, Equatable {
    let id = UUID()
    let roomID: UUID
    let roomName: String
    let groupID: UUID
    let date: Date
    let timeSlot: String
}

class BookingStore: ObservableObject {
    @Published var bookings: [Booking] = []
    
    func isBooked(roomID: UUID, date: Date, timeSlot: String) -> Bool {
        bookings.contains {
            $0.roomID == roomID &&
            Calendar.current.isDate($0.date, inSameDayAs: date) &&
            $0.timeSlot == timeSlot
        }
    }
    
    func addBooking(_ booking: Booking) {
        bookings.append(booking)
    }

    func upcomingBookings() -> [Booking] {
        bookings
            .filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
            .sorted {
                if Calendar.current.isDate($0.date, inSameDayAs: $1.date) {
                    return $0.timeSlot < $1.timeSlot
                }
                return $0.date < $1.date
            }
    }
}
