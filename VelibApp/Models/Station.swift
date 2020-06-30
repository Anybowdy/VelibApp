import Foundation
import UIKit
import MapKit
import Contacts

class Station: NSObject, MKAnnotation {
    
    let title: String?
    let stationName: String
    let nbBikes: Int
    let nbEBikes: Int
    let nbFreeDocks: Int
    var coordinate: CLLocationCoordinate2D
    let location: CLLocationCoordinate2D
    let distance: Float
    
    init(stationName: String, nbBikes: Int, nbEBikes: Int, nbFreeDocks: Int, location: CLLocationCoordinate2D, distance: Float, coordinate: CLLocationCoordinate2D) {
        self.title = stationName
        self.stationName = stationName
        self.nbBikes = nbBikes
        self.nbEBikes = nbEBikes
        self.nbFreeDocks = nbFreeDocks
        self.location = location
        self.distance = distance
        self.coordinate = coordinate
    }

    static var stationsList: [Station] = []
    
    static func fetchStationsData(completed: @escaping ([Station]) -> Void) {
        let stations: [Station] = []
        let location = CLLocationManager().location
        guard let jsonStringUrl = URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=1400") else { return }
        URLSession.shared.dataTask(with: jsonStringUrl) { (data, response, error) in
            guard let data = data else { return }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
                guard let recordsObjects = jsonObject["records"] as? [[String: Any]] else { return }
                for recordObject in recordsObjects {
                    if let fields = recordObject["fields"] as? [String: Any],
                        let nbFreeEDock = fields["nbfreeedock"] as? Int,
                        let nbBikes = fields["nbbike"] as? Int,
                        let nbEBikes = fields["nbebike"] as? Int,
                        let stationName = fields["station_name"] as? String,
                        let geo = fields["geo"] as? [CLLocationDegrees]
                    {
                        Station.stationsList.append(Station(stationName: stationName,nbBikes: nbBikes, nbEBikes: nbEBikes, nbFreeDocks: nbFreeEDock, location: CLLocationCoordinate2D(latitude: geo[0], longitude: geo[1]), distance: (Float(location!.distance(from: CLLocation(latitude: geo[0], longitude: geo[1]))) / 100).rounded() / 10, coordinate: CLLocationCoordinate2D(latitude: geo[0], longitude: geo[1])))
                        
                    }
                }
            }
            catch let error {
                print("Error: \(error)")
            }
            Station.stationsList = Station.stationsList.sorted(by: {(a, b) -> Bool in a.distance < b.distance })
            completed(stations)
        }.resume()
    }
    
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary:addressDict as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }
}
