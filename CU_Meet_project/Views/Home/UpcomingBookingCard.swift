import SwiftUI

/// Compact row card showing a future booking's group, room, time slot, and date.
struct UpcomingBookingCard: View {
    /// Display name of the associated group.
    let groupName: String
    /// Display name of the booked room.
    let roomName: String
    /// Time range string (e.g. "09:00 - 11:00").
    let timeSlot: String
    /// Calendar date of the booking.
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

    /// Formats a date to a short "dd MMM" string.
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
