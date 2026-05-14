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
    @State private var showSplash = true

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
            ZStack {
                MainTabView()
                    .environmentObject(bookingStore)
                    .environmentObject(groupStore)
                    .environmentObject(userStore)
                    .environmentObject(authManager)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.4), value: showSplash)
            .task {
                try? await Task.sleep(for: .seconds(1.8))
                showSplash = false
            }
        }
    }
}
