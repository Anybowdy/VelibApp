import Foundation
import UIKit

class InformationView: UIViewController {
        
    var stationName: String
    var nbEBikes: Int
    var nbBikes: Int
    var nbFreeDocks: Int
    var distance: Float
    
    init(stationName: String, nbEBikes: Int, nbBikes: Int, nbFreeDocks: Int, distance: Float) {
        self.stationName = stationName
        self.nbEBikes = nbEBikes
        self.nbBikes = nbBikes
        self.nbFreeDocks = nbFreeDocks
        self.distance = distance
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stationNameLabel = { () -> UILabel in
        let stationNameLabel = UILabel()
        stationNameLabel.backgroundColor = .white
        stationNameLabel.text = self.stationName
        stationNameLabel.textColor = .black
        stationNameLabel.textAlignment = .center
        stationNameLabel.clipsToBounds = true
        stationNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        return stationNameLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStationNameLabel()
        view.layer.cornerRadius = 20
        view.layer.opacity = 0.9
        view.backgroundColor = .white

        view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: view.frame.width, height: view.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.6) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    func setUpStationNameLabel() {
        view.addSubview(stationNameLabel)
        stationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        stationNameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        stationNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //stationNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        stationNameLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stationNameLabel.heightAnchor.constraint(equalToConstant: 65).isActive = true
    }
    
    
    
    func hideViewWithAnimation() {
        UIView.animate(withDuration: 0.6) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
}
