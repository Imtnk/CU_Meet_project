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
    @EnvironmentObject var authManager: AuthManager
    @State private var testNotificationScheduled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("CU Meet").font(.title)
                Image("logo_meet").resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(75).shadow(radius: 3)
                NavigationLink(destination: RoomMapView()
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
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        NotificationManager.shared.scheduleTestReminder()
                        testNotificationScheduled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            testNotificationScheduled = false
                        }
                    } label: {
                        Image(systemName: testNotificationScheduled ? "checkmark.circle.fill" : "bell.badge")
                    }
                }
            }
            #endif
        }
    }
    
    private var upcomingSection: some View {
        let myGroupIDs = Set(groupStore.myGroups(currentUserID: authManager.currentUserID).map { $0.id })
        let bookings = bookingStore.upcomingBookings()
            .filter { myGroupIDs.contains($0.groupID) }
            .prefix(5)
        
        return VStack(alignment: .leading, spacing: 12) {
            
            Text("Upcoming Bookings")
                .font(.headline)
            
            if bookingStore.isLoading {
                ProgressView("Loading bookings…")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
            } else if bookings.isEmpty {
                Text("No upcoming bookings")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                
                VStack(spacing: 12) {
                    ForEach(Array(bookings)) { booking in
                        
                        NavigationLink(
                            destination: BookingDetailView(booking: booking)
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
    let userStore = UserStore()
    HomeView()
        .environmentObject(BookingStore())
        .environmentObject(GroupStore())
        .environmentObject(AuthManager(userStore: userStore))
}
