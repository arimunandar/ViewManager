//
//  Extension+UICollectionView.swift
//  TutorialDemo
//
//  Created by Ari Munandar on 31/01/24.
//

import UIKit

extension UICollectionView {
    func registerCellNib<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: cellClass))
        register(nib, forCellWithReuseIdentifier: identifier)
    }

    func registerSupplementaryNib<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        let identifier = String(describing: viewClass)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: viewClass))
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }

    func registerCellClass<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    func registerSupplementaryClass<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        let identifier = String(describing: viewClass)
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
}
