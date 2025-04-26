import SwiftUI

struct IntroView: View {
    @State private var currentPage = 0
    @State private var showLoginView = false
    @State private var showHomeView = false
    @State private var showRegistrationView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // // Logo
                    // Image("logo")
                    //     .resizable()
                    //     .scaledToFit()
                    //     .frame(width: 200, height: 200)
                    //     .padding(.top, 50)
                    
                    // Spacer()
                    
                    // Info Views
                    TabView(selection: $currentPage) {
                        Info1View()
                            .tag(0)
                        Info2View()
                            .tag(1)
                        Info3View()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Page Indicator
                    PageIndicatorView(numberOfPages: 3, currentPage: currentPage)
                        .padding(.vertical, 20)
                    
                    // Continue Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            PreferenceManager.shared.setBooleanValue(true, forKey: "firstRun")
                            showLoginView = true
                        }
                    }) {
                        Text(currentPage < 2 ? "Next" : "Get Started")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
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
                checkUserStatus()
            }
        }
    }
    
    private func checkUserStatus() {
        print("\n=== Checking User Status in IntroView ===")
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
        
        if !customerId.isEmpty {
            if !customerName.isEmpty && customerName != "NA" {
                print("User is logged in with complete profile, navigating to home")
                showHomeView = true
            } else {
                print("User is logged in but needs registration")
                showRegistrationView = true
            }
        } else {
            print("No user logged in")
            if firstRun {
                print("First run completed, showing login")
                showLoginView = true
            }
        }
        print("=== End User Status Check ===\n")
    }
}

#Preview {
    IntroView()
} 
