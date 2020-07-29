//
//  MapVC+Location.swift
//  VelibApp
//
//  Created by Joseph Huang on 20/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import MapKit

extension MapVC {
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            getStations()
            locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied, .restricted:
            presentAlert()
        default:
            break
        }
        
        
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Confidentialité", message: "Veuillez activer la localisation de votre appareil pour VelibApp", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Réglages", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            UIApplication.shared.openURL(NSURL(string:UIApplication.openSettingsURLString)! as URL)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerOnUserLocation(zoomDelta: userLocationZoom)
    }
}
