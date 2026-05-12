//
//  GroupDetailView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI
import GoogleSignIn

struct GroupDetailView: View {
    let group: Group
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userStore: UserStore
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
                if let memberIDs = currentGroup?.memberIDs {
                    ForEach(memberIDs, id: \.self) { memberID in
                        Label(userStore.displayName(for: memberID), systemImage: "person.circle")
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    groupStore.leaveGroup(groupID: group.id, userID: authManager.userProfile?.userID ?? "")
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
                    groupStore.leaveGroup(groupID: group.id, userID: authManager.userProfile?.userID ?? "")
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
