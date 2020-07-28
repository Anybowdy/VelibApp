//
//  StationMarkerView.swift
//  VelibApp
//
//  Created by Joseph Huang on 30/06/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import UIKit
import MapKit


class StationMarkerView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
      willSet {
        guard let station = newValue as? Station else {
          return
        }
        
        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        rightCalloutAccessoryView = { () -> UIButton in
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35)))
            button.setBackgroundImage(UIImage(named: "google"), for: UIControl.State.normal)
            return button
        }()

        glyphText = "\(station.totalBikesCount)"
        markerTintColor = station.markerTintColor
      }
    }
}
