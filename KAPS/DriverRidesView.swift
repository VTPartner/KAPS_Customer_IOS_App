import SwiftUI

struct DriverRidesView: View {
    @State private var recentBookings: [DriverBooking] = []
    @State private var pastOrders: [DriverOrder] = []
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
//                HStack {
//                    Spacer()
//                    Text("All Driver Rides")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.black)
//                    Spacer()
//                }
//                .padding()
//                .background(Color.white)
//                
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
                                DriverBookingItemView(booking: booking)
                                    .onTapGesture {
                                        // Navigate to DriverOngoingBookingDetailsView
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
                                DriverOrderItemView(order: order)
                                    .onTapGesture {
                                        // Navigate to DriverOrderDetailsView
                                    }
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                    }
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("All Driver Rides")
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
            url: APIClient.baseUrl + "customers_all_other_driver_bookings",
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
                              let pickupAddress = dict["pickup_address"] as? String,
                              let dropAddress = dict["drop_address"] as? String else {
                            return nil
                        }
                        
                        return DriverBooking(
                            bookingId: bookingId,
                            bookingTiming: bookingTiming,
                            bookingStatus: bookingStatus,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            serviceName: serviceName,
                            subCategoryName: subCategoryName,
                            distance: distance,
                            totalTime: totalTime,
                            pickupAddress: pickupAddress,
                            dropAddress: dropAddress
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
            url: APIClient.baseUrl + "customers_all_other_driver_orders",
            parameters: parameters
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    pastOrders = results.compactMap { dict in
                        guard let bookingId = dict["booking_id"] as? String,
                              let bookingTiming = dict["booking_timing"] as? String,
                              let bookingStatus = dict["booking_status"] as? String,
                              let totalPrice = dict["total_price"] as? String,
                              let paymentMethod = dict["payment_method"] as? String,
                              let serviceName = dict["service_name"] as? String,
                              let subCategoryName = dict["sub_cat_name"] as? String,
                              let distance = dict["distance"] as? String,
                              let totalTime = dict["total_time"] as? String,
                              let pickupAddress = dict["pickup_address"] as? String,
                              let dropAddress = dict["drop_address"] as? String else {
                            return nil
                        }
                        
                        return DriverOrder(
                            bookingId: bookingId,
                            bookingTiming: bookingTiming,
                            bookingStatus: bookingStatus,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            serviceName: serviceName,
                            subCategoryName: subCategoryName,
                            distance: distance,
                            totalTime: totalTime,
                            pickupAddress: pickupAddress,
                            dropAddress: dropAddress
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

struct DriverBookingItemView: View {
    let booking: DriverBooking
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("# \(booking.bookingId)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(formatDateTime(booking.bookingTiming))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(booking.serviceName) - \(booking.subCategoryName)")
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
            
            // Pickup Location
            HStack {
                Image("ic_current_long")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup Location")
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
            
            // Drop Location
            HStack {
                Image("ic_destination_long")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Drop Location")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text(booking.dropAddress)
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
                Image(systemName: "timelapse")
                    .renderingMode(.template)
                    .foregroundColor(Colors.statusGreen)
                    .frame(width: 18, height: 18)
                
                Text(booking.bookingStatus)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                
                Spacer()
                
                Text("\(booking.distance) km")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(10)
            
            // Payment Method
            if booking.paymentMethod != "NA" {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .renderingMode(.template)
                        .foregroundColor(Colors.statusGreen)
                        .frame(width: 18, height: 18)
                    
                    Text(booking.paymentMethod)
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

struct DriverOrderItemView: View {
    let order: DriverOrder
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("# \(order.bookingId)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(formatDateTime(order.bookingTiming))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(order.serviceName) - \(order.subCategoryName)")
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
            
            // Pickup Location
            HStack {
                Image("ic_current_long")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pickup Location")
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
            
            // Drop Location
            HStack {
                Image("ic_destination_long")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Drop Location")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text(order.dropAddress)
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
                Image(systemName: "timelapse")
                    .renderingMode(.template)
                    .foregroundColor(Colors.statusGreen)
                    .frame(width: 18, height: 18)
                
                Text("Delivered")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                
                Spacer()
                
                Text("\(order.distance) km")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
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
    DriverRidesView()
} 
