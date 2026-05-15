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
            
            Image(room.imageAssetName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Room")
                    .font(.caption)
                    .foregroundColor(.mutedGray)
                
                Text(room.name)
                    .font(.headline)
                
                Divider()
                
                Text("Group")
                    .font(.caption)
                    .foregroundColor(.mutedGray)
                
                Text(groupStore.groupName(for: groupID))
                    .font(.headline)
                
                Divider()
                
                Text("Date & Time")
                    .font(.caption)
                    .foregroundColor(.mutedGray)
                
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
                .background(Color.mutedGray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                .disabled(isSubmitting)

                Button(action: {
                    isSubmitting = true
                    let booking = Booking(
                        id: UUID().uuidString,
                        roomID: room.id,
                        roomName: room.name,
                        groupID: groupID,
                        date: selectedDate,
                        timeSlot: selectedTime,
                        imageAssetName: room.imageAssetName
                    )
                    Task {
                        do {
                            try await bookingStore.addBooking(booking)
                            NotificationManager.shared.scheduleReminder(for: booking)
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
                .background(isSubmitting ? Color.brandPink.opacity(0.6) : Color.brandPink)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
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
