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
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            UIView.animate(withDuration: 0.4) {
                self.navigationController?.isNavigationBarHidden = false
                self.collectionViewTop.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            navigationItem.titleView = nil
            UIView.animate(withDuration: 0.4) {
                self.navigationController?.isNavigationBarHidden = true
                self.collectionViewTop.constant = 1200
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension MapVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchMode(isActivated: false)
    }
}
