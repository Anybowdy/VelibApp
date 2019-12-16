import UIKit
import MapKit

class MapVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Data().fetchStationData { (finished) in
            if finished {
                self.setUpAnnotation()
            }
        }
        detectLocation()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthStatus()
        setUpAnnotation()
    }
    
    private func detectLocation() {
        let location = locationManager.location
        let myLocation = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let zoom = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: myLocation, span: zoom)
        mapView.setRegion(region, animated: true)
    }
   
    private func setUpAnnotation() {
        print(Data.stationsList.count)
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
        let lat = view.annotation?.coordinate.latitude
        let long = view.annotation?.coordinate.longitude
        /*for station in Data.stationsList {
            if station.location.latitude == lat && station.location.longitude == long {
                print(station.stationName)
                print(station.nbBikes)
                print(station.nbFreeDocks)
            }
        }*/
        let zoom = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat!, longitude: long!), span: zoom)
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
            annotationView.image = UIImage(named: "placeholder")
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
