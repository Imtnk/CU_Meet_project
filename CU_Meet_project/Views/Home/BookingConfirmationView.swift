//
//  BookingConfirmationView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 18/4/2569 BE.
//


import SwiftUI

struct BookingConfirmationView: View {
    
    let room: MeetingRoom
    let selectedDate: Date
    let selectedTime: String
    let groupID: UUID
    
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Confirm Booking")
                .font(.title2)
                .fontWeight(.bold)
            
            Image("meeting_room1")
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Room")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(room.name)
                    .font(.headline)
                
                Divider()
                
                Text("Group")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(groupStore.groupName(for: groupID))
                    .font(.headline)
                
                Divider()
                
                Text("Date & Time")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(formattedDate(selectedDate)) • \(selectedTime)")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Spacer()
            
            HStack {
                
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Confirm") {
                    
                    let booking = Booking(
                        roomID: room.id,
                        roomName: room.name,
                        groupID: groupID,
                        date: selectedDate,
                        timeSlot: selectedTime
                    )
                    
                    bookingStore.addBooking(booking)
                    
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
