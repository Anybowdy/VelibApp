import UIKit
import MapKit

class StationListScreen: UIViewController {
    
    private let locationManager = CLLocationManager()
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var stationsListView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
            /*stationsListView.frame = CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)*/
        setUpNavBar()
        setUpRefreshControl()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    @objc private func refreshData() {
        self.refreshControl.beginRefreshing()
        Data().fetchStationData()
        Data.dispatchGroup.notify(queue: .main) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setUpRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
    }
    
    private func setUpNavBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}

// MARK: TableView
extension StationListScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as! StationCell
            cell.setUpStation(station: Data.stationsList[indexPath.row])
        return cell
    }
}
