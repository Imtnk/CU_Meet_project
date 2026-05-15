//
//  Group.swift
//  CU_Meet_project
//

import Foundation
import Combine
import FirebaseFirestore

/// A named collection of users who can share room bookings.
struct Group: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    /// Short code members share to invite others.
    let joinCode: String
    /// Firebase UIDs of every member.
    var memberIDs: [String]
    /// The Firebase UID of the user who created the group; `nil` for legacy groups.
    let creatorID: String?

    var memberCount: Int { memberIDs.count }
}

/// Observable store that syncs the current user's groups from Firestore in real time.
class GroupStore: ObservableObject {

    @Published var groups: [Group] = []
    @Published var isLoading = false
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    /// Attaches a Firestore listener scoped to groups `userID` belongs to.
    func startListening(for userID: String) {
        listener?.remove()
        guard !userID.isEmpty else {
            groups = []
            isLoading = false
            return
        }
        isLoading = true
        listener = FirestoreService.shared.listenToGroups(for: userID) { [weak self] groups in
            self?.groups = groups
            self?.isLoading = false
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        groups = []
        isLoading = false
    }

    enum JoinResult {
        case success(Group)
        case alreadyMember(Group)
        case notFound
    }

    func createGroup(name: String, creatorID: String) async throws -> Group {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            throw AppError.invalidGroupName(reason: "cannot be empty")
        }

        guard trimmedName.count <= 100 else {
            throw AppError.invalidGroupName(reason: "must be 100 characters or less")
        }

        let code = try await FirestoreService.shared.generateUniqueJoinCode()
        let group = Group(
            id: UUID().uuidString,
            name: trimmedName,
            joinCode: code,
            memberIDs: [creatorID],
            creatorID: creatorID
        )
        try await FirestoreService.shared.createGroup(group)
        return group
    }

    func joinGroup(code: String, userID: String) async throws -> JoinResult {
        guard let group = try await FirestoreService.shared.fetchGroup(byJoinCode: code) else {
            return .notFound
        }
        if group.memberIDs.contains(userID) {
            return .alreadyMember(group)
        }
        let updatedIDs = group.memberIDs + [userID]
        try await FirestoreService.shared.updateGroupMembers(groupID: group.id, memberIDs: updatedIDs)
        return .success(Group(id: group.id, name: group.name, joinCode: group.joinCode, memberIDs: updatedIDs, creatorID: group.creatorID))
    }

    func leaveGroup(groupID: String, userID: String) async throws {
        guard let group = groups.first(where: { $0.id == groupID }) else { return }
        let remaining = group.memberIDs.filter { $0 != userID }
        if remaining.isEmpty {
            try await FirestoreService.shared.deleteGroup(id: groupID)
        } else {
            try await FirestoreService.shared.updateGroupMembers(groupID: groupID, memberIDs: remaining)
        }
    }

    func updateGroupName(id: String, name: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw AppError.invalidGroupName(reason: "cannot be empty") }
        guard trimmed.count <= 100 else { throw AppError.invalidGroupName(reason: "must be 100 characters or less") }
        try await FirestoreService.shared.updateGroupName(id: id, name: trimmed)
    }

    func deleteGroup(id: String) async throws {
        try await FirestoreService.shared.deleteGroup(id: id)
    }

    func groupName(for id: String) -> String {
        groups.first(where: { $0.id == id })?.name ?? "Unknown Group"
    }

    func myGroups(currentUserID: String?) -> [Group] {
        guard let currentUserID, !currentUserID.isEmpty else { return [] }
        return groups.filter { $0.memberIDs.contains(currentUserID) }
    }
}
