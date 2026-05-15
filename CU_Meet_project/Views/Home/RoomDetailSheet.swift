//
//  RoomDetailSheet.swift
//  CU_Meet_project
//

import SwiftUI

struct RoomDetailSheet: View {

    let room: MeetingRoom

    var body: some View {
        VStack(spacing: 0) {

            // Drag indicator
            Capsule()
                .fill(Color.mutedGray.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 16) {

                    // Room image
                    Rectangle()
                        .fill(Color.brandPinkDark)
                        .overlay(
                            Image(room.imageAssetName).resizable().scaledToFill()
                        )
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                        .padding(.horizontal)

                    // Name + rating row
                    VStack(alignment: .leading, spacing: 6) {
                        Text(room.name)
                            .font(.title2).fontWeight(.bold).foregroundColor(.charcoal)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                ForEach(0..<5) { i in
                                    Image(systemName: i < Int(room.rating.rounded()) ? "star.fill" : "star")
                                        .font(.caption).foregroundColor(.brandPink)
                                }
                                Text(String(format: "%.1f", room.rating))
                                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.charcoal)
                            }
                            Text("·  \(room.reviewCount) reviews")
                                .font(.subheadline).foregroundColor(.mutedGray)
                        }

                        Label("\(room.capacity) people max", systemImage: "person.2.fill")
                            .font(.subheadline).foregroundColor(.mutedGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Facilities
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Facilities")
                            .font(.headline).foregroundColor(.charcoal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Facility.allCases) { facility in
                                let available = room.facilities.contains(facility)
                                HStack(spacing: 6) {
                                    Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle")
                                        .foregroundColor(available ? .brandPink : .mutedGray)
                                        .font(.subheadline)
                                    Text(facility.rawValue)
                                        .font(.caption).foregroundColor(available ? .charcoal : .mutedGray)
                                    Spacer()
                                }
                                .opacity(available ? 1 : 0.45)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
    }
}
