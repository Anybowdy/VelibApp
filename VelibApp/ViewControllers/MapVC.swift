import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    var stations: [Station] = [] {
        didSet {
            setUpAnnotation()
            myPositionButton.isEnabled = true
            closestStationButton.isEnabled = true
            self.centerOnUserLocation(zoomDelta: userLocationZoom)
        }
    }
    
    let locationManager = CLLocationManager()
    var selectedAnnotation: Station?
    
    var indicatorView = UIActivityIndicatorView()
    
    let annotationView: MKAnnotationView = {
        let goButton = { () -> UIButton in
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35)))
            button.setBackgroundImage(UIImage(named: "google"), for: UIControl.State.normal)
            return button
        }()
        
        let annotationView = MKAnnotationView()
        annotationView.image = UIImage(named: "bubble")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = goButton
        return annotationView
    }()

    let userLocationZoom = 0.02
    
    // MARK: -Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewCenter: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    // MARK: -Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
        
        getStations()
        setUpView()
    }
    
    // MARK: -UI
    
    func setUpView() {
        indicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicatorView.hidesWhenStopped = true
        indicatorView.center = view.center
        indicatorView.style = UIActivityIndicatorView.Style.gray
        indicatorView.startAnimating()
        
        infoViewCenter.constant = 300
        infoView.layer.cornerRadius = 20
        infoView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        view.addSubview(indicatorView)
    }
    
    func centerOnUserLocation(zoomDelta: CLLocationDegrees) {
        if let userLocation = locationManager.location?.coordinate {
            let zoom = MKCoordinateSpan(latitudeDelta: zoomDelta, longitudeDelta: zoomDelta)
            let region = MKCoordinateRegion(center: userLocation, span: zoom)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getStations() {
        Station.fetchStationsData { stations in
            DispatchQueue.main.async {
                self.stations = stations
                print(stations.count)
            }
        }
    }

    
    func setUpAnnotation() {
        indicatorView.stopAnimating()
        mapView.addAnnotations(stations)
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            centerOnUserLocation(zoomDelta: userLocationZoom)
            break
        case .denied, .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }
    
    // MARK: INFORMATION VIEW

    private func showInfoView(station: Station) {
        nbEBikesLabel.text = String(station.eBike)
        nbBikesLabel.text = String(station.mechanical)
        nbDocksLabel.text = String(station.numdocksavailable)
        
        infoViewCenter.constant = 148
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideInfoView() {
        infoViewCenter.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: -Actions
    
    @IBAction func myPositionButtonTapped(_ sender: Any) {
        mapView.deselectAnnotation(self.selectedAnnotation, animated: true)
        hideInfoView()
        centerOnUserLocation(zoomDelta: userLocationZoom)
    }
    
    
    @IBAction func closestStationButtonTapped(_ sender: Any) {
        if (stations.isEmpty) {
            return
        }
        let closestStation = stations.first
        //let test = stations.min(by: { $0.distance < $1.distance})
        let toSelectAnnotation = mapView.annotations.filter({ return $0.title == closestStation?.name})
        mapView.selectedAnnotations = toSelectAnnotation
    }
}


extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? Station else { return }
        
        self.selectedAnnotation = annotation
        showInfoView(station: annotation)
        
        let currentSpanLat = self.mapView.region.span.latitudeDelta
        let currentSpanLong = self.mapView.region.span.longitudeDelta
        var zoom = MKCoordinateSpan(latitudeDelta: currentSpanLat, longitudeDelta: currentSpanLong)
        if (currentSpanLat > 0.04 || currentSpanLong > 0.04) {
            zoom = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        }
        let region = MKCoordinateRegion(center: annotation.coordinate, span: zoom)
        mapView.setRegion(region, animated: true)
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


extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
