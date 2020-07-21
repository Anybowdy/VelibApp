import UIKit
import MapKit
import CoreLocation

import RxSwift
import RxCocoa

class MapVC: UIViewController {
    
    var stations: [Station] = [] {
        didSet {
            setupCellConfiguration()
            setUpAnnotation()
            myPositionButton.isEnabled = true
            closestStationButton.isEnabled = true
            searchButton.isEnabled = true
            UIView.transition(with: self.mapView,
                                    duration: 0.6,
                                    options: .transitionCrossDissolve, animations: {
                self.mapView.isHidden = false
            })
        }
    }
    
    var selectedAnnotation: Station?
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    var searchBar = UISearchBar()
    
    let disposeBag = DisposeBag()

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

    let userLocationZoom = 0.01
    
    // MARK: -Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    @IBOutlet weak var searchButton: PositionButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var infoViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorization()
        getStations()
        centerOnUserLocation(zoomDelta: userLocationZoom)
        setupCellTapHandling()
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
        searchBar.placeholder = "Entrez une adresse"
        
        indicatorView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        indicatorView.hidesWhenStopped = true
        indicatorView.center = view.center
        indicatorView.style = UIActivityIndicatorView.Style.gray
        indicatorView.startAnimating()
        
        infoViewTrailing.constant = -150
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
        UIView.transition(with: self.mapView, duration: 0.6,
                            options: .transitionCrossDissolve, animations: {
                                self.mapView.addAnnotations(self.stations)
        })
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

// MARK: - Rx Tableview

extension MapVC {
    
    func setupCellConfiguration() {
        let searchResults = searchBar.rx.text.orEmpty
            .flatMapLatest { (query) -> Observable<[Station]> in
                if query.isEmpty {
                    return .just(self.stations)
                }
                let filteredStations = self.stations.filter { (station) -> Bool in
                    return station.name.contains(query)
                }
                return .just(filteredStations)
        }
        .observeOn(MainScheduler.instance)
        
        searchResults
            .bind(to: tableView.rx.items(cellIdentifier: "stationCell")) { row, station, cell in
                cell.textLabel?.text = station.name
            }
        .disposed(by: disposeBag)
    }
    
    func setupCellTapHandling() {
        tableView
            .rx
            .modelSelected(Station.self)
            .subscribe(onNext: { [unowned self] station in
                self.selectedAnnotation = station
                self.mapView.selectedAnnotations = self.mapView.annotations.filter({ return $0.title == station.name})
                self.searchMode(isActivated: false)
                
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                  self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            })
        .disposed(by: disposeBag)
    }
    
}

// MARK: - INFORMATION VIEW

extension MapVC {
    
    func stationInfoView(shouldShow: Bool) {
        if (shouldShow), let station = self.selectedAnnotation {
            nbEBikesLabel.text = String(station.eBike)
            nbBikesLabel.text = String(station.mechanical)
            nbDocksLabel.text = String(station.numdocksavailable)
            
            UIView.animate(withDuration: 0.3) {
                self.infoViewTrailing.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.infoViewTrailing.constant = -150
                self.view.layoutIfNeeded()
            }
        }
    }
}
