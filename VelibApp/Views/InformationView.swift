import Foundation
import UIKit

class InformationView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 20
        view.layer.opacity = 0.5
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showViewWithAnimation() {
        UIView.animate(withDuration: 0.6) { [weak self] in
        let frame = self?.view.frame
        let yComponent = UIScreen.main.bounds.height - 200
        self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    func hideViewWithAnimation() {
        UIView.animate(withDuration: 0.6) { [weak self] in
        let frame = self?.view.frame
        let yComponent = UIScreen.main.bounds.height + 200
        self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
}
