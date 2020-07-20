//
//  MapVC+Location.swift
//  VelibApp
//
//  Created by Joseph Huang on 20/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import MapKit
import CoreLocation

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? Station else { return }

        self.selectedAnnotation = annotation
        
        let currentSpanLat = self.mapView.region.span.latitudeDelta
        let currentSpanLong = self.mapView.region.span.longitudeDelta
        var zoom = MKCoordinateSpan(latitudeDelta: currentSpanLat, longitudeDelta: currentSpanLong)
        if (currentSpanLat > 0.04 || currentSpanLong > 0.04) {
            zoom = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        }
        let region = MKCoordinateRegion(center: annotation.coordinate, span: zoom)
        mapView.setRegion(region, animated: true)
        stationInfoView(shouldShow: true)
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView") {
            return annotationView
        }
        return nil
    }
    
    // Redirect to Plans
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
      let location = view.annotation as! Station
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
