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
            //centerOnUserLocation(zoomDelta: userLocationZoom)
            break
        case .denied, .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }

}
