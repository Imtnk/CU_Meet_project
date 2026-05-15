//
//  ValidationHelpers.swift
//  CU_Meet_project
//

import Foundation

extension String {
    /// Returns `nil` when the string is empty, otherwise returns the string itself.
    var nonEmpty: String? { isEmpty ? nil : self }
}

/// Namespace for stateless input validation functions used across the app.
enum ValidationHelpers {

    // MARK: - Group Validation

    /// Validates that `name` is non-empty and at most 100 characters.
    static func validateGroupName(_ name: String) -> (isValid: Bool, error: AppError?) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            return (false, .invalidGroupName(reason: "cannot be empty"))
        }

        if trimmed.count > 100 {
            return (false, .invalidGroupName(reason: "must be 100 characters or less"))
        }

        return (true, nil)
    }

    // MARK: - Join Code Validation

    /// Validates that `code` is exactly 6 decimal digits.
    static func validateJoinCode(_ code: String) -> (isValid: Bool, error: AppError?) {
        let trimmed = code.trimmingCharacters(in: .whitespaces)

        if trimmed.count != 6 {
            return (false, .invalidJoinCode)
        }

        if !trimmed.allSatisfy({ $0.isNumber }) {
            return (false, .invalidJoinCode)
        }

        return (true, nil)
    }

    // MARK: - Booking Validation

    /// Validates that `notes` does not exceed 200 characters after trimming whitespace.
    static func validateBookingNotes(_ notes: String) -> (isValid: Bool, error: String?) {
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 200 {
            return (false, "Notes must be 200 characters or less")
        }
        return (true, nil)
    }

    /// Validates that the start time of `timeSlot` on `date` is in the future.
    static func validateBookingDateTime(date: Date, timeSlot: String) -> (isValid: Bool, error: AppError?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let startTimeString = timeSlot.split(separator: "-").first else {
            return (false, .pastDateTime)
        }

        let trimmed = startTimeString.trimmingCharacters(in: .whitespaces)

        guard let slotTime = formatter.date(from: trimmed) else {
            return (false, .pastDateTime)
        }

        let calendar = Calendar.current
        let slotComponents = calendar.dateComponents([.hour, .minute], from: slotTime)
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)

        guard
            let hour = slotComponents.hour,
            let minute = slotComponents.minute,
            let year = selectedComponents.year,
            let month = selectedComponents.month,
            let day = selectedComponents.day
        else {
            return (false, .pastDateTime)
        }

        let combined = calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )) ?? Date()

        if combined < Date() {
            return (false, .pastDateTime)
        }

        return (true, nil)
    }
}
