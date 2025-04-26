import SwiftUI

struct WalletView: View {
    @State private var walletBalance: Double = 0.0
    @State private var transactions: [WalletTransaction] = []
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showAddMoneySheet = false
    @State private var amountInput = ""
    
    private let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Wallet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                
                // Wallet Balance Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KAPS Credit")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Balance ₹\(String(format: "%.2f", walletBalance))")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAddMoneySheet = true
                    }) {
                        Text("Add Payment")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Colors.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Divider
                Color.gray.opacity(0.1)
                    .frame(height: 10)
                
                // History Section
                HStack {
                    Text("History")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image("ic_notfound")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("Wallet History Not Found")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(transactions) { transaction in
                            WalletTransactionItemView(transaction: transaction)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMoneySheet) {
            AddMoneySheet(amountInput: $amountInput, onAdd: { amount in
                // Handle add money without Razorpay
                showError = true
                errorMessage = "Payment integration is currently unavailable. Please try again later."
            })
        }
        .overlay {
            if showLoading {
                LoadingView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            fetchWalletDetails()
        }
    }
    
    private func fetchWalletDetails() {
        showLoading = true
        let url = URL(string: "\(APIClient.baseUrl)customer_wallet_details")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["customer_id": customerId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                showLoading = false
                
                if let error = error {
                    showError = true
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    showError = true
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let results = json?["results"] as? [String: Any] {
                        if let walletDetails = results["wallet_details"] as? [String: Any],
                           let balance = walletDetails["current_balance"] as? Double {
                            walletBalance = balance
                        }
                        
                        if let history = results["transaction_history"] as? [[String: Any]] {
                            let decoder = JSONDecoder()
                            transactions = try decoder.decode([WalletTransaction].self, from: JSONSerialization.data(withJSONObject: history))
                        }
                    }
                } catch {
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
}

struct AddMoneySheet: View {
    @Binding var amountInput: String
    let onAdd: (Double) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Wallet Amount")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray)
            
            HStack {
                TextField("Enter Amount", text: $amountInput)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(width: 200)
                
                Button(action: {
                    if let amount = Double(amountInput), amount >= 1 {
                        onAdd(amount)
                        dismiss()
                    }
                }) {
                    Text("Add Payment")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Colors.primary)
                        .cornerRadius(12)
                }
            }
            
            Text("Note: This amount will be saved but not used as of now. Because we are using subscription model right now.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.height(200)])
    }
}

struct WalletTransactionItemView: View {
    let transaction: WalletTransaction
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("#\(transaction.razorPayID)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(transaction.transactionType)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(transaction.transactionType == "CREDIT" ? .green : .red)
                    
                    Text(transaction.transactionDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("₹\(String(format: "%.2f", transaction.amount))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(transaction.transactionType == "CREDIT" ? .green : .red)
            }
            .padding(.vertical, 8)
            
            Divider()
        }
    }
}

#Preview {
    WalletView()
} 
