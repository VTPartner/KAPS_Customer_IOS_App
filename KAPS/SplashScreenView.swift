import SwiftUI

struct SplashScreenView: View {
    @State private var showIntroView = false
    @State private var showLoginView = false
    @State private var showHomeView = false
    @State private var showRegistrationView = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Colors.primaryDark // Make sure to add this color to your assets
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 142)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    Text("KAPS")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1.0 : 0.0)
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showIntroView) {
                IntroView()
            }
            .navigationDestination(isPresented: $showLoginView) {
                LoginView()
            }
            .navigationDestination(isPresented: $showHomeView) {
                HomeView()
            }
            .navigationDestination(isPresented: $showRegistrationView) {
                // RegistrationView()
                Text("Registration View Placeholder")
            }
            .onAppear {
                print("\n=== Checking User Status in SplashScreenView ===")
                withAnimation(.easeInOut(duration: 1.0)) {
                    isAnimating = true
                }
                checkUserStatus()
            }
        }
    }
    
    private func checkUserStatus() {
        let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
        let customerName = PreferenceManager.shared.getStringValue("customer_name") ?? ""
        let firstRun = PreferenceManager.shared.getBooleanValue("firstRun")
        
        print("Retrieved values:")
        print("customer_id: \(customerId)")
        print("customer_name: \(customerName)")
        print("firstRun: \(firstRun)")
        
        // Verify all saved values
        print("\nAll saved values:")
        print("customer_id: \(PreferenceManager.shared.getStringValue("customer_id") ?? "nil")")
        print("customer_name: \(PreferenceManager.shared.getStringValue("customer_name") ?? "nil")")
        print("customer_mobile_no: \(PreferenceManager.shared.getStringValue("customer_mobile_no") ?? "nil")")
        print("profile_pic: \(PreferenceManager.shared.getStringValue("profile_pic") ?? "nil")")
        print("full_address: \(PreferenceManager.shared.getStringValue("full_address") ?? "nil")")
        print("email: \(PreferenceManager.shared.getStringValue("email") ?? "nil")")
        print("gst_no: \(PreferenceManager.shared.getStringValue("gst_no") ?? "nil")")
        print("gst_address: \(PreferenceManager.shared.getStringValue("gst_address") ?? "nil")")
        
        // Add a delay to show the splash screen for 3 seconds (matching Android)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if firstRun {
                if !customerId.isEmpty && !customerName.isEmpty {
                    print("User is logged in with complete profile, navigating to home")
                    showHomeView = true
                } else {
                    print("User is logged in but needs registration")
                    showLoginView = true
                }
            } else {
                print("First run not completed, showing intro")
                showIntroView = true
            }
            print("=== End User Status Check in SplashScreenView ===\n")
        }
    }
}

#Preview {
    SplashScreenView()
} 
