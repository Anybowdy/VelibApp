import UIKit
import MapKit

class MapVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    var selectedAnnotation: StationAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewCenter: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpIndicatorView()
        setUpListButton()
        setUpInfoView()

        setRegionToUserLocation(zoomDelta: 0.15)
        
        Station.fetchStationsData {
            DispatchQueue.main.async {
                self.setRegionToUserLocation(zoomDelta: 0.02)
                self.setUpAnnotation()
                self.indicatorView.stopAnimating()
                self.myPositionButton.isEnabled = true
                self.closestStationButton.isEnabled = true
                self.listButton.isEnabled = true
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthStatus()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func setUpIndicatorView() {
        indicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicatorView.center = self.view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()
    }
    
    
    func setRegionToUserLocation(zoomDelta: CLLocationDegrees) {
        let userLocation = locationManager.location!.coordinate
        let zoom = MKCoordinateSpan(latitudeDelta: zoomDelta, longitudeDelta: zoomDelta)
        let region = MKCoordinateRegion(center: userLocation, span: zoom)
        mapView.setRegion(region, animated: true)
    }
   
    
    func setUpAnnotation() {
        for station in Station.stationsList {
            let annotation = StationAnnotation(title: station.stationName, locationName: station.stationName, coordinate: station.location, nbEBikes: station.nbEBikes, nbBikes: station.nbBikes, nbDocks: station.nbFreeDocks)
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
    
    
    func setUpListButton() {
        listButton.layer.cornerRadius = 0.5 * myPositionButton.bounds.size.width
        listButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        listButton.layer.shadowColor = UIColor.black.cgColor
        listButton.layer.shadowRadius = 8
        listButton.layer.shadowOpacity = 0.5
        listButton.layer.masksToBounds = false
        listButton.backgroundColor = .white
    }
    
    
    // MARK: INFORMATION VIEW
    
    private func setUpInfoView() {
        infoViewCenter.constant = 300
        infoView.layer.cornerRadius = 20
        infoView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    
    private func showInfoView(station: StationAnnotation) {
        nbEBikesLabel.text = String(station.nbEBikes)
        nbBikesLabel.text = String(station.nbBikes)
        nbDocksLabel.text = String(station.nbDocks)
        
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
    
    
    // MARK: IBACTIONS
    
    @IBAction func myPositionButtonTapped(_ sender: Any) {
        mapView.deselectAnnotation(self.selectedAnnotation, animated: true)
        hideInfoView()
        setRegionToUserLocation(zoomDelta: 0.020)
    }
    
    
    @IBAction func closestStationButtonTapped(_ sender: Any) {
        let closestStationName = Station.stationsList[0].stationName
        let toSelectAnnotation = mapView.annotations.filter({ return $0.title == closestStationName})
        mapView.selectedAnnotations = toSelectAnnotation
    }
   
}


extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? StationAnnotation else { return }
        self.selectedAnnotation = annotation
        showInfoView(station: annotation)
        
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        let currentSpanLat = self.mapView.region.span.latitudeDelta
        let currentSpanLong = self.mapView.region.span.longitudeDelta
        var zoom = MKCoordinateSpan(latitudeDelta: currentSpanLat, longitudeDelta: currentSpanLong)
        if (currentSpanLat > 0.04 || currentSpanLong > 0.04) {
            zoom = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
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
            annotationView.image = UIImage(named: "bubble")
            annotationView.canShowCallout = false
            annotationView.rightCalloutAccessoryView = goButton
            annotationView.canShowCallout = true
            return annotationView
        }()
        
        return annotationView
    }
    
    
    // Redirect to Plans
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
      let location = view.annotation as! StationAnnotation
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}
