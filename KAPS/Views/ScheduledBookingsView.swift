import SwiftUI

struct ScheduledBookingsView: View {
    @State private var scheduledBookings: [ScheduledBooking] = []
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    private let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if scheduledBookings.isEmpty {
                    VStack(spacing: 20) {
                        Image("ic_notfound")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("No Scheduled Bookings")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.05))
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(scheduledBookings) { booking in
                            ScheduledBookingItemView(booking: booking)
                                .onTapGesture {
                                    navigateToBookingDetails(booking)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Scheduled Bookings")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            fetchScheduledBookings()
        }
        .overlay {
            if showLoading {
                LoadingView()
            }
        }
    }
    
    private func fetchScheduledBookings() {
        showLoading = true
        let url = URL(string: "\(APIClient.baseUrl)get_scheduled_bookings")!
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
                    if let status = json?["status"] as? Bool, status {
                        if let bookingsData = json?["data"] as? [[String: Any]] {
                            let decoder = JSONDecoder()
                            let bookings = try decoder.decode([ScheduledBooking].self, from: JSONSerialization.data(withJSONObject: bookingsData))
                            scheduledBookings = bookings
                        }
                    } else {
                        showError = true
                        errorMessage = "Failed to fetch bookings"
                    }
                } catch {
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }
    
    private func navigateToBookingDetails(_ booking: ScheduledBooking) {
        // Navigation logic based on category_id
        // This will be implemented when the detail views are created
    }
}

struct ScheduledBookingItemView: View {
    let booking: ScheduledBooking
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                AsyncImage(url: URL(string: booking.categoryImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.serviceName.isEmpty ? 
                         booking.subCatName : 
                         "\(booking.subCatName) / \(booking.serviceName)")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("# CRN \(booking.bookingId)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(formatCurrency(booking.totalPrice))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Colors.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.horizontal)
            
            // Details
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                    Text(formatDateTime(booking.scheduledTime))
                        .font(.system(size: 14))
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    Text(booking.pickupAddress)
                        .font(.system(size: 14))
                }
                
                if booking.categoryId == "1" || booking.categoryId == "2" {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.red)
                        Text(booking.dropAddress ?? "")
                            .font(.system(size: 14))
                    }
                }
                
                Text(booking.bookingStatus)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Colors.primary)
                    .cornerRadius(12)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func formatDateTime(_ timestamp: String) -> String {
        guard let epochTime = Double(timestamp) else { return timestamp }
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd, hh:mm a"
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: String) -> String {
        guard let value = Double(amount) else { return "₹\(amount)" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "₹\(amount)"
    }
}

#Preview {
    ScheduledBookingsView()
} 
