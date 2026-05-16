import SwiftUI

/// Hero card displaying a room's image overlay with name, capacity badge, and rating pill.
struct RoomFeatureCard: View {
    /// The room metadata to render.
    let room: MeetingRoom

    var body: some View {
        Rectangle()
            .fill(Color.brandPinkDark)
            .overlay(
                Image(room.imageAssetName)
                    .resizable()
                    .scaledToFill()
            )
            .overlay(
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(room.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                        Text("Up to \(room.capacity) people")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text(String(format: "%.1f", room.rating))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.35))
                .clipShape(Capsule())
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
    }
}

#Preview {
    RoomFeatureCard(room: MeetingRoom(
        id: "preview", name: "Engineering Room",
        latitude: 13.7365, longitude: 100.5325,
        rating: 4.7, reviewCount: 32,
        facilities: [.projector, .whiteboard],
        capacity: 10, imageAssetName: "meeting_room1"
    ))
        .frame(height: 200)
        .padding()
}
