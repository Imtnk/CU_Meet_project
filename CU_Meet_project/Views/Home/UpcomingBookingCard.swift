import SwiftUI

struct UpcomingBookingCard: View {
    let groupName: String
    let roomName: String
    let timeSlot: String
    let date: Date

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(groupName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                Text(roomName)
                    .font(.caption)
                    .foregroundColor(.mutedGray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeSlot)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.brandPink)
                Text(formattedDate(date))
                    .font(.caption)
                    .foregroundColor(.mutedGray)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.mutedGray)
        }
        .padding(16)
        .background(Color.brandPinkLight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM"
        return f.string(from: date)
    }
}

#Preview {
    UpcomingBookingCard(
        groupName: "Study Group A",
        roomName: "Engineering Room",
        timeSlot: "09:00 - 11:00",
        date: Date()
    )
    .padding()
}
