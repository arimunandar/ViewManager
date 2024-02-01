//
//  Extension+UITableView.swift
//  TutorialDemo
//
//  Created by Ari Munandar on 31/01/24.
//

import UIKit

extension UITableView {
    func registerCellNib<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: cellClass))
        register(nib, forCellReuseIdentifier: identifier)
    }

    func registerSupplementaryNib<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        let identifier = String(describing: viewClass)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: viewClass))
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    func registerCellClass<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(cellClass, forCellReuseIdentifier: identifier)
    }

    func registerSupplementaryClass<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        let identifier = String(describing: viewClass)
        register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
}
