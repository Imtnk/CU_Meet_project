//
//  CU_Meet_projectApp.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

@main
struct CU_Meet_projectApp: App {
    
    @StateObject private var bookingStore = BookingStore()
    @StateObject private var groupStore = GroupStore()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(bookingStore)
                .environmentObject(groupStore)
        }
    }
}
