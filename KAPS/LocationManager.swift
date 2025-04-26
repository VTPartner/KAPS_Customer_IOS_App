import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var currentAddress = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // Cache for geocoding results
    private var geocodingCache: [CLLocation: String] = [:]
    private var lastGeocodingTime: Date?
    private let minimumGeocodingInterval: TimeInterval = 2.0 // Minimum 2 seconds between requests
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update only when moved 100 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    private func shouldPerformGeocoding() -> Bool {
        guard let lastTime = lastGeocodingTime else { return true }
        return Date().timeIntervalSince(lastTime) >= minimumGeocodingInterval
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        // Check cache first
        if let cachedAddress = geocodingCache[location] {
            DispatchQueue.main.async {
                self.currentAddress = cachedAddress
            }
            return
        }
        
        // Check rate limiting
        guard shouldPerformGeocoding() else { return }
        
        lastGeocodingTime = Date()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                var addressComponents: [String] = []
                
                if let name = placemark.name { addressComponents.append(name) }
                if let locality = placemark.locality { addressComponents.append(locality) }
                if let postalCode = placemark.postalCode { addressComponents.append(postalCode) }
                if let country = placemark.country { addressComponents.append(country) }
                
                let address = addressComponents.joined(separator: ", ")
                
                // Cache the result
                self.geocodingCache[location] = address
                
                DispatchQueue.main.async {
                    self.currentAddress = address
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
} 