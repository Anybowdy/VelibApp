import UIKit
import MapKit
import CoreLocation

import RxSwift
import RxCocoa

class MapVC: UIViewController {
    
    var stations: [Station] = [] {
        didSet {
            stationsDidLoad()
        }
    }
    
    var selectedAnnotation: Station?
    
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    var indicatorView = UIActivityIndicatorView()
    var searchBar = UISearchBar()
        
    let userLocationZoom = 0.01
    
    // MARK: -Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    @IBOutlet weak var searchButton: PositionButton!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var nbEBikesLabel: UILabel!
    @IBOutlet weak var nbBikesLabel: UILabel!
    @IBOutlet weak var nbDocksLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            setupCellTapHandling()
        }
    }

    // MARK: -Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStations()
        centerOnUserLocation(zoomDelta: userLocationZoom)
        checkLocationAuthorization()

        register()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Register cell and delegate
    
    func register() {
        mapView.register(StationMarkerView.self, forAnnotationViewWithReuseIdentifier: "AnnotationView")
        
        collectionView.delegate = self
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
    
    func stationsDidLoad() {
        // Stop indicator animation
        indicatorView.stopAnimating()
        // Add annotations
        UIView.transition(with: self.mapView, duration: 0.6,
                            options: .transitionCrossDissolve, animations: {
                                self.mapView.addAnnotations(self.stations)
        })
        // Enable buttons
        myPositionButton.isEnabled = true
        closestStationButton.isEnabled = true
        searchButton.isEnabled = true
        // Make map visible
        UIView.transition(with: self.mapView,
                                duration: 0.6,
                                options: .transitionCrossDissolve, animations: {
            self.mapView.isHidden = false
        })
        // Add cells
        setupCellConfiguration()
    }
    
    func getStations() {
        API.fetchStationsData { stations in
            DispatchQueue.main.async {
                let orderedStations = stations.sorted(by: {(a, b) -> Bool in a.distance! < b.distance! })
                self.stations = orderedStations
            }
        }
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
        let test = stations.first
        let toSelectAnnotation = mapView.annotations.filter({ return $0.title == test?.name})
        mapView.selectedAnnotations = toSelectAnnotation
    }

}

// MARK: - Rx CollectionView

extension MapVC {
    
    func setupCellConfiguration() {
        searchBar.rx.text.orEmpty
            .flatMapLatest { (query) -> Observable<[Station]> in
                if query.isEmpty {
                    return .just(self.stations)
                }
                let filteredStations = self.stations.filter { (station) -> Bool in
                    return station.name.lowercased().contains(query.lowercased())
                }
                return .just(filteredStations)
        }
            .observeOn(MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: StationCollectionViewCell.self)) { row, station, cell in
                cell.configureWithStation(station: station)
            }
        .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .bind(onNext: {
                self.collectionView.setContentOffset(.zero, animated: true)
            })
        .disposed(by: disposeBag)
    }
    
    func setupCellTapHandling() {
        collectionView
            .rx
            .modelSelected(Station.self)
            .subscribe(onNext: { [unowned self] station in
                self.selectedAnnotation = station
                self.mapView.selectedAnnotations = self.mapView.annotations.filter({ return $0.title == station.name})
                self.searchMode(isActivated: false)
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

extension MapVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 100)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollYAxis = scrollView.contentOffset.y
        if (scrollYAxis <= 0) {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.endEditing(true)
        }
    }
}
