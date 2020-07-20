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
            searchButton.isEnabled = true
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
    
    let dummyData = ["Paris", "New York", "Shanghai", "Los Angeles"]
    
    // MARK: -Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    @IBOutlet weak var searchButton: PositionButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewCenter: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStations()
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
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: -UI
    
    func setUpView() {
        mapView.isHidden = true
        
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter an address"
        
        indicatorView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
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
    
    // MARK: -Actions
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchMode(isActivated: true)
    }
    
    @IBAction func myPositionButtonTapped(_ sender: Any) {
        mapView.deselectAnnotation(self.selectedAnnotation, animated: true)
        stationInfoView(shouldShow: false)
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
    
    func stationInfoView(shouldShow: Bool) {
        if (shouldShow), let station = self.selectedAnnotation {
            nbEBikesLabel.text = String(station.eBike)
            nbBikesLabel.text = String(station.mechanical)
            nbDocksLabel.text = String(station.numdocksavailable)
            
            infoViewCenter.constant = 151
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            infoViewCenter.constant = 300
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
