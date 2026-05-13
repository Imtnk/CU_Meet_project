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
    
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var showCancelAlert = false
    @State private var errorMessage: String?
    
    
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
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Group")
                            .font(.headline)
                            .bold()

                        if let group = currentGroup {
                            
                            Text(group.name)
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text("Members")
                                .font(.headline)
                                .padding(.top, 5)

                            ForEach(group.memberIDs, id: \.self) { memberID in
                                Text("• \(userStore.displayName(for: memberID))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                        } else {
                            Text("Group not found")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if booking.date >= Calendar.current.startOfDay(for: Date()) {
                            
                            Button("Cancel Booking") {
                                showCancelAlert = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top)
                        }
                    
                }
                .padding()
                .alert("Cancel Booking?", isPresented: $showCancelAlert) {
                    
                    Button("Delete", role: .destructive) {
                        Task {
                            do {
                                try await bookingStore.cancelBooking(booking)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    
                    Button("Keep", role: .cancel) { }
                    
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
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
    
    private var currentGroup: Group? {
        groupStore.groups.first { $0.id == booking.groupID }
    }
}
