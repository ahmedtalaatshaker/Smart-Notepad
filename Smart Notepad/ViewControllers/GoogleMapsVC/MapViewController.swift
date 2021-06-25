//
//  GoogleMapViewController.swift
//  Smart Notepad
//
//  Created by ahmed talaat on 23/06/2021.
//

import UIKit
import GoogleMaps

protocol didSelectAddress {
    func selectAddress(latitude:Double,longitude:Double,address:String)
}
class GoogleMapViewController: MainViewController{
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLocationLabel: UILabel!

    var delegate : didSelectAddress?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var zoomLevel: Float = 15.0
    var governorate: String?
    var lat :Float = 0.0
    var lng :Float = 0.0
    var address = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initMap() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self


        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        
        if address != "" {
            locateWithLongitude(Double(lng), andLatitude: Double(lat), andTitle: address)
        }
    }
    
    var marker = GMSMarker()
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.mapView.clear()
            let camera = GMSCameraPosition.camera(withLatitude: lat,
                                                  longitude: lon,
                                                  zoom: self.zoomLevel)

            self.mapView.animate(to: camera)

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: CLLocationDegrees(lon))
            self.moveMarkerToLocation(location: coordinate)
            self.currentLocationLabel.text = title
            self.marker.map = self.mapView

        }
    }
    
    @IBAction func confirm(_ sender: Any) {
        if (currentLocation != nil) {
            delegate?.selectAddress(latitude: (currentLocation?.latitude.magnitude)!, longitude: (currentLocation?.longitude.magnitude)!, address: currentLocationLabel.text!)
            navigationController?.popViewController(animated: true)
        }
    }
}


extension GoogleMapViewController: CLLocationManagerDelegate, GMSMapViewDelegate {

    func moveMarkerToLocation(location: CLLocationCoordinate2D) {
        mapView.clear()

        let mapMarker = GMSMarker(position: location)
        mapMarker.map = mapView


        getAddressFor(location: location) { (obtainedAddress, governorate) in
            self.currentLocationLabel.text = obtainedAddress
            self.governorate = governorate
            mapMarker.title = "Address : \(obtainedAddress)"

        }
        self.currentLocation = location
        
        
    }

    func getAddressFor(location: CLLocationCoordinate2D,
                       completionHandler: @escaping (_ address: String, _ governorate: String) -> ()) {

        let geocoder = GMSGeocoder()


        var obtainedAddress = ""
        var governorate = ""
        geocoder.reverseGeocodeCoordinate(location) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]

                obtainedAddress = lines.joined(separator: "\n")
                governorate = address.lines?.last ?? ""
                completionHandler(obtainedAddress, governorate)
            }
        }


        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: zoomLevel)

        mapView.animate(to: camera)

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        moveMarkerToLocation(location: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            break
        case .denied:
            break
        case .notDetermined:
            break
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.didTapMyLocationButton(for: self.mapView)
            }
            print("Location status is OK.")
            break
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {

        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: zoomLevel)

        mapView.animate(to: camera)

        moveMarkerToLocation(location: coordinate)


    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {

        if mapView.myLocation?.coordinate != nil {
            moveMarkerToLocation(location: (mapView.myLocation?.coordinate)!)
        }else{
            self.AlertWith2ButtonsAndActionFirstButton(title: "Allow Access to Location", message: "Please Allow Access to Location to get nearest note", VC: self, B1Action: {
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }, B1Title: "Settings", B2Action: {
//                self.viewModel.Authorized = false
//                self.viewModel.getNearestNote(Authorized: self.viewModel.Authorized)
            }, B2Title: "Cancel")

        }

        return true
    }


}
