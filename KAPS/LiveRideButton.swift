import SwiftUI

struct LiveRideButton: View {
    let currentBookingId: String
    @State private var isAnimating = false
    
    var body: some View {
        Button {
            if !currentBookingId.isEmpty {
                // Navigate to OngoingGoodsDetailView
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 58, height: 58)
                    .shadow(radius: 4)
                
                Image("live_ride")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 55, height: 55)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LiveRideButton(currentBookingId: "123")
} 