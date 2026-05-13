//
//  Group.swift
//  CU_Meet_project
//

import Foundation
import Combine
import FirebaseFirestore

struct Group: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let joinCode: String
    var memberIDs: [String]

    var memberCount: Int { memberIDs.count }
}

class GroupStore: ObservableObject {

    @Published var groups: [Group] = []
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    func startListening(for userID: String) {
        listener?.remove()
        guard !userID.isEmpty else {
            groups = []
            return
        }
        listener = FirestoreService.shared.listenToGroups(for: userID) { [weak self] groups in
            self?.groups = groups
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        groups = []
    }

    enum JoinResult {
        case success(Group)
        case alreadyMember(Group)
        case notFound
    }

    func createGroup(name: String, creatorID: String) async throws -> Group {
        let code = String(Int.random(in: 100000...999999))
        let group = Group(
            id: UUID().uuidString,
            name: name,
            joinCode: code,
            memberIDs: [creatorID]
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
        return .success(Group(id: group.id, name: group.name, joinCode: group.joinCode, memberIDs: updatedIDs))
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

    func groupName(for id: String) -> String {
        groups.first(where: { $0.id == id })?.name ?? "Unknown Group"
    }

    func myGroups(currentUserID: String?) -> [Group] {
        guard let currentUserID, !currentUserID.isEmpty else { return [] }
        return groups.filter { $0.memberIDs.contains(currentUserID) }
    }
}
