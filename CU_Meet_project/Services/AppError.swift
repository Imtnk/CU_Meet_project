//
//  AppError.swift
//  CU_Meet_project
//

import Foundation

enum AppError: LocalizedError {
    case invalidGroupName(reason: String)
    case invalidJoinCode
    case groupNotFound
    case alreadyMember
    case uniqueCodeGenerationFailed
    case bookingConflict
    case pastDateTime
    case authRequired
    case networkError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidGroupName(let reason):
            return "Invalid group name: \(reason)"
        case .invalidJoinCode:
            return "Join code must be exactly 6 digits"
        case .groupNotFound:
            return "Group not found. Please check the code."
        case .alreadyMember:
            return "You're already a member of this group"
        case .uniqueCodeGenerationFailed:
            return "Failed to generate a unique code. Please try again."
        case .bookingConflict:
            return "This room is already booked for that time"
        case .pastDateTime:
            return "Cannot book a room for a past date or time"
        case .authRequired:
            return "Please sign in to perform this action"
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidGroupName:
            return "Group names should be 1-100 characters"
        case .invalidJoinCode:
            return "Make sure you enter exactly 6 digits"
        case .groupNotFound:
            return "Ask the group creator for the correct code"
        case .alreadyMember:
            return "Go to the Groups tab to view your groups"
        case .uniqueCodeGenerationFailed:
            return "This is rare. Try creating the group again."
        case .bookingConflict:
            return "Choose a different time slot"
        case .pastDateTime:
            return "Select a future date and time"
        case .authRequired:
            return "Go to the Profile tab to sign in"
        case .networkError:
            return "Check your internet connection and try again"
        case .unknown:
            return nil
        }
    }
}
