import SwiftUI

// MARK: - Profile Section
struct ProfileSectionView: View {
    let customerId: String
    let customerName: String
    let customerMobileNo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Customer ID #\(customerId)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 2)
            
            Text(customerName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 2)
            
            Text(customerMobileNo)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.vertical, 2)
            
            NavigationLink(destination: CustomerEditProfileView()) {
                Text("Edit Details")
                    .font(.system(size: 16))
                    .foregroundColor(Colors.primary)
                    .padding(.vertical, 2)
            }
        }
        .padding(12)
        .background(Color.white)
    }
}

// MARK: - Wallet Section
struct WalletSectionView: View {
    var body: some View {
        HStack {
            Text("Wallet")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            NavigationLink(destination: WalletView()) {
                HStack {
                    Text("Check")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Colors.primary)
                .cornerRadius(12)
            }
        }
        .padding(10)
    }
}

// MARK: - Promotional Section
struct PromotionalSectionView: View {
    let shareApp: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Invite Friends
            Button(action: shareApp) {
                VStack {
                    Image("invite_friends")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(5)
                    
                    Text("Invite Your Friend")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.primary)
                        .padding(2)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Place Trip
            NavigationLink(destination: HomeView()) {
                VStack {
                    Image("first_trip")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(5)
                    
                    Text("Place a First Trip")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.primary)
                        .padding(2)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Enjoy Earnings
            NavigationLink(destination: WalletView()) {
                VStack {
                    Image("earn_money")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(5)
                    
                    Text("Enjoy Your Earning")
                        .font(.system(size: 12))
                        .foregroundColor(Colors.primary)
                        .padding(2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
    }
}

// MARK: - Contact Section
struct ContactSectionView: View {
    let makePhoneCall: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(12)
            VStack(alignment: .leading, spacing: 5) {
                Text("Contact Us")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text("For any queries or help")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Button(action: makePhoneCall) {
                    HStack {
                        Text("Call Us")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Image(systemName: "phone.fill")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Colors.primary)
                    .cornerRadius(20)
                }
            }
        }
        .padding(10)
    }
}

// MARK: - Service Section
struct ServiceSectionView<Destination: View>: View {
    let title: String
    let destination: Destination
    let backgroundColor: Color
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack {
                    Text("View All")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(backgroundColor)
                .cornerRadius(12)
            }
            .padding(10)
        }
    }
}

// MARK: - Terms Section
struct TermsSectionView: View {
    let openWebUrl: (String) -> Void
    
    var body: some View {
        HStack {
            Text("Terms and conditions")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                openWebUrl("https://www.kaps9.in/terms&conditions")
            }) {
                HStack {
                    Text("View")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Colors.primaryDark)
                .cornerRadius(12)
            }
        }
        .padding(10)
    }
}

// MARK: - Account Actions Section
struct AccountActionsSectionView: View {
    let showDeleteAccountAlert: () -> Void
    let showLogoutAlert: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Delete Account
            Button(action: showDeleteAccountAlert) {
                Text("DELETE ACCOUNT")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            
            // Divider
            Color.gray.opacity(0.1)
                .frame(height: 1)
                .padding(.horizontal, 10)
            
            // Logout
            Button(action: showLogoutAlert) {
                Text("Logout")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
        }
    }
}

// MARK: - Main View
struct AccountSettingsView: View {
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutAlert = false
    @State private var showLanguageDialog = false
    @State private var showDeleteConfirmation = false
    
    private let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
    private let customerName = PreferenceManager.shared.getStringValue("customer_name") ?? ""
    private let customerMobileNo = PreferenceManager.shared.getStringValue("customer_mobile_no") ?? ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Profile Section
                ProfileSectionView(
                    customerId: customerId,
                    customerName: customerName,
                    customerMobileNo: customerMobileNo
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Wallet Section
                WalletSectionView()
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 1)
                    .padding(.horizontal, 10)
                
                // Promotional Sections
                PromotionalSectionView(shareApp: shareApp)
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Terms and Conditions
                TermsSectionView(openWebUrl: openWebUrl)
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Scheduled Bookings
                ServiceSectionView(
                    title: "Scheduled Bookings",
                    destination: ScheduledBookingsView(),
                    backgroundColor: Colors.primaryDark
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // JCB/Crane Rides
                ServiceSectionView(
                    title: "JCB / Crane Rides",
                    destination: JcbCraneRidesView(),
                    backgroundColor: Color.purple
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Driver Rides
                ServiceSectionView(
                    title: "Driver Rides",
                    destination: DriverRidesView(),
                    backgroundColor: Colors.primaryDark
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Handyman Services
                ServiceSectionView(
                    title: "Handyman Services",
                    destination: HandymanServicesView(),
                    backgroundColor: Color.green
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Contact Section
                ContactSectionView(makePhoneCall: makePhoneCall)
                
                // Email
                Text("Mail us at info@kaps9.in")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.primary)
                    .padding(10)
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // Account Actions
                AccountActionsSectionView(
                    showDeleteAccountAlert: { showDeleteAccountAlert = true },
                    showLogoutAlert: { showLogoutAlert = true }
                )
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // App Version
                Text("App version v0.0.1")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(10)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Delete", role: .destructive) {
                showDeleteConfirmation = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .alert("Request Sent", isPresented: $showDeleteConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your account deletion request has been sent to our team. We will process it within 24-48 hours.")
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Logout", role: .destructive) {
                logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private func shareApp() {
        let appUrl = "https://play.google.com/store/apps/details?id=com.kapstranspvtltd.kaps&hl=en_IN"
        let text = "Experience seamless transportation and on-demand services with the KAPS app! 🚀 Whether you need reliable Goods Delivery, Cab Booking, JCB & Crane Services, Professional Drivers, or skilled Handyman Services, KAPS has you covered. Download now and simplify your daily needs with just a few taps! 🔗 Get the app here: \(appUrl)"
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
    
    private func openWebUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func makePhoneCall() {
        let phoneNumber = "+919665141555"
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func logout() {
        PreferenceManager.shared.clearAll()
        // Navigate to login screen
    }
}

#Preview {
    AccountSettingsView()
} 
