import Foundation
import CoreLocation
import MapKit

class SBAddressViewModel: NSObject, ObservableObject {
    @Published var currentAddress: String = ""
    @Published var isLoadingLocation = false
    @Published var locationError: String?
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -121.8907),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoadingLocation = true
        locationError = nil
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            isLoadingLocation = false
            locationError = "Location access denied. Please enable it in Settings."
        @unknown default:
            isLoadingLocation = false
            locationError = "Unknown location authorization status"
        }
    }
    
    func geocodeAddress(_ address: String) {
        isLoadingLocation = true
        locationError = nil
        
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                
                if let error = error {
                    self?.locationError = error.localizedDescription
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    self?.locationError = "Could not find location for this address"
                    return
                }
                
                self?.coordinate = location.coordinate
                self?.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                // Format and set the address
                if let formattedAddress = self?.formatAddress(from: placemark) {
                    self?.currentAddress = formattedAddress
                }
            }
        }
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                
                if let error = error {
                    self?.locationError = error.localizedDescription
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    self?.locationError = "No address found"
                    return
                }
                
                let address = self?.formatAddress(from: placemark)
                self?.currentAddress = address ?? ""
                self?.coordinate = location.coordinate
                self?.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []

        // House number and street
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }

        // Neighborhood or sublocality
        if let subLocality = placemark.subLocality {
            components.append(subLocality)
        }

        // City / town
        if let locality = placemark.locality {
            components.append(locality)
        }

        // State or province
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }

        // Postal code
        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        // Country
        if let country = placemark.country {
            components.append(country)
        }

        // Join all non-empty components with commas
        return components.joined(separator: ", ")
    }
}

extension SBAddressViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        geocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoadingLocation = false
            self.locationError = error.localizedDescription
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isLoadingLocation = false
            locationError = "Location access denied. Please enable it in Settings."
        default:
            break
        }
    }
}
 