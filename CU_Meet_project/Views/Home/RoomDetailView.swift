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
}
