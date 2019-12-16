import UIKit
import MapKit

class Data {

    static var stationsList = [Station]()
    static let dispatchGroup = DispatchGroup()
    
    func fetchStationData() {
        Data.dispatchGroup.enter()
        
        let locationManager = CLLocationManager()
        let location = locationManager.location
        guard let jsonStringUrl = URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=2000") else { return }
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
                        Data.stationsList.append(Station(stationName: stationName,nbBikes: nbBikes, nbEBikes: nbEBikes, nbFreeDocks: nbFreeEDock, location: CLLocationCoordinate2D(latitude: geo[0], longitude: geo[1]), distance: (Float(location!.distance(from: CLLocation(latitude: geo[0], longitude: geo[1]))) / 100).rounded() / 10))
                        
                    }
                }
                Data.dispatchGroup.leave()
            }
            catch let jsonError{
                print("Error: \(jsonError)")
            }
            self.sortStationsWithDistance(arr: &Data.stationsList)
            print("All stations are loaded")
        }.resume()
    }
    
    func sortStationsWithDistance(arr: inout [Station]) {
        for _ in 0...arr.count - 1 {
            for j in 1...arr.count - 1{
                if (arr[j].distance < arr[j - 1].distance) {
                    let tmp = arr[j]
                    arr[j] = arr[j - 1]
                    arr[j - 1] = tmp
                }
            }
        }
    }
}
