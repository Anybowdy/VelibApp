import UIKit
import MapKit

class MapVC: UIViewController {
    
    let locationManager = CLLocationManager()
    let informationView = InformationView()
    var indicatorView = UIActivityIndicatorView()
    var selectedAnnotation: StationAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myPositionButton: UIButton!
    @IBOutlet weak var closestStationButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setUpPositionButton()
        setUpClosestStationButton()
        setUpListButton()

        detectLocation(zoomDelta: 0.020)
        
        Station.fetchStationsData()
        Station.dispatchGroup.notify(queue: .main) {
            self.setUpAnnotation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthStatus()
        checkInfoView()
    }
    
    func checkInfoView() {
        self.view.addSubview(informationView.view)
        let height = view.frame.height
        let width = view.frame.width
        
        informationView.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height / 4)
        print("view set")
        informationView.showViewWithAnimation()
    }
    
    func detectLocation(zoomDelta: CLLocationDegrees) {
        let location = locationManager.location!
        let userLocation = location.coordinate
        let zoom = MKCoordinateSpan(latitudeDelta: zoomDelta, longitudeDelta: zoomDelta)
        let region = MKCoordinateRegion(center: userLocation, span: zoom)
        mapView.setRegion(region, animated: true)
    }
   
    func setUpAnnotation() {
        for station in Station.stationsList {
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
    
    func setUpPositionButton() {
        myPositionButton.layer.cornerRadius = 0.5 * myPositionButton.bounds.size.width
        myPositionButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        myPositionButton.layer.shadowColor = UIColor.black.cgColor
        myPositionButton.layer.shadowRadius = 8
        myPositionButton.layer.shadowOpacity = 0.5
        myPositionButton.layer.masksToBounds = false
        myPositionButton.backgroundColor = .white
        myPositionButton.setImage(UIImage(named: "target"), for: .normal)
        myPositionButton.addTarget(self, action: #selector(myPositionButtonTapped), for: .touchUpInside)
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
    
    func setUpClosestStationButton() {
        closestStationButton.setTitle("Station la + proche", for: .normal)
        closestStationButton.setTitleColor(.white, for: .normal)
        closestStationButton.layer.cornerRadius = 0.5 * myPositionButton.bounds.size.width
        closestStationButton.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        closestStationButton.layer.shadowColor = UIColor.black.cgColor
        closestStationButton.layer.shadowRadius = 8
        closestStationButton.layer.shadowOpacity = 0.5
        closestStationButton.layer.masksToBounds = false
        closestStationButton.backgroundColor = UIColor(red: 0.3804, green: 0.7137, blue: 0.9098, alpha: 1.0)
        closestStationButton.addTarget(self, action: #selector(closestStationButtonTapped), for: .touchUpInside)
    }
    
    @objc func myPositionButtonTapped(_: UIButton) {
        detectLocation(zoomDelta: 0.020)
    }
    
    @objc func closestStationButtonTapped(_: UIButton) {
        print("Closest Station button tapped")
        let closestStationInList: Station = Station.stationsList[0]
        for annotation in mapView.annotations {
            if annotation.title! == closestStationInList.stationName {
                mapView.selectAnnotation(annotation, animated: true)
                print("In loop")
                break
            }
        }
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        informationView.hideViewWithAnimation()
        self.selectedAnnotation = view.annotation as? StationAnnotation
        
        let lat = view.annotation!.coordinate.latitude
        let long = view.annotation!.coordinate.longitude
        let currentSpanLat = self.mapView.region.span.latitudeDelta
        let currentSpanLong = self.mapView.region.span.longitudeDelta
        var zoom = MKCoordinateSpan(latitudeDelta: currentSpanLat, longitudeDelta: currentSpanLong)
        if (currentSpanLat > 0.04 || currentSpanLong > 0.04) {
            zoom = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: zoom)
        mapView.setRegion(region, animated: true)
        //informationView.showViewWithAnimation()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Region changed")
        //informationView.view.removeFromSuperview()
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
