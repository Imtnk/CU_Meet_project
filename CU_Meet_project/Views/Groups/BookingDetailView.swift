//
//  BookingDetailView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI

struct BookingDetailView: View {
    
    let booking: Booking
    
    @EnvironmentObject var groupStore: GroupStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Room Image
                Image("meeting_room1")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Room Info
                    Text(booking.roomName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Time: \(booking.timeSlot)")
                        .foregroundColor(.blue)
                    
                    Text("Date: \(formattedDate(booking.date))")
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Group Info
                    Text("Group")
                        .font(.headline).bold()
                    
                    if let group = groupStore.group(for: booking.groupID) {
                        
                        Text(group.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Members")
                            .font(.headline)
                            .padding(.top, 5)
                        
                        ForEach(group.members, id: \.self) { member in
                            Text("• \(member)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                    } else {
                        Text("Group not found")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
