import Foundation
import CoreLocation
import Combine

class LocationHelper: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationCallback: ((Result<LocationDetails, Error>) -> Void)?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func getCurrentLocation(completion: @escaping (Result<LocationDetails, Error>) -> Void) {
        locationCallback = completion
        
        // Check location authorization status
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(.failure(NSError(domain: "LocationHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied. Please enable location access in Settings."])))
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            completion(.failure(NSError(domain: "LocationHelper", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"])))
        }
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationCallback?(.failure(NSError(domain: "LocationHelper", code: 3, userInfo: [NSLocalizedDescriptionKey: "No location found"])))
            return
        }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.locationCallback?(.failure(error))
                return
            }
            
            let postalCode = placemarks?.first?.postalCode ?? "0"
            let address = placemarks?.first?.name ?? ""
            
            let locationDetails = LocationDetails(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                address: address,
                postalCode: postalCode
            )
            
            self.locationCallback?(.success(locationDetails))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCallback?(.failure(error))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationCallback?(.failure(NSError(domain: "LocationHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied. Please enable location access in Settings."])))
        default:
            break
        }
    }
}

struct LocationDetails {
    let latitude: Double
    let longitude: Double
    let address: String
    let postalCode: String
} 