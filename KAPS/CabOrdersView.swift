import SwiftUI

struct CabOrdersView: View {
    @State private var recentBookings: [Booking] = []
    @State private var pastOrders: [AllGoodsOrders] = []
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("All Cab Rides")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
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
                                BookingItemView(booking: booking)
                                    .onTapGesture {
                                        // Navigate to OngoingGoodsDetailView with cab=true
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
                                PastOrderItemView(order: order)
                                    .onTapGesture {
                                        // Navigate to OrderDetailsView with cab=true
                                    }
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                    }
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
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
            url: APIClient.baseUrl + "customers_all_cab_bookings",
            parameters: parameters
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    recentBookings = results.compactMap { dict in
                        guard let bookingId = dict["booking_id"] as? String,
                              let vehicleName = dict["vehicle_name"] as? String,
                              let vehicleImage = dict["vehicle_image"] as? String,
                              let bookingTiming = dict["booking_timing"] as? String,
                              let totalTime = dict["total_time"] as? String,
                              let bookingStatus = dict["booking_status"] as? String,
                              let totalPrice = dict["total_price"] as? String,
                              let paymentMethod = dict["payment_method"] as? String,
                              let pickupAddress = dict["pickup_address"] as? String,
                              let dropAddress = dict["drop_address"] as? String else {
                            return nil
                        }
                        
                        return Booking(
                            bookingId: bookingId,
                            vehicleName: vehicleName,
                            vehicleImage: vehicleImage,
                            bookingTiming: bookingTiming,
                            totalTime: totalTime,
                            bookingStatus: bookingStatus,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            senderName: "NA",
                            senderNumber: "NA",
                            receiverName: "NA",
                            receiverNumber: "NA",
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
            url: APIClient.baseUrl + "customers_all_cab_orders",
            parameters: parameters
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    pastOrders = results.compactMap { dict in
                        guard let orderId = dict["order_id"] as? String,
                              let vehicleName = dict["vehicle_name"] as? String,
                              let vehicleImage = dict["vehicle_image"] as? String,
                              let bookingTiming = dict["booking_timing"] as? String,
                              let totalTime = dict["total_time"] as? String,
                              let totalPrice = dict["total_price"] as? String,
                              let paymentMethod = dict["payment_method"] as? String,
                              let pickupAddress = dict["pickup_address"] as? String,
                              let dropAddress = dict["drop_address"] as? String else {
                            return nil
                        }
                        
                        return AllGoodsOrders(
                            orderId: orderId,
                            vehicleName: vehicleName,
                            vehicleImage: vehicleImage,
                            bookingTiming: bookingTiming,
                            totalTime: totalTime,
                            totalPrice: totalPrice,
                            paymentMethod: paymentMethod,
                            senderName: "NA",
                            senderNumber: "NA",
                            receiverName: "NA",
                            receiverNumber: "NA",
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

#Preview {
    CabOrdersView()
} 