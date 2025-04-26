import SwiftUI
import CoreLocation

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var selectedAccountType = "Personal"
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showLoading = false
    @State private var showHomeView = false
    @StateObject private var locationHelper = LocationHelper()
    @State private var showLocationAlert = false
    
    private let accountTypes = ["Personal", "Business"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Back Button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    .frame(height: 52)
                    .padding(.horizontal)
                    
                    // Title
                    Text("Complete Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Colors.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Phone Number
                    Text(PreferenceManager.shared.getStringValue("customer_mobile_no") ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(Colors.grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Full Name Input
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                        .font(.system(size: 16))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    
                    // Email Input
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 16))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Account Type Picker
                    Picker("Account Type", selection: $selectedAccountType) {
                        ForEach(accountTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .frame(maxWidth:.infinity)
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Register Button
                    Button(action: {
                        if validateInputs() {
                            registerCustomer()
                        }
                    }) {
                        Text("Register")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Colors.primary)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal)
                    .padding(.top, 32)
                    .disabled(showLoading)
                }
                .padding(.bottom, 32)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showHomeView) {
                HomeView()
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showLocationAlert) {
                Alert(
                    title: Text("Location Access Required"),
                    message: Text("Please enable location access in Settings to complete your registration."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            .overlay {
                if showLoading {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Colors.primary)
                        }
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if fullName.isEmpty {
            errorMessage = "Full name required"
            showError = true
            return false
        }
        
        if email.isEmpty || !isValidEmail(email) {
            errorMessage = "Valid email required"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func registerCustomer() {
        showLoading = true
        
        // Check location authorization status
        switch locationHelper.authorizationStatus {
        case .notDetermined:
            locationHelper.getCurrentLocation { result in
                handleLocationResult(result)
            }
        case .denied, .restricted:
            showLoading = false
            showLocationAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationHelper.getCurrentLocation { result in
                handleLocationResult(result)
            }
        @unknown default:
            showLoading = false
            errorMessage = "Unknown location authorization status"
            showError = true
        }
    }
    
    private func handleLocationResult(_ result: Result<LocationDetails, Error>) {
        switch result {
        case .success(let locationDetails):
            let parameters: [String: Any] = [
                "customer_id": PreferenceManager.shared.getStringValue("customer_id") ?? "",
                "full_address": locationDetails.address,
                "customer_name": fullName,
                "email": email,
                "purpose": selectedAccountType,
                "pincode": locationDetails.postalCode,
                "r_lat": locationDetails.latitude,
                "r_lng": locationDetails.longitude
            ]
            
            NetworkManager.shared.postRequest(
                url: APIClient.baseUrl + "customer_registration",
                parameters: parameters
            ) { result in
                showLoading = false
                switch result {
                case .success:
                    saveUserDetails(name: fullName, email: email, address: locationDetails.address)
                    showHomeView = true
                case .failure(let error):
                    print("customer registration error:: \(error.localizedDescription)")
                    errorMessage = "Registration failed. Please try again."
                    showError = true
                }
            }
            
        case .failure(let error):
            showLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func saveUserDetails(name: String, email: String, address: String) {
        PreferenceManager.shared.setStringValue(name, forKey: "customer_name")
        PreferenceManager.shared.setStringValue(email, forKey: "email")
        PreferenceManager.shared.setStringValue(address, forKey: "full_address")
    }
}

#Preview {
    RegistrationView()
} 
