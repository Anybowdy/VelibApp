import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    var stations: [Station] = [] {
        didSet {
            centerOnUserLocation(zoomDelta: userLocationZoom)
            setUpAnnotation()
            myPositionButton.isEnabled = true
            closestStationButton.isEnabled = true
            mapView.isHidden = false
        }
    }
    
    var selectedAnnotation: Station?
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    var searchBar = UISearchBar()

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
    @IBOutlet weak var searchButton: PositionButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewCenter: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    // MARK: -Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: -Delegates
    
    func setupDelegates() {
        searchBar.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    // MARK: -UI
    
    func setUpView() {
        mapView.isHidden = true
        
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter an address"
        
        indicatorView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        indicatorView.backgroundColor = .gray
        indicatorView.hidesWhenStopped = true
        indicatorView.center = view.center
        indicatorView.style = UIActivityIndicatorView.Style.gray
        indicatorView.startAnimating()
        
        infoViewCenter.constant = 300
        infoView.layer.cornerRadius = 20
        infoView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        view.addSubview(indicatorView)
        addTapGesture()
    }
    
    func centerOnUserLocation(zoomDelta: CLLocationDegrees) {
        if let userLocation = locationManager.location?.coordinate {
            let zoom = MKCoordinateSpan(latitudeDelta: zoomDelta, longitudeDelta: zoomDelta)
            let region = MKCoordinateRegion(center: userLocation, span: zoom)
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 10,
                           options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.mapView.setRegion(region, animated: true)
            }, completion: nil)
        }
    }
    
    func getStations() {
        Station.fetchStationsData { stations in
            DispatchQueue.main.async {
                self.stations = stations
            }
        }
    }
    
    func setUpAnnotation() {
        indicatorView.stopAnimating()
        mapView.addAnnotations(stations)
    }
    
    // MARK: -Gesture Recognizer
    
    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnMap))
        mapView.addGestureRecognizer(gesture)
    }
    
    
    // MARK: -Actions
    
    @objc func didTapOnMap() {
        hideInfoView()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchMode(isActivated: true)
    }
    
    @IBAction func myPositionButtonTapped(_ sender: Any) {
        mapView.deselectAnnotation(self.selectedAnnotation, animated: true)
        hideInfoView()
        centerOnUserLocation(zoomDelta: userLocationZoom)
    }
    
    @IBAction func closestStationButtonTapped(_ sender: Any) {
        if (stations.isEmpty) {
            return
        }
        mapView.deselectAnnotation(selectedAnnotation, animated: true)
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        let location = CLLocation(latitude: lat, longitude: long)
        let closestStation = stations.min { (a, b) -> Bool in
            let first = location.distance(from: CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude))
            let second = location.distance(from: CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude))
            return first < second
        }
        let toSelectAnnotation = mapView.annotations.filter({ return $0.title == closestStation?.name})
        mapView.selectedAnnotations = toSelectAnnotation
    }
    
}


// MARK: INFORMATION VIEW

extension MapVC {
    func showInfoView(station: Station) {
        nbEBikesLabel.text = String(station.eBike)
        nbBikesLabel.text = String(station.mechanical)
        nbDocksLabel.text = String(station.numdocksavailable)
        
        infoViewCenter.constant = 151
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
}
