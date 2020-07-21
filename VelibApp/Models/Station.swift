import Foundation
import UIKit
import MapKit
import Contacts

class Station: NSObject, MKAnnotation, Decodable {
    
    var coordinate: CLLocationCoordinate2D
    
    let title: String?
    let name: String
    let mechanical: Int
    let eBike: Int
    let numdocksavailable: Int
    var location: [CLLocationDegrees]
    var distance: Float?

    enum CodingKeys: CodingKey {
        case fields
        
        case ebike
        case name
        case mechanical
        case coordonnees_geo
        case numdocksavailable
    }
    
        
    required init (from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fieldsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)
                
        self.eBike = try fieldsContainer.decode(Int.self, forKey: .ebike)
        self.title = try fieldsContainer.decode(String.self, forKey: .name)
        self.name = try fieldsContainer.decode(String.self, forKey: .name)
        self.mechanical = try fieldsContainer.decode(Int.self, forKey: .mechanical)
        self.location = try fieldsContainer.decode([CLLocationDegrees].self, forKey: .coordonnees_geo)
        self.numdocksavailable = try fieldsContainer.decode(Int.self, forKey: .numdocksavailable)
        
        self.coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        //print(()
        super.init()
    }
    
    static func fetchStationsData(completed: @escaping ([Station]) -> Void) {
        let location = CLLocationManager().location
        guard let url = URL(string: API.API_LINK) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                let stations = response.records.map { (station) -> Station in
                    station.distance = (Float(location!.distance(from: CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude))) / 100).rounded() / 10
                    return station
                }
                let orderedStations = stations.sorted(by: {(a, b) -> Bool in a.distance! < b.distance! })
                completed(orderedStations)
            }
            catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary:addressDict as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }
}
