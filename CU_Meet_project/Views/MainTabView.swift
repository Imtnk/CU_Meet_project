//
//  MainTabView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case groups
        case profile
    }
    
    var body: some View {
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
    }
}

#Preview {
    MainTabView()
}
