import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var showLocationAlert = false
    @State private var showLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var services: [ServiceModel] = []
    @State private var offers: [OfferModel] = []
    @State private var isLiveRide = false
    @State private var currentBookingId: String = ""
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                HomeTabView(
                    locationManager: locationManager,
                    services: services,
                    offers: offers,
                    isLiveRide: isLiveRide,
                    currentBookingId: currentBookingId
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // Goods Orders Tab
                GoodsOrdersView()
                    .tabItem {
                        Image(systemName: "box.truck.fill")
                        Text("Goods")
                    }
                    .tag(1)
                
                // Cab Orders Tab
                CabOrdersView()
                    .tabItem {
                        Image(systemName: "car.fill")
                        Text("Cab")
                    }
                    .tag(2)
                
                // Account Settings Tab
                AccountSettingsView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
                    .tag(3)
            }
            .accentColor(Colors.primary)
            .onAppear {
                checkLocationAuthorization()
                fetchServices()
                fetchOffers()
                checkLiveRide()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Location Access Required", isPresented: $showLocationAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location access in Settings to use this app.")
            }
            .overlay {
                if showLoading {
                    LoadingView()
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func fetchServices() {
        showLoading = true
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "all_services",
            parameters: [:]
        ) { (result: Result<[String: Any], NetworkError>) in
            showLoading = false
            switch result {
            case .success(let response):
                if let results = response["results"] as? [[String: Any]] {
                    services = results.compactMap { dict in
                        guard let categoryId = dict["category_id"] as? Int,
                              let categoryName = dict["category_name"] as? String,
                              let categoryImage = dict["category_image"] as? String,
                              let description = dict["description"] as? String else {
                            return nil
                        }
                        return ServiceModel(
                            categoryId: categoryId,
                            categoryName: categoryName,
                            categoryImage: categoryImage,
                            description: description
                        )
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func fetchOffers() {
        NetworkManager.shared.postRequest(
            url: APIClient.baseUrl + "get_all_banners",
            parameters: [:]
        ) { (result: Result<[String: Any], NetworkError>) in
            switch result {
            case .success(let response):
                if let banners = response["banners"] as? [[String: Any]] {
                    offers = banners.compactMap { dict in
                        guard let bannerImage = dict["banner_image"] as? String,
                              let bannerTitle = dict["banner_title"] as? String,
                              let bannerDescription = dict["banner_description"] as? String,
                              let status = dict["status"] as? Int,
                              let startDate = dict["start_date"] as? String,
                              let endDate = dict["end_date"] as? String else {
                            return nil
                        }
                        return OfferModel(
                            bannerImage: bannerImage,
                            bannerTitle: bannerTitle,
                            bannerDescription: bannerDescription,
                            status: status,
                            startDate: startDate,
                            endDate: endDate
                        )
                    }.filter { banner in
                        banner.status == 1 && isDateValid(startDate: banner.startDate, endDate: banner.endDate)
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func isDateValid(startDate: String, endDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let start = dateFormatter.date(from: startDate),
              let end = dateFormatter.date(from: endDate) else {
            return true
        }
        
        let current = Date()
        return (current >= start && current <= end)
    }
    
    private func checkLiveRide() {
        isLiveRide = PreferenceManager.shared.getBooleanValue("live_ride") ?? false
        currentBookingId = PreferenceManager.shared.getStringValue("current_booking_id") ?? ""
    }
}

struct HomeTabView: View {
    @ObservedObject var locationManager: LocationManager
    let services: [ServiceModel]
    let offers: [OfferModel]
    let isLiveRide: Bool
    let currentBookingId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Location Header
                LocationHeaderView(address: locationManager.currentAddress)
                
                // Services Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Hello 👋,\n\(PreferenceManager.shared.getStringValue( "customer_name") ?? "")")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal)
                        .padding(.top, 15)
                    
                    ServicesGridView(services: services)
                        .padding(.horizontal)
                }
                
                // Offers Section
                HStack {
                    Text("Our Offers")
                        .font(.system(size: 16, weight: .bold))
                    
                    Spacer()
                    
                    if isLiveRide {
                        LiveRideButton(currentBookingId: currentBookingId)
                    }
                }
                .padding()
                
                OffersCarouselView(offers: offers)
                    .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
        }
        .background(Color.white)
    }
}

// Models
struct ServiceModel: Codable, Identifiable {
    let id = UUID()
    let categoryId: Int
    let categoryName: String
    let categoryImage: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case categoryImage = "category_image"
        case description
    }
}

struct OfferModel: Codable, Identifiable {
    let id = UUID()
    let bannerImage: String
    let bannerTitle: String
    let bannerDescription: String
    let status: Int
    let startDate: String
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case bannerImage = "banner_image"
        case bannerTitle = "banner_title"
        case bannerDescription = "banner_description"
        case status
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct ServicesResponse: Codable {
    let results: [ServiceModel]
}

struct BannersResponse: Codable {
    let banners: [OfferModel]
}

#Preview {
    HomeView()
} 
