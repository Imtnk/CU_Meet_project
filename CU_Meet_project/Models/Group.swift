//
//  Group.swift
//  CU_Meet_project
//
//  Created by Imtnk on 17/4/2569 BE.
//

import Foundation
import Combine
import SwiftUI

struct Group: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let joinCode: String
    var members: [String]
    
    var memberCount: Int {
        members.count
    }
}

class GroupStore: ObservableObject {
    
    @Published var groups: [Group] = []
    
    init() {
        let mockGroup = Group(
            name: "Test Group",
            joinCode: "123456",
            members: ["Alice", "Bob"]
        )
        
        groups.append(mockGroup)
    }
    
    func createGroup(name: String) -> Group {
        let code = String(Int.random(in: 100000...999999))
        
        let group = Group(
            name: name,
            joinCode: code,
            members: ["You"]
        )
        
        groups.append(group)
        return group
    }
    
    enum JoinResult {
        case success(Group)
        case alreadyMember(Group)
        case notFound
    }
    
    func joinGroup(code: String, userName: String = "You") -> JoinResult {
        
        guard let index = groups.firstIndex(where: { $0.joinCode == code }) else {
            return .notFound
        }
        
        if groups[index].members.contains(userName) {
            return .alreadyMember(groups[index])
        }
        
        groups[index].members.append(userName)
        return .success(groups[index])
    }
    
    func leaveGroup(groupID: UUID, userName: String = "You") {
        guard let index = groups.firstIndex(where: { $0.id == groupID }) else { return }
        
        groups[index].members.removeAll { $0 == userName }
        
        // remove group if empty
        if groups[index].members.isEmpty {
            groups.remove(at: index)
        }
    }
    
    func groupName(for id: UUID) -> String {
        groups.first(where: { $0.id == id })?.name ?? "Unknown Group"
    }
    
    var myGroups: [Group] {
        groups.filter { $0.members.contains("You") }
    }
}
