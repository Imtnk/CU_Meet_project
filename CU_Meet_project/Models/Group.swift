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
    let memberCount: Int
}

class GroupStore: ObservableObject {
    
    @Published var groups: [Group] = [
        Group(name: "AI Study Group", memberCount: 5),
        Group(name: "Project Team Alpha", memberCount: 3),
        Group(name: "UX Research Group", memberCount: 4)
    ]
    
    func groupName(for id: UUID) -> String {
        groups.first(where: { $0.id == id })?.name ?? "Unknown Group"
    }
}
