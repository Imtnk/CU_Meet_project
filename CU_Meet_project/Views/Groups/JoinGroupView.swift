//
//  JoinGroupView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI

struct JoinGroupView: View {
    
    @EnvironmentObject var groupStore: GroupStore
    @State private var code = ""
    @State private var error: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Join Group")
                .font(.title)
            
            TextField("Enter 6-digit code", text: $code)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: {
                
                let result = groupStore.joinGroup(code: code)
                
                switch result {
                    
                case .success(let group):
                    alertMessage = "Joined \(group.name)"
                    code = ""
                    
                case .alreadyMember(let group):
                    alertMessage = "You're already in \(group.name)"
                    
                case .notFound:
                    alertMessage = "Group not found"
                }
                
                showAlert = true
                
            }) {
                Text("Join")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .alert("Join Group", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
