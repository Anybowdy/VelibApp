import Foundation
import UIKit

class ClosestStationButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    
    private func setUpButton() {
        backgroundColor = UIColor(red: 0.3804, green: 0.7137, blue: 0.9098, alpha: 1.0)
        setTitleColor(.white, for: .normal)
        
        layer.masksToBounds = false
        layer.cornerRadius = 25
        
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
    }
    
}
