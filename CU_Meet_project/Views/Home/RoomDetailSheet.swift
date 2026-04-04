//
//  RoomDetailSheet.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct RoomDetailSheet: View {
    
    let room: MeetingRoom
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Meeting Info")
                .font(.headline)
                .padding(.top, 8)
            
            // Image (placeholder for now)
            Image("meeting_room1")
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            
            Text(room.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Date + Time (mock)
            HStack(spacing: 12) {
                Text("Apr 1, 2025")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
                
                Text("9:41 AM")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding()
    }
}
