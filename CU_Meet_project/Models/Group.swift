//
//  Group.swift
//  CU_Meet_project
//
//  Created by Imtnk on 17/4/2569 BE.
//

import Foundation
import Combine
import SwiftUI

struct Group: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let joinCode: String
    var memberIDs: [String]

    var memberCount: Int {
        memberIDs.count
    }
}

class GroupStore: ObservableObject {

    @Published var groups: [Group] = []

    init() {
        let mockGroup = Group(
            id: UUID().uuidString,
            name: "Test Group",
            joinCode: "123456",
            memberIDs: ["alice_uid", "bob_uid"]
        )

        groups.append(mockGroup)
    }

    func createGroup(name: String, creatorID: String) -> Group {
        let code = String(Int.random(in: 100000...999999))

        let group = Group(
            id: UUID().uuidString,
            name: name,
            joinCode: code,
            memberIDs: [creatorID]
        )

        groups.append(group)
        return group
    }

    enum JoinResult {
        case success(Group)
        case alreadyMember(Group)
        case notFound
    }

    func joinGroup(code: String, userID: String) -> JoinResult {

        guard let index = groups.firstIndex(where: { $0.joinCode == code }) else {
            return .notFound
        }

        if groups[index].memberIDs.contains(userID) {
            return .alreadyMember(groups[index])
        }

        groups[index].memberIDs.append(userID)
        return .success(groups[index])
    }

    func leaveGroup(groupID: String, userID: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupID }) else { return }

        groups[index].memberIDs.removeAll { $0 == userID }

        // remove group if empty
        if groups[index].memberIDs.isEmpty {
            groups.remove(at: index)
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
