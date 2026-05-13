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
    let groupID: String
    
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    
    @Environment(\.dismiss) var dismiss
    let onComplete: () -> Void
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 20) {

            Text("Confirm Booking")
                .font(.title2)
                .fontWeight(.bold)

            if isSubmitting {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
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
            
            HStack(spacing: 12) {

                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isSubmitting)

                Button(action: {
                    isSubmitting = true
                    let booking = Booking(
                        id: UUID().uuidString,
                        roomID: room.id,
                        roomName: room.name,
                        groupID: groupID,
                        date: selectedDate,
                        timeSlot: selectedTime
                    )
                    Task {
                        do {
                            try await bookingStore.addBooking(booking)
                            onComplete()
                        } catch {
                            errorMessage = error.localizedDescription
                            isSubmitting = false
                        }
                    }
                }) {
                    if isSubmitting {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Booking…")
                        }
                    } else {
                        Text("Confirm")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSubmitting ? Color.blue.opacity(0.6) : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isSubmitting)
            }
        }
        .padding()
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
