//
//  CU_Meet_projectApp.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

@main
struct CU_Meet_projectApp: App {

    @StateObject private var bookingStore = BookingStore()
    @StateObject private var groupStore   = GroupStore()
    @StateObject private var userStore: UserStore
    @StateObject private var authManager: AuthManager

    init() {
        FirebaseApp.configure()

        let clientID = FirebaseApp.app()?.options.clientID ?? ""
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let store = UserStore()
        _userStore   = StateObject(wrappedValue: store)
        _authManager = StateObject(wrappedValue: AuthManager(userStore: store))

        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(bookingStore)
                .environmentObject(groupStore)
                .environmentObject(userStore)
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
