//
//  JoinGroupView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

/// Sheet view for joining a group by entering a 6‑digit join code.
struct JoinGroupView: View {

    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var authManager: AuthManager
    @State private var code = ""
    @State private var isJoining = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    /// Shows a success toast after joining a group.
    @State private var showSuccessToast = false
    /// Text shown in the success toast.
    @State private var successMessage = ""

    /// Whether the current input is a valid 6‑digit numeric code.
    var isValidCode: Bool {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        return trimmed.count == 6 && trimmed.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(spacing: 16) {

            Text("Join Group")
                .font(.title2).fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 6) {
                TextField("Enter 6-digit code", text: $code)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: code) { newValue in
                        code = String(newValue.prefix(6).filter { $0.isNumber })
                    }

                HStack {
                    Text("\(code.count)/6")
                        .font(.caption)
                        .foregroundColor(.mutedGray)

                    if !isValidCode && !code.isEmpty {
                        Text("Code must be 6 digits")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .padding(14)
//            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
            .padding(.horizontal, 20)

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
                            successMessage = "Joined \(group.name)!"
                            showSuccessToast = true
                            code = ""
                        case .alreadyMember(let group):
                            alertTitle = "Already Member"
                            alertMessage = "You're already a member of \(group.name)"
                            showAlert = true
                        case .notFound:
                            alertTitle = "Not Found"
                            alertMessage = "No group found with this code"
                            showAlert = true
                        }
                    } catch {
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                    isJoining = false
                }
            }) {
                Text(isJoining ? "Joining…" : "Join")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(isJoining || !isValidCode ? Color.brandPink.opacity(0.4) : Color.brandPink)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
            }
            .disabled(!isValidCode || isJoining)
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.warmGray.ignoresSafeArea())
        .toast(isPresented: $showSuccessToast, message: successMessage)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
