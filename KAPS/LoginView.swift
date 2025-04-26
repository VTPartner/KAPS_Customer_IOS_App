import SwiftUI

struct LoginView: View {
    @State private var phoneNumber = ""
    @State private var selectedCountryCode = CountryCode.defaultCodes[0]
    @State private var showOTPView = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isPhoneNumberFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
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
                        
                        Text("Continue with Phone")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .frame(height: 52)
                    .padding(.horizontal)
                    
                    // Logo and Description
                    VStack(spacing: 20) {
                        Image("logo") // Make sure to add logo to assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                        
                        Text("You'll receive a 6 digit code\nto verify next")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 20)
                    
                    // Phone Input Card
                    VStack(spacing: 20) {
                        Text("Enter Your Phone")
                            .font(.system(size: 12, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 5) {
                            // Country Code Picker
                            Menu {
                                ForEach(CountryCode.defaultCodes) { country in
                                    Button(action: {
                                        selectedCountryCode = country
                                    }) {
                                        HStack {
                                            Text(country.flag)
                                            Text(country.dialCode)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCountryCode.flag)
                                    Text(selectedCountryCode.dialCode)
                                    Image(systemName: "chevron.down")
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            // Phone Number Input
                            TextField("Enter Mobile Number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .focused($isPhoneNumberFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            isPhoneNumberFocused = false
                                        }
                                    }
                                }
                                .onChange(of: phoneNumber) { newValue in
                                    // Remove non-digit characters
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue {
                                        phoneNumber = filtered
                                    }
                                    
                                    // Limit to 10 digits
                                    if filtered.count > 10 {
                                        phoneNumber = String(filtered.prefix(10))
                                    }
                                }
                                .frame(height: 50)
                                .padding(.horizontal, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 25)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 20)
                    
                    // Continue Button
                    Button(action: {
                        if validatePhoneNumber() {
                            showOTPView = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blue)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $showOTPView) {
                SendOTPView(phoneNumber: selectedCountryCode.dialCode + phoneNumber)
            }
        }
    }
    
    private func validatePhoneNumber() -> Bool {
        if phoneNumber.isEmpty {
            errorMessage = "Please enter mobile number"
            showError = true
            return false
        }
        
        if phoneNumber.count != 10 {
            errorMessage = "Mobile number must be 10 digits"
            showError = true
            return false
        }
        
        return true
    }
}

#Preview {
    LoginView()
} 
