//
//  MapVC+TableView.swift
//  VelibApp
//
//  Created by Joseph Huang on 20/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import UIKit

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(stations.count)
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = stations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = stations[indexPath.row]
        print(station.name)
        searchMode(isActivated: false)
    }
}
