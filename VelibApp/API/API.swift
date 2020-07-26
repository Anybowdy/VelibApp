//
//  API.swift
//  VelibApp
//
//  Created by Joseph Huang on 20/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import MapKit

struct API {
    static let API_LINK = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=&rows=1400"
    
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
                completed(stations)
            }
            catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
}
