import SwiftUI

struct LoadingView: View {
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Colors.primary)
            }
    }
}

#Preview {
    LoadingView()
} 