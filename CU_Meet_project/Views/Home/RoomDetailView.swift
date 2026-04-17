//
//  RoomDetailView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 15/4/2569 BE.
//

import SwiftUI

struct RoomDetailView: View {
    
    let room: MeetingRoom
    @State private var userRating: Int = 0
    // for debugging rating
    @State private var showAlert = false
    
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    @State private var selectedGroupID: UUID? = nil
    @State private var showConfirmationSheet = false
    @Environment(\.dismiss) var dismiss
    
    private let timeSlots = [
        "09:00 - 10:00",
        "10:00 - 11:00",
        "11:00 - 12:00",
        "13:00 - 14:00",
        "14:00 - 15:00",
        "15:00 - 16:00"
    ]
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Image
                Image("meeting_room1")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 16) {

                    Text(room.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Capacity: \(room.capacity) people")
                        .foregroundColor(.gray)
                    
                    ratingSection
                    
                    facilitiesSection
                    
                    rateSection
                    
                    bookingSection
                    
                }
                .padding()
            }
        }
        .navigationTitle("Room Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rating Submitted", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You rated this room \(userRating) star\(userRating > 1 ? "s" : "")")
        }
        .sheet(isPresented: $showConfirmationSheet) {
            BookingConfirmationView(
                room: room,
                selectedDate: selectedDate,
                selectedTime: selectedTime!,
                groupID: selectedGroupID!,
                onComplete: {
                    dismiss() // go back to Map
                }
            )
            .environmentObject(bookingStore)
            .environmentObject(groupStore)
        }
    }
    private var ratingSection: some View {
        HStack {
            Text(String(format: "%.1f", room.rating))
                .font(.system(size: 32, weight: .bold))
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                    }
                }
                
                Text("\(room.reviewCount) Reviews")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    private var facilitiesSection: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Facilities")
                .font(.headline)
            
            ForEach(Facility.allCases) { facility in
                
                let available = room.facilities.contains(facility)
                
                HStack {
                    Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundColor(available ? .green : .gray)
                    
                    Text(facility.rawValue)
                        .foregroundColor(available ? .primary : .gray)
                    
                    Spacer()
                }
                .opacity(available ? 1 : 0.4)
            }
        }
    }
    private var rateSection: some View {
        VStack {
            Text("Tap to Rate")
                .font(.subheadline)
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= userRating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            userRating = star
                            showAlert = true
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var bookingSection: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Book This Room")
                .font(.headline)
            
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            
            groupPickerSection
            
            if let id = selectedGroupID {
                Text("Members: \(groupStore.groups.first(where: { $0.id == id })?.memberCount ?? 0)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Select Time Slot")
                .font(.subheadline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                
                ForEach(timeSlots, id: \.self) { slot in
                    
                    let isBooked = bookingStore.isBooked(
                        roomID: room.id,
                        date: selectedDate,
                        timeSlot: slot
                    )
                    
                    Button {
                        if !isBooked {
                            selectedTime = slot
                        }
                    } label: {
                        Text(slot)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isBooked ? Color.gray.opacity(0.3) :
                                (selectedTime == slot ? Color.blue : Color(.systemGray5))
                            )
                            .foregroundColor(
                                isBooked ? .gray :
                                (selectedTime == slot ? .white : .primary)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(isBooked)
                }
            }
            
            let isDisabled = selectedTime == nil || selectedGroupID == nil

            Button {
                showConfirmationSheet = true
            } label: {
                Text("Reserve Room")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isDisabled)
            .background(selectedTime == nil ? Color.gray : Color.blue)
            .cornerRadius(15)
            
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private var groupPickerSection: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Select Group")
                .font(.headline)
            
            Menu {
                ForEach(groupStore.groups) { group in
                    Button {
                        selectedGroupID = group.id
                    } label: {
                        Text(group.name)
                    }
                }
            } label: {
                HStack {
                    Text(selectedGroupName)
                        .foregroundColor(selectedGroupID == nil ? .gray : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private var selectedGroupName: String {
        guard let id = selectedGroupID else {
            return "Choose a group"
        }
        return groupStore.groupName(for: id)
    }
}
