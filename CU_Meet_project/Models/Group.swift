//
//  Group.swift
//  CU_Meet_project
//
//  Created by Imtnk on 17/4/2569 BE.
//

import Foundation
import Combine

struct Group: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let members: [String]
    
    var memberCount: Int {
        members.count
    }
}

class GroupStore: ObservableObject {
    
    @Published var groups: [Group] = [
        Group(name: "AI Study Group", members: ["Alice", "Bob", "Charlie"]),
        Group(name: "Project Team Alpha", members: ["John", "Emma"]),
        Group(name: "UX Research Group", members: ["Mike", "Sarah", "Tom"])
    ]
    
    func group(for id: UUID) -> Group? {
        groups.first(where: { $0.id == id })
    }
    
    func groupName(for id: UUID) -> String {
        group(for: id)?.name ?? "Unknown Group"
    }
}
