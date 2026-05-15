//
//  GroupCard.swift
//  CU_Meet_project
//

import SwiftUI

/// Tappable card displaying a group's name, member count, and join code.
struct GroupCard: View {
    /// The group to render.
    let group: Group

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                HStack(spacing: 14) {
                    Label("\(group.memberCount) members", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.mutedGray)
                    Text("Code: \(group.joinCode)")
                        .font(.caption)
                        .foregroundColor(.mutedGray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(.mutedGray)
        }
        .padding(16)
        .background(Color.brandPinkLight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    GroupCard(group: Group(
        id: "1", name: "Study Group A",
        joinCode: "ABC123", memberIDs: ["u1", "u2", "u3"]
    ))
    .padding()
}
