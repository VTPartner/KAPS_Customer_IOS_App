import SwiftUI

struct JcbCraneRidesView: View {
    @State private var recentBookings: [JcbCraneBooking] = []
    @State private var pastOrders: [JcbCraneOrder] = []
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Recent Bookings Section
                VStack(spacing: 0) {
                    HStack {
                        Text("Recent Bookings")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    if recentBookings.isEmpty {
                        VStack(spacing: 20) {
                            Image("ic_notfound")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("No recent orders found")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(recentBookings) { booking in
                                JcbCraneBookingItemView(booking: booking)
                                    .onTapGesture {
                                        // Navigate to JcbCraneBookingDetailsView
                                    }
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                    }
                }
                
                // Past Orders Section
                VStack(spacing: 0) {
                    HStack {
                        Text("Delivered Orders")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    if pastOrders.isEmpty {
                        VStack(spacing: 20) {
                            Image("ic_notfound")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("No Order History Found\nPlease start booking.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(pastOrders) { order in
                                JcbCraneOrderItemView(order: order)
                                    .onTapGesture {
                                        // Navigate to JcbCraneOrderDetailsView
                                    }
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                    }
                }
            }
        }
        .background(Color.white)
        .navigationTitle("All JCB/Crane Rides")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchData()
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
    }
    
    private func fetchData() {
        fetchRecentBookings()
        fetchPastOrders()
    }
    
    private func fetchRecentBookings() {
        showLoading = true
        let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
        let parameters: [String: Any] = ["customer_id": customerId]
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "customers_all_jcb_crane_bookings",
            parameters: parameters
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    recentBookings = results.compactMap { dict in
                        guard let bookingId = dict["booking_id"] as? String,
                              let bookingTiming = dict["booking_timing"] as? String,
                              let bookingStatus = dict["booking_status"] as? String,
                              let totalPrice = dict["total_price"] as? String,
                              let paymentMethod = dict["payment_method"] as? String,
                              let serviceName = dict["service_name"] as? String,
                              let subCategoryName = dict["sub_cat_name"] as? String,
                              let distance = dict["distance"] as? String,
                              let totalTime = dict["total_time"] as? String,
                              let pickupAddress = dict["pickup_address"] as? String else {
                            return nil
                        }
                        
                        return JcbCraneBooking(
                            bookingId: bookingId,
                            bookingTiming: bookingTiming,
                            bookingStatus: bookingStatus,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            serviceName: serviceName,
                            subCategoryName: subCategoryName,
                            distance: distance,
                            totalTime: totalTime,
                            pickupAddress: pickupAddress
                        )
                    }.filter { $0.bookingStatus != "End Trip" }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func fetchPastOrders() {
        showLoading = true
        let customerId = PreferenceManager.shared.getStringValue("customer_id") ?? ""
        let parameters: [String: Any] = ["customer_id": customerId]
        
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "customers_all_jcb_crane_orders",
            parameters: parameters
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    pastOrders = results.compactMap { dict in
                        guard let orderId = dict["order_id"] as? String,
                              let bookingTiming = dict["booking_timing"] as? String,
                              let bookingStatus = dict["booking_status"] as? String,
                              let totalPrice = dict["total_price"] as? String,
                              let paymentMethod = dict["payment_method"] as? String,
                              let serviceName = dict["service_name"] as? String,
                              let subCategoryName = dict["sub_cat_name"] as? String,
                              let distance = dict["distance"] as? String,
                              let totalTime = dict["total_time"] as? String,
                              let pickupAddress = dict["pickup_address"] as? String else {
                            return nil
                        }
                        
                        return JcbCraneOrder(
                            orderId: orderId,
                            bookingTiming: bookingTiming,
                            bookingStatus: bookingStatus,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            serviceName: serviceName,
                            subCategoryName: subCategoryName,
                            distance: distance,
                            totalTime: totalTime,
                            pickupAddress: pickupAddress
                        )
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct JcbCraneBookingItemView: View {
    let booking: JcbCraneBooking
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("# CRN \(booking.bookingId)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(formatDateTime(booking.bookingTiming))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(booking.serviceName.isEmpty ? booking.subCategoryName : "\(booking.subCategoryName) / \(booking.serviceName)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(formatCurrency(booking.totalPrice))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Colors.primaryDark)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            // Work Location
            HStack {
                Image(systemName: "location.fill")
                    .renderingMode(.template)
                    .foregroundColor(Colors.primaryDark)
                    .frame(width: 18, height: 18)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Work Location")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text(booking.pickupAddress)
                        .font(.system(size: 11))
                        .foregroundColor(.black)
                }
                .padding(.leading, 5)
                
                Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            
            // Status and Distance Section
            HStack {
                Image(systemName: "circle.fill")
                    .renderingMode(.template)
                    .foregroundColor(Colors.statusGreen)
                    .frame(width: 18, height: 18)
                
                Text(booking.bookingStatus)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                
                Spacer()
                
//                Text("\(booking.distance) km")
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
            }
            .padding(10)
        }
        .background(Color.white)
        .padding(.horizontal, 2)
        .padding(.vertical, 5)
    }
    
    private func formatDateTime(_ timestamp: String) -> String {
        guard let epochTime = Double(timestamp.components(separatedBy: ".")[0]) else {
            return timestamp
        }
        
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd, hh:mm a"
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: String) -> String {
        guard let value = Double(amount) else {
            return "₹\(amount)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "₹\(amount)"
    }
}

struct JcbCraneOrderItemView: View {
    let order: JcbCraneOrder
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("# CRN \(order.orderId)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(formatDateTime(order.bookingTiming))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(order.serviceName.isEmpty ? order.subCategoryName : "\(order.subCategoryName) / \(order.serviceName)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(formatCurrency(order.totalPrice))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Colors.primaryDark)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            // Work Location
            HStack {
                Image(systemName: "location.fill")
                    .renderingMode(.template)
                    .foregroundColor(Colors.primaryDark)
                    .frame(width: 18, height: 18)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Work Location")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text(order.pickupAddress)
                        .font(.system(size: 11))
                        .foregroundColor(.black)
                }
                .padding(.leading, 5)
                
                Spacer()
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            
            // Status and Distance Section
            HStack {
                Image(systemName: "circle.fill")
                    .renderingMode(.template)
                    .foregroundColor(Colors.statusGreen)
                    .frame(width: 18, height: 18)
                
                Text("Delivered")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                
                Spacer()
                
//                Text("\(order.distance) km")
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
            }
            .padding(10)
            
            // Payment Method
            if order.paymentMethod != "NA" {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .renderingMode(.template)
                        .foregroundColor(Colors.statusGreen)
                        .frame(width: 18, height: 18)
                    
                    Text(order.paymentMethod)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(8)
            }
        }
        .background(Color.white)
        .padding(.horizontal, 2)
        .padding(.vertical, 5)
    }
    
    private func formatDateTime(_ timestamp: String) -> String {
        guard let epochTime = Double(timestamp.components(separatedBy: ".")[0]) else {
            return timestamp
        }
        
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd, hh:mm a"
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: String) -> String {
        guard let value = Double(amount) else {
            return "₹\(amount)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "₹\(amount)"
    }
}

#Preview {
    JcbCraneRidesView()
} 
