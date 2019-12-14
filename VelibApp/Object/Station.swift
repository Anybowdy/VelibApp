import Foundation
import UIKit
import MapKit

struct Station {
    var stationName: String
    var nbBikes: Int
    var nbEBikes: Int
    var nbFreeDocks: Int
    var location: CLLocationCoordinate2D
    var distance: Float = 0
}
