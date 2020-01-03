import UIKit

class StationCell: UITableViewCell {
    
    @IBOutlet weak var nbEBikes: UILabel!
    @IBOutlet weak var NbBikes: UILabel!
    @IBOutlet weak var nbFreeDocks: UILabel!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    
    func setUpStationCell(station: Station) {
        self.stationName.text = station.stationName
        
        self.nbEBikes.text = String(station.nbEBikes) + " vélos électrique(s) "
        self.nbEBikes.textColor = UIColor(hue: 0.5694, saturation: 1, brightness: 0.92, alpha: 1.0)
        
        self.NbBikes.text = String(station.nbBikes) + " vélos mécanique(s)"
        self.NbBikes.textColor = UIColor(hue: 0.3306, saturation: 1, brightness: 0.75, alpha: 1.0)
        
        self.nbFreeDocks.text = String(station.nbFreeDocks) + " places disponibles"
        self.distance.text = String(station.distance) + " km"
    }
    
}
