//
//  JoinGroupView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

struct JoinGroupView: View {

    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @State private var code = ""
    @State private var isJoining = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var isValidCode: Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        return trimmed.count == 6 && trimmed.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("Join Group")
                .font(.title)

            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter 6-digit code", text: $code)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: code) { newValue in
                        code = String(newValue.prefix(6).filter { $0.isNumber })
                    }

                HStack {
                    Text("\(code.count)/6")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if !isValidCode && !code.isEmpty {
                        Text("Code must be 6 digits")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .padding()

            Button(action: {
                isJoining = true
                Task {
                    do {
                        let result = try await groupStore.joinGroup(
                            code: code,
                            userID: authManager.currentUserID ?? ""
                        )
                        switch result {
                        case .success(let group):
                            alertTitle = "Success"
                            alertMessage = "Joined \(group.name)!"
                            code = ""
                        case .alreadyMember(let group):
                            alertTitle = "Already Member"
                            alertMessage = "You're already a member of \(group.name)"
                        case .notFound:
                            alertTitle = "Not Found"
                            alertMessage = "No group found with this code"
                        }
                    } catch {
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                    }
                    isJoining = false
                    showAlert = true
                }
            }) {
                Text(isJoining ? "Joining…" : "Join")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValidCode || isJoining)

            Spacer()
        }
        .padding()
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
