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
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary:addressDict as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }
    
    var totalBikesCount: Int {
        return eBike + mechanical
    }
    
    var markerTintColor: UIColor {
        switch totalBikesCount {
        case 0...5:
            return .red
        case 5...10:
            return .yellow
        default:
            return .green
        }
    }
}
