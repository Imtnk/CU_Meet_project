//
//  CU_Meet_projectApp.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import GoogleSignIn

@main
struct CU_Meet_projectApp: App {
    
    @StateObject private var bookingStore = BookingStore()
    @StateObject private var groupStore = GroupStore()
    
    init() {
            // Replace with your actual Client ID from Google Console
            let config = GIDConfiguration(clientID: "71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76.apps.googleusercontent.com")
            GIDSignIn.sharedInstance.configuration = config
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(bookingStore)
                .environmentObject(groupStore)
                .onOpenURL { url in
                                    GIDSignIn.sharedInstance.handle(url)
                                }
        }
    }
}
