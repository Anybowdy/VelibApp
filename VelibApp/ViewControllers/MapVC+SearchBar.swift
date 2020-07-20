//
//  MapVC+SearchBar.swift
//  VelibApp
//
//  Created by Joseph Huang on 20/07/2020.
//  Copyright © 2020 Joseph Huang. All rights reserved.
//

import UIKit

extension MapVC {
    func searchMode(isActivated: Bool) {
        if (isActivated) {
            navigationController?.isNavigationBarHidden = false
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
        } else {
            navigationItem.titleView = nil
            navigationController?.isNavigationBarHidden = true
        }
    }
}

extension MapVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchMode(isActivated: false)
    }
}
