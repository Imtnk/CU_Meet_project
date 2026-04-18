//
//  GroupsView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct GroupsView: View {
    
    @EnvironmentObject var groupStore: GroupStore
    
    @State private var showCreate = false
    @State private var showJoin = false
    
    @State private var showLeaveAlert = false
    
    var body: some View {
        NavigationStack {
            
            Spacer()
            VStack(spacing: 20) {
                
                Text("Your Groups")
                    .font(.title)
                
                if groupStore.myGroups.isEmpty {
                    Text("No groups yet")
                        .foregroundColor(.gray)
                } else {
                    HStack{
                        List(groupStore.myGroups) { group in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(group.name)
                                        .font(.title2)
                                    
                                    Text("Code: \(group.joinCode)")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("\(group.memberCount) members")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    showLeaveAlert = true
                                } label: {
                                    Text("Leave Group")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    Button {
                        showCreate = true
                    } label: {
                        Text("Create Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        showJoin = true
                    } label: {
                        Text("Join Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Groups")
            .sheet(isPresented: $showCreate) {
                CreateGroupView()
                    .environmentObject(groupStore)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showJoin) {
                JoinGroupView()
                    .environmentObject(groupStore)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

