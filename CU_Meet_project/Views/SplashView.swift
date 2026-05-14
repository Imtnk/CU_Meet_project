import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.brandPink
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image("logo_meet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(color: .white.opacity(0.4), radius: 20)
                Text("CU Meet")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SplashView()
}
