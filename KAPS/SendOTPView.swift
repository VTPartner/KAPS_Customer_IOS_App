import SwiftUI
import Combine

struct SendOTPView: View {
    let phoneNumber: String
    @State private var otpFields: [String] = Array(repeating: "", count: 6)
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var timer: Timer?
    @State private var timeRemaining = 60
    @State private var isTimerActive = true
    @State private var showLoading = false
    @State private var receivedOTP: String?
    @State private var isResendVisible = false
    @State private var isSubmitVisible = true
    @State private var isTimerVisible = true
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Int?
    @State private var showHomeView = false
    @State private var showRegistrationView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Logo and Message
                    VStack(spacing: 20) {
                        Image("one1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 142)
                            .padding(.horizontal)
                        
                        Text("We have sent you an SMS on \(phoneNumber)\nwith 6 digit verification code")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // OTP Input Fields
                        HStack(spacing: 5) {
                            ForEach(0..<6) { index in
                                OTPTextField(
                                    text: $otpFields[index],
                                    isLast: index == 5,
                                    isFocused: Binding(
                                        get: { focusedField == index },
                                        set: { if $0 { focusedField = index } }
                                    )
                                )
                                .onChange(of: otpFields[index]) { newValue in
                                    handleOTPInput(index: index, value: newValue)
                                }
                                .focused($focusedField, equals: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 25)
                    
                    Spacer()
                    
                    // Bottom Section
                    VStack(spacing: 20) {
                        Text("Did not receive the code?")
                            .foregroundColor(.black)
                        
                        if isResendVisible {
                            Button(action: {
                                resendOTP()
                            }) {
                                Text("Resend OTP")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 10)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if isTimerVisible {
                            Text("\(timeRemaining) Second Wait")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 10)
                                .padding(.horizontal, 20)
                        }
                        
                        if isSubmitVisible {
                            Button(action: {
                                print("Submit button pressed")
                                verifyOTP()
                            }) {
                                Text("Submit")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color.blue)
                                    .cornerRadius(24)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                        }
                    }
                    .padding(.bottom, 25)
                }
            }
            .background(Color.white)
            .navigationTitle("Verify Phone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Verify Phone")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationDestination(isPresented: $showHomeView) {
                HomeView()
            }
            .navigationDestination(isPresented: $showRegistrationView) {
                 RegistrationView()
                
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {
                if showLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .onAppear {
                print("SendOTPView appeared")
                sendOTP()
                startTimer()
                // Focus first field on appear
                focusedField = 0
            }
            .onDisappear {
                print("SendOTPView disappeared")
                timer?.invalidate()
            }
        }
    }
    
    private func handleOTPInput(index: Int, value: String) {
        print("OTP input changed at index \(index): \(value)")
        // Handle paste
        if value.count > 1 {
            let filtered = value.filter { $0.isNumber }
            if filtered.count >= 6 {
                print("Pasting complete OTP: \(filtered)")
                // Fill all fields with the pasted OTP
                for i in 0..<6 {
                    if i < filtered.count {
                        otpFields[i] = String(filtered[filtered.index(filtered.startIndex, offsetBy: i)])
                    }
                }
                // Focus last field
                focusedField = 5
                // Verify OTP after pasting
                verifyOTP()
                return
            }
        }
        
        // Handle single digit input
        let filtered = value.filter { $0.isNumber }
        if filtered != value {
            otpFields[index] = filtered
            return
        }
        
        // Limit to 1 digit
        if filtered.count > 1 {
            otpFields[index] = String(filtered.prefix(1))
        }
        
        // Move to next field if current is filled
        if !filtered.isEmpty && index < 5 {
            focusedField = index + 1
        }
        
        // Move to previous field if current is empty and backspace was pressed
        if filtered.isEmpty && index > 0 {
            focusedField = index - 1
        }
        
        // Check if all fields are filled
        let completeOTP = otpFields.joined()
        if completeOTP.count == 6 {
            print("All OTP fields filled: \(completeOTP)")
            verifyOTP()
        }
    }
    
    private func verifyOTP() {
        print("Verifying OTP...")
        let enteredOTP = otpFields.joined()
        
        if enteredOTP.count != 6 {
            print("Invalid OTP length: \(enteredOTP.count)")
            errorMessage = "Please enter complete OTP"
            showError = true
            return
        }
        
        if let receivedOTP = receivedOTP {
            if enteredOTP != receivedOTP {
                print("OTP mismatch. Entered: \(enteredOTP), Received: \(receivedOTP)")
                errorMessage = "Invalid OTP"
                showError = true
                return
            }
        }
        
        showLoading = true
        verifyOTPAndLogin(otp: enteredOTP)
    }
    
    private func verifyOTPAndLogin(otp: String) {
        print("Verifying OTP and logging in...")
        let parameters: [String: Any] = [
            "mobile_no": phoneNumber
        ]
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "login",
            parameters: parameters
        ) { result in
            showLoading = false
            switch result {
            case .success(let response):
                print("Login response received: \(response ?? [:])")
                handleLoginResponse(response: response)
            case .failure(let error):
                print("Login error: \(error.localizedDescription)")
                handleError(error: error)
            }
        }
    }
    
    private func handleLoginResponse(response: [String: Any]? = nil) {
        print("Handling login response...")
        if let results = response?["results"] as? [[String: Any]], !results.isEmpty {
            print("Found results array")
            let user = results[0]
            saveUserDetails(user: user)
            
            if let customerName = user["customer_name"] as? String,
               !customerName.isEmpty && customerName != "NA" {
                print("Navigating to home view")
                navigateToHome()
            } else {
                print("Navigating to registration view")
                navigateToRegistration()
            }
        } else if let result = response?["result"] as? [[String: Any]], !result.isEmpty {
            print("Found result array")
            let user = result[0]
            saveUserDetails(user: user)
            print("Navigating to registration view")
            navigateToRegistration()
        } else {
            print("Invalid response format")
            errorMessage = "Invalid response format"
            showError = true
        }
    }
    
    private func saveUserDetails(user: [String: Any]) {
        print("Saving user details...")
        if let customerId = user["customer_id"] as? Int {
            print("Saving customer_id: \(customerId)")
            PreferenceManager.shared.setStringValue(String(customerId), forKey: "customer_id")
        }
        if let customerName = user["customer_name"] as? String {
            print("Saving customer_name: \(customerName)")
            PreferenceManager.shared.setStringValue(customerName, forKey: "customer_name")
        }
        if let profilePic = user["profile_pic"] as? String {
            print("Saving profile_pic: \(profilePic)")
            PreferenceManager.shared.setStringValue(profilePic, forKey: "profile_pic")
        }
        print("Saving phone number: \(phoneNumber)")
        PreferenceManager.shared.setStringValue(phoneNumber, forKey: "customer_mobile_no")
        
        if let fullAddress = user["full_address"] as? String {
            print("Saving full_address: \(fullAddress)")
            PreferenceManager.shared.setStringValue(fullAddress, forKey: "full_address")
        }
        if let email = user["email"] as? String {
            print("Saving email: \(email)")
            PreferenceManager.shared.setStringValue(email, forKey: "email")
        }
        if let gstNo = user["gst_no"] as? String {
            print("Saving gst_no: \(gstNo)")
            PreferenceManager.shared.setStringValue(gstNo, forKey: "gst_no")
        }
        if let gstAddress = user["gst_address"] as? String {
            print("Saving gst_address: \(gstAddress)")
            PreferenceManager.shared.setStringValue(gstAddress, forKey: "gst_address")
        }
    }
    
    private func navigateToHome() {
        print("Setting showHomeView to true")
        showHomeView = true
    }
    
    private func navigateToRegistration() {
        print("Setting showRegistrationView to true")
        showRegistrationView = true
    }
    
    private func handleError(error: NetworkError) {
        PreferenceManager.shared.setStringValue("", forKey: "customer_id")
        PreferenceManager.shared.setStringValue("", forKey: "customer_name")
        errorMessage = "Error: \(error.localizedDescription)"
        showError = true
    }
    
    private func sendOTP() {
        showLoading = true
        
        // Special case for testing
//        if phoneNumber == "8296565587" {
//            verifyOTPAndLogin(otp: "")
//            return
//        }
//        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "send_otp",
            parameters: ["mobile_no": phoneNumber]
        ) { result in
            showLoading = false
            switch result {
            case .success(let response):
                print("OTP Response: \(response)")
                
                // Check if response contains the required fields
                if let message = response["message"] as? String,
                   let otp = response["otp"] as? String {
                    receivedOTP = otp
                    print("Received OTP: \(otp)")
                    // Show success message
                } else if let message = response["message"] as? String,
                          let otp = response["otp"] as? Int {
                    // Handle case where OTP is returned as Int
                    receivedOTP = String(otp)
                    print("Received OTP: \(receivedOTP ?? "")")
                    // Show success message
                } else {
                    print("Invalid OTP response format: \(response)")
                    errorMessage = "Failed to send OTP. Please try again."
                    showError = true
                }
                
            case .failure(let error):
                print("OTP Error: \(error.localizedDescription)")
                errorMessage = "Failed to send OTP: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func resendOTP() {
        isResendVisible = false
        isTimerVisible = true
        isSubmitVisible = true
        timeRemaining = 60
        startTimer()
        sendOTP()
        clearOTPFields()
    }
    
    private func clearOTPFields() {
        otpFields = Array(repeating: "", count: 6)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isResendVisible = true
                isTimerVisible = false
                timer?.invalidate()
            }
        }
    }
}

struct OTPTextField: View {
    @Binding var text: String
    let isLast: Bool
    @Binding var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .frame(width: 45, height: 45)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(text)) { newValue in
                let filtered = newValue.filter { $0.isNumber }
                if filtered != newValue {
                    text = filtered
                }
            }
    }
}

#Preview {
    SendOTPView(phoneNumber: "+91 9876543210")
} 
