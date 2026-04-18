//
//  GroupDetailView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI

struct GroupDetailView: View {
    let group: Group
    @EnvironmentObject var groupStore: GroupStore
    @Environment(\.dismiss) var dismiss
    
    @State private var showLeaveAlert = false
    
    private var currentGroup: Group? {
        groupStore.groups.first(where: { $0.id == group.id })
    }

    var body: some View {
        List {
            Section(header: Text("Group Info")) {
                HStack {
                    Text("Join Code")
                    Spacer()
                    Text(currentGroup?.joinCode ?? "")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Total Members")
                    Spacer()
                    Text("\(currentGroup?.memberCount ?? 0)")
                }
            }

            Section(header: Text("Members")) {
                if let members = currentGroup?.members {
                    ForEach(members, id: \.self) { member in
                        Label(member, systemImage: "person.circle")
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    groupStore.leaveGroup(groupID: group.id)
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text("Leave Group")
                        Spacer()
                    }
                }
            }
            .alert("Leave Group?", isPresented: $showLeaveAlert) {
                
                Button("Leave", role: .destructive) {
                    groupStore.leaveGroup(groupID: group.id)
                }
                
                Button("Cancel", role: .cancel) { }
                
            } message: {
                Text("You will be removed from this group.")
            }
        }
        .navigationTitle(currentGroup?.name ?? "Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
