import Foundation
import UIKit
import MapKit
import Contacts

struct Station: Decodable {
    let name: String
    let mechanical: Int
    let eBike: Int
    let numdocksavailable: Int
    var coordinate: [Float]
    //let distance: Float

    enum CodingKeys: CodingKey {
        case fields
        
        case ebike
        case name
        case mechanical
        case coordonnees_geo
        case numdocksavailable
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fieldsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)
                
        self.eBike = try fieldsContainer.decode(Int.self, forKey: .ebike)
        self.name = try fieldsContainer.decode(String.self, forKey: .name)
        self.mechanical = try fieldsContainer.decode(Int.self, forKey: .mechanical)
        self.coordinate = try fieldsContainer.decode([Float].self, forKey: .coordonnees_geo)
        self.numdocksavailable = try fieldsContainer.decode(Int.self, forKey: .numdocksavailable)
    }
    
    
    static func fetchStationsData(completed: @escaping ([Station]) -> Void) {
        //let location = CLLocationManager().location
        guard let url = URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=&rows=1400") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let stations = try JSONDecoder().decode(Response.self, from: data)
                completed(stations.records)
            }
            catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
    /*
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary:addressDict as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }*/
}
