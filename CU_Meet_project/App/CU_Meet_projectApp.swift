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
    @StateObject private var groupStore   = GroupStore()
    @StateObject private var userStore: UserStore
    @StateObject private var authManager: AuthManager

    init() {
        let config = GIDConfiguration(clientID: "71930476155-qrkic6shoev6tuutc1ot1fhi08nnim76.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config

        let store = UserStore()
        _userStore   = StateObject(wrappedValue: store)
        _authManager = StateObject(wrappedValue: AuthManager(userStore: store))
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
