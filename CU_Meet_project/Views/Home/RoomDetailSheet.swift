//
//  RoomDetailSheet.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct RoomDetailSheet: View {
    
    let room: MeetingRoom
    
    // mock data
    private func percentage(for star: Int) -> CGFloat {
        switch star {
        case 5: return 0.98
        case 4: return 0.02
        case 3: return 0.0
        case 2: return 0.0
        case 1: return 0.0
        default: return 0.0
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Meeting Room Info")
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
            
            //Rating (mock)
            VStack(alignment: .leading, spacing: 16) {
                
                // Top Rating Row
                HStack(alignment: .center) {
                    
                    Text("4.8")
                        .font(.system(size: 40, weight: .bold))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Text("667K Ratings")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Breakdown Card
                VStack(spacing: 8) {
                    
                    Text("User Reviews")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach([5,4,3,2,1], id: \.self) { star in
                        HStack {
                            Text("\(star)")
                                .frame(width: 10)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                    
                                    Capsule()
                                        .fill(Color.yellow)
                                        .frame(width: geo.size.width * percentage(for: star))
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(Int(percentage(for: star) * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 40)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Tap to Rate
                VStack(spacing: 5) {
                    Text("Tap to Rate")
                        .font(.subheadline)
                    
                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: "star")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
