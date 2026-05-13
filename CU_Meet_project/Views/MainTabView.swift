//
//  MainTabView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var bookingStore: BookingStore
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case groups
        case profile
    }

    var body: some View {
        VStack(spacing: 0) {
            if authManager.isLoggedIn && !authManager.isFirebaseAuthenticated {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Firebase sign-in failed — writes are disabled. Check Firebase Console (Auth → Google provider).")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.85))
            }

        TabView(selection: $selectedTab) {
            
            // HOME
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            
            // GROUP
            GroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.3")
                }
                .tag(Tab.groups)
            
            // PROFILE
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        } // end VStack
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                bookingStore.startListening()
                groupStore.startListening(for: authManager.currentUserID ?? "")
            } else {
                bookingStore.stopListening()
                groupStore.stopListening()
            }
        }
        .onChange(of: authManager.currentUserID) { _, newID in
            groupStore.startListening(for: newID ?? "")
            if authManager.isLoggedIn {
                bookingStore.startListening()
            }
        }
        .onAppear {
            if authManager.isLoggedIn {
                bookingStore.startListening()
                groupStore.startListening(for: authManager.currentUserID ?? "")
            }
        }
    }
}

#Preview {
    let userStore = UserStore()
    MainTabView()
        .environmentObject(BookingStore())
        .environmentObject(GroupStore())
        .environmentObject(userStore)
        .environmentObject(AuthManager(userStore: userStore))
}
