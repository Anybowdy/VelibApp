import Foundation
import MapKit
import Contacts

class StationAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    let nbEBikes: Int
    let nbBikes: Int
    let nbDocks: Int
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D, nbEBikes: Int, nbBikes: Int, nbDocks: Int) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.nbEBikes = nbEBikes
        self.nbBikes = nbBikes
        self.nbDocks = nbDocks
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary:addressDict as [String : Any])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }
}
