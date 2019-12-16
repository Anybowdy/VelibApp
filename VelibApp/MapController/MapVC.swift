import UIKit
import MapKit

class MapVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationAuthStatus()
        detectLocation(zoomDelta: 0.025)
        
        Data().fetchStationData()
        Data.dispatchGroup.notify(queue: .main) {
            self.setUpAnnotation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthStatus()
    }
    
    private func detectLocation(zoomDelta: CLLocationDegrees) {
        let location = locationManager.location
        let myLocation = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let zoom = MKCoordinateSpan(latitudeDelta: zoomDelta, longitudeDelta: zoomDelta)
        let region = MKCoordinateRegion(center: myLocation, span: zoom)
        mapView.setRegion(region, animated: true)
    }
   
    func setUpAnnotation() {
        for station in Data.stationsList {
            let location = station.location
            let annotation = StationAnnotation(title: station.stationName, locationName: station.stationName, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            mapView.addAnnotation(annotation)
        }
    }
    
    private func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}


extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let lat = view.annotation!.coordinate.latitude
        let long = view.annotation!.coordinate.longitude
        let currentSpanLat = self.mapView.region.span.latitudeDelta
        let currentSpanLong = self.mapView.region.span.longitudeDelta
        var zoom = MKCoordinateSpan(latitudeDelta: currentSpanLat, longitudeDelta: currentSpanLong)
        if (currentSpanLat > 0.03 || currentSpanLong > 0.03) {
            zoom = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: zoom)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let goButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35)))
            button.setBackgroundImage(UIImage(named: "google"), for: UIControl.State.normal)
            return button
        }()
        
        let annotationView = { () -> MKAnnotationView in
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            annotationView.image = UIImage(named: "circle")
            annotationView.rightCalloutAccessoryView = goButton
            annotationView.canShowCallout = true
            return annotationView
        }()
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
      let location = view.annotation as! StationAnnotation
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
