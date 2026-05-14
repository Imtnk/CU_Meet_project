import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var groupStore: GroupStore
    @EnvironmentObject var bookingStore: BookingStore
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, groups, profile
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
                SwiftUI.Group {
                    if authManager.isLoggedIn {
                        HomeView()
                    } else {
                        SignInRequiredView()
                    }
                }
                .tabItem { Label("Explore", systemImage: "house.fill") }
                .tag(Tab.home)

                SwiftUI.Group {
                    if authManager.isLoggedIn {
                        GroupsView()
                    } else {
                        SignInRequiredView()
                    }
                }
                .tabItem { Label("Groups", systemImage: "person.3.fill") }
                .tag(Tab.groups)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                    .tag(Tab.profile)
            }
            .tint(.brandPink)
        }
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
            if authManager.isLoggedIn { bookingStore.startListening() }
        }
        .onAppear {
            if authManager.isLoggedIn {
                bookingStore.startListening()
                groupStore.startListening(for: authManager.currentUserID ?? "")
            }
        }
    }
}

private struct SignInRequiredView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 64))
                    .foregroundColor(.brandPink)
                Text("Sign In Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                Text("Go to the Profile tab to sign in.")
                    .foregroundColor(.mutedGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Sign In")
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
