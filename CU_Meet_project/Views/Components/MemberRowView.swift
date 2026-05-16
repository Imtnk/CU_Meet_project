//
//  MemberRowView.swift
//  CU_Meet_project
//

import SwiftUI

/// Tappable row showing a member's avatar, display name, and a "You" badge
/// when the row represents the current user.
struct MemberRowView: View {
    /// Firebase UID of the member.
    let memberID: String
    /// Pre‑resolved display name.
    let displayName: String
    /// Whether this row represents the signed‑in user.
    let isCurrentUser: Bool
    /// Action triggered when the row is tapped.
    let onTap: () -> Void
    /// If non-nil, shows a red remove button. Called with the member's display name.
    var onRemove: ((String) -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brandPinkLight)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.subheadline).foregroundColor(.brandPink)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.subheadline).fontWeight(.medium).foregroundColor(.charcoal)
                if isCurrentUser {
                    Text("You")
                        .font(.caption).foregroundColor(.brandPink)
                }
            }

            Spacer()

            if let onRemove {
                Button {
                    onRemove(displayName)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }

            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(.mutedGray)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview {
    VStack(spacing: 12) {
        MemberRowView(
            memberID: "alice_uid",
            displayName: "Alice Johnson",
            isCurrentUser: false,
            onTap: {}
        )
        MemberRowView(
            memberID: "current_uid",
            displayName: "You",
            isCurrentUser: true,
            onTap: {}
        )
    }
    .padding()
}
