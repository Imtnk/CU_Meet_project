//
//  EditProfileView.swift
//  CU_Meet_project
//

import SwiftUI
import GoogleSignIn

struct EditProfileView: View {

    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var nickname: String = ""
    @State private var studentID: String = ""
    @State private var faculty: String = ""
    @State private var year: String = ""
    @State private var mostActiveDay: String = ""
    @State private var birthdate: Date = Date()
    @State private var hasBirthdate: Bool = false

    @State private var isSaving = false
    @State private var studentIDError: String?

    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let years    = ["Year 1", "Year 2", "Year 3", "Year 4", "Year 5+", "Graduate"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Google Account") {
                    LabeledContent("First Name", value: authManager.extendedProfile?.firstName ?? authManager.userProfile?.profile?.givenName ?? "—")
                    LabeledContent("Last Name",  value: authManager.extendedProfile?.lastName  ?? authManager.userProfile?.profile?.familyName ?? "—")
                    LabeledContent("Email",      value: authManager.extendedProfile?.email     ?? authManager.userProfile?.profile?.email ?? "—")
                }

                Section("CU Profile") {
                    TextField("Nickname", text: $nickname)
                        .autocorrectionDisabled()

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Student ID (10 digits)", text: $studentID)
                            .keyboardType(.numberPad)
                            .onChange(of: studentID) { _, val in
                                studentID = String(val.filter(\.isNumber).prefix(10))
                                studentIDError = validateStudentID(studentID)
                            }
                        if let err = studentIDError {
                            Text(err).font(.caption).foregroundColor(.red)
                        }
                    }

                    TextField("Faculty / Department", text: $faculty)
                        .autocorrectionDisabled()

                    Picker("Year of Study", selection: $year) {
                        Text("—").tag("")
                        ForEach(years, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Personal") {
                    Toggle("Set Birthdate", isOn: $hasBirthdate)
                        .tint(.brandPink)
                    if hasBirthdate {
                        DatePicker("Birthdate", selection: $birthdate,
                                   in: ...Date(), displayedComponents: .date)
                            .tint(.brandPink)
                    }

                    Picker("Most Active Day", selection: $mostActiveDay) {
                        Text("—").tag("")
                        ForEach(weekdays, id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaving || studentIDError != nil)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandPink)
                }
            }
            .onAppear { loadCurrentValues() }
        }
    }

    private func loadCurrentValues() {
        guard let p = authManager.extendedProfile else { return }
        nickname      = p.nickname      ?? ""
        studentID     = p.studentID     ?? ""
        faculty       = p.faculty       ?? ""
        year          = p.year          ?? ""
        mostActiveDay = p.mostActiveDay ?? ""
        if let bd = p.birthdate {
            birthdate    = bd
            hasBirthdate = true
        }
    }

    private func validateStudentID(_ id: String) -> String? {
        guard !id.isEmpty else { return nil }
        return id.count == 10 ? nil : "Student ID must be exactly 10 digits"
    }

    private func save() {
        guard studentIDError == nil else { return }
        isSaving = true
        Task {
            do {
                try await authManager.saveProfile(
                    nickname:      nickname.nonEmpty,
                    studentID:     studentID.nonEmpty,
                    birthdate:     hasBirthdate ? birthdate : nil,
                    mostActiveDay: mostActiveDay.nonEmpty,
                    faculty:       faculty.nonEmpty,
                    year:          year.nonEmpty
                )
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run { isSaving = false }
            }
        }
    }
}
