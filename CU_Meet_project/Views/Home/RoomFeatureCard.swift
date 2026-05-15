import SwiftUI

struct RoomFeatureCard: View {
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
    RoomFeatureCard(room: HomeViewModel.seedRooms[0])
        .frame(height: 200)
        .padding()
}
