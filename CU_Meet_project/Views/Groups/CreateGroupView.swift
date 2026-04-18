//
//  CreateGroupView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI

struct CreateGroupView: View {
    
    @EnvironmentObject var groupStore: GroupStore
    @Environment(\.dismiss) var dismiss
    
    @State private var groupName = ""
    @State private var createdGroup: Group?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Create Group")
                .font(.title)
            
            TextField("Group Name", text: $groupName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Create") {
                createdGroup = groupStore.createGroup(name: groupName)
            }
            .disabled(groupName.isEmpty)
            
            if let group = createdGroup {
                
                VStack(spacing: 10) {
                    Text("Group Created")
                        .font(.headline)
                    
                    Text("Name: \(group.name)")
                    Text("Join Code: \(group.joinCode)")
                        .font(.title2)
                        .bold()
                    
                    Button("Done") {
                        dismiss()
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}
