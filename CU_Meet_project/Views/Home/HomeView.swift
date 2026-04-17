//
//  HomeView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var groupStore: GroupStore
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("CU Meet").font(.title)
                Image("logo_meet").resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(75).shadow(radius: 3)
                NavigationLink(destination: RoomMapView()
                    .environmentObject(bookingStore)
                ) {
                    Text("Book Now")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal)
                }
                
                upcomingSection
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
    
    private var upcomingSection: some View {
        
        let bookings = bookingStore.bookings
            .filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
            .sorted {
                if Calendar.current.isDate($0.date, inSameDayAs: $1.date) {
                    return $0.timeSlot < $1.timeSlot
                }
                return $0.date < $1.date
            }
            .prefix(5)
        
        return VStack(alignment: .leading, spacing: 12) {
            
            Text("Upcoming Bookings")
                .font(.headline)
            
            if bookings.isEmpty {
                Text("No upcoming bookings")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                
                VStack(spacing: 12) {
                    ForEach(Array(bookings)) { booking in
                        
                        NavigationLink(
                            destination: BookingDetailView(booking: booking)
                                .environmentObject(groupStore)
                        ) {
                            
                            HStack {
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    Text(groupStore.groupName(for: booking.groupID))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(booking.roomName)
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 6){
                                    
                                    Text(booking.timeSlot)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    Text(formattedDateShort(booking.date))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                }
                               
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func formattedDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    
    HomeView()
        .environmentObject(BookingStore())
        .environmentObject(GroupStore())
}
