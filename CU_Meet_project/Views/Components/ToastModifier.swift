import SwiftUI

/// A capsule‑shaped banner that slides in from the top edge to confirm a
/// successful action, then auto‑dismisses after 2 seconds.
struct ToastModifier: ViewModifier {
    /// Controls visibility of the toast.
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    Text(message)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(Color.brandPink)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 8)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPresented)
    }
}

extension View {
    /// Presents a brief success toast at the top of the view.
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}
