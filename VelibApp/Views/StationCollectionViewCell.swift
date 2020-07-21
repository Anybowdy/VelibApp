//
//  StationCollectionViewself.swift
//  VelibApp
//
//  Created by Joseph Huang on 21/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import UIKit

class StationCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceToLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor(red: 0.3804, green: 0.7137, blue: 0.9098, alpha: 1.0).cgColor
        self.layer.cornerRadius = 25
        self.backgroundColor = .white
    }
    
    func configureWithStation(station: Station) {
        stationNameLabel.text = station.name
        distanceToLabel.text = "\(station.distance!) km"
    }
}
