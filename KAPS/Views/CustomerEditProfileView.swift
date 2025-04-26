import SwiftUI

struct CustomerEditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CustomerEditProfileViewModel()
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Personal Details Section
                    SectionView(title: "Personal Details") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $viewModel.customerName,
                                placeholder: "Full Name",
                                keyboardType: .default
                            )
                            
                            CustomTextField(
                                text: .constant(viewModel.mobileNumber),
                                placeholder: "Mobile Number",
                                keyboardType: .phonePad
                            )
                            .disabled(true)
                            
                            CustomTextField(
                                text: $viewModel.email,
                                placeholder: "Email",
                                keyboardType: .emailAddress
                            )
                        }
                    }
                    
                    // Address Details Section
                    SectionView(title: "Address Details") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $viewModel.address,
                                placeholder: "Full Address",
                                keyboardType: .default,
                                isMultiline: true
                            )
                            
                            CustomTextField(
                                text: $viewModel.pincode,
                                placeholder: "Pincode",
                                keyboardType: .numberPad
                            )
                        }
                    }
                    
                    // GST Details Section
                    SectionView(title: "GST Details") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $viewModel.gstNumber,
                                placeholder: "GST Number",
                                keyboardType: .default
                            )
                            
                            CustomTextField(
                                text: $viewModel.gstAddress,
                                placeholder: "GST Address",
                                keyboardType: .default,
                                isMultiline: true
                            )
                        }
                    }
                    
                    // Bank Details Section
                    SectionView(title: "Bank Details") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                text: $viewModel.bankName,
                                placeholder: "Bank Name",
                                keyboardType: .default
                            )
                            
                            CustomTextField(
                                text: $viewModel.accountName,
                                placeholder: "Account Holder Name",
                                keyboardType: .default
                            )
                            
                            CustomTextField(
                                text: $viewModel.accountNumber,
                                placeholder: "Account Number",
                                keyboardType: .numberPad
                            )
                            
                            CustomTextField(
                                text: $viewModel.ifscCode,
                                placeholder: "IFSC Code",
                                keyboardType: .default
                            )
                        }
                    }
                    
                    // Update Button
                    Button(action: {
                        viewModel.updateProfile()
                    }) {
                        Text("Update Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if showLoading {
                    LoadingView()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                viewModel.loadCustomerDetails()
            }
            .onChange(of: viewModel.isLoading) { newValue in
                showLoading = newValue
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if let error = newValue {
                    errorMessage = error
                    showError = true
                }
            }
            .onChange(of: viewModel.isProfileUpdated) { newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - View Model
class CustomerEditProfileViewModel: ObservableObject {
    @Published var customerName = ""
    @Published var mobileNumber = ""
    @Published var email = ""
    @Published var address = ""
    @Published var pincode = ""
    @Published var gstNumber = ""
    @Published var gstAddress = ""
    @Published var bankName = ""
    @Published var accountName = ""
    @Published var accountNumber = ""
    @Published var ifscCode = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isProfileUpdated = false
    
    private let preferenceManager = PreferenceManager.shared
    
    func loadCustomerDetails() {
        guard let customerId = preferenceManager.getStringValue("customer_id"),
              !customerId.isEmpty else {
            errorMessage = "Invalid customer ID"
            return
        }
        
        isLoading = true
        
        let parameters: [String: Any] = ["customer_id": customerId]
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "get_customer_details",
            parameters: parameters
        ) { [weak self] (result: Result<[String: Any], NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    if let customer = response["customer"] as? [String: Any] {
                        self?.populateFields(customer: customer)
                    } else {
                        self?.errorMessage = "Error parsing customer details"
                    }
                case .failure(let error):
                    self?.errorMessage = "Error loading customer details: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func populateFields(customer: [String: Any]) {
        // Only set values if they are not NA or -1
        if let name = customer["customer_name"] as? String, name != "NA", name != "-1" {
            customerName = name
        }
        if let mobile = customer["mobile_no"] as? String, mobile != "NA", mobile != "-1" {
            mobileNumber = mobile
        }
        if let email = customer["email"] as? String, email != "NA", email != "-1" {
            self.email = email
        }
        if let address = customer["full_address"] as? String, address != "NA", address != "-1" {
            self.address = address
        }
        if let pincode = customer["pincode"] as? String, pincode != "NA", pincode != "-1" {
            self.pincode = pincode
        }
        if let gstNo = customer["gst_no"] as? String, gstNo != "NA", gstNo != "-1" {
            self.gstNumber = gstNo
        }
        if let gstAddress = customer["gst_address"] as? String, gstAddress != "NA", gstAddress != "-1" {
            self.gstAddress = gstAddress
        }
        if let bankName = customer["bank_name"] as? String, bankName != "NA", bankName != "-1" {
            self.bankName = bankName
        }
        if let accountName = customer["account_name"] as? String, accountName != "NA", accountName != "-1" {
            self.accountName = accountName
        }
        if let accountNumber = customer["account_number"] as? String, accountNumber != "NA", accountNumber != "-1" {
            self.accountNumber = accountNumber
        }
        if let ifscCode = customer["ifsc_code"] as? String, ifscCode != "NA", ifscCode != "-1" {
            self.ifscCode = ifscCode
        }
    }
    
    func updateProfile() {
        let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
        
        isLoading = true
        
        let parameters: [String: Any] = [
            "customer_id": customerId,
            "customer_name": customerName.isEmpty ? "NA" : customerName,
            "email": email.isEmpty ? "NA" : email,
            "full_address": address.isEmpty ? "NA" : address,
            "gst_no": gstNumber.isEmpty ? "NA" : gstNumber,
            "gst_address": gstAddress.isEmpty ? "NA" : gstAddress,
            "pincode": pincode.isEmpty ? "NA" : pincode,
            "bank_name": bankName.isEmpty ? "NA" : bankName,
            "ifsc_code": ifscCode.isEmpty ? "NA" : ifscCode,
            "account_number": accountNumber.isEmpty ? "NA" : accountNumber,
            "account_name": accountName.isEmpty ? "NA" : accountName
        ]
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "update_customer_details",
            parameters: parameters
        ) { [weak self] (result: Result<[String: Any], NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.isProfileUpdated = true
                case .failure(let error):
                    self?.errorMessage = "Error updating profile: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    var isMultiline: Bool = false
    
    var body: some View {
        if isMultiline {
            TextEditor(text: $text)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                        }
                    },
                    alignment: .topLeading
                )
        } else {
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
        }
    }
}

#Preview {
    CustomerEditProfileView()
} 
