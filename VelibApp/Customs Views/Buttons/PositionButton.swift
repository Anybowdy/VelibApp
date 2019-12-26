import Foundation
import UIKit

class PositionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    
    private func setUpButton() {
        backgroundColor = .white
        
        layer.masksToBounds = false
        layer.cornerRadius = 0.5 * bounds.size.width
        
        layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.5
    }
    
}
