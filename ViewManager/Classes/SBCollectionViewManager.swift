//
//  SBCollectionViewManager.swift
//  TutorialDemo
//
//  Created by Ari Munandar on 23/12/23.
//

import Foundation
import UIKit

public typealias SBCollectionViewDelegateHandler = (_ item: SBAnyViewComponent, _ indexPath: IndexPath) -> Void

public final class SBCollectionViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SBViewManager {
    public typealias ViewType = UICollectionView
    public weak var view: ViewType?

    public var sections: [SBSectionComponent] = []
    public var registeredViewTypes = Set<String>()
    private var didSelectItemHandler: SBCollectionViewDelegateHandler?
    private var didDeselectItemHandler: SBCollectionViewDelegateHandler?
    private var didWillDisplayItemHandler: SBCollectionViewDelegateHandler?
    private var didGetBottomHandler: SBCollectionViewDelegateHandler?

    public init(collectionView: UICollectionView?) {
        self.view = collectionView
        super.init()
        configureView()
        setupOrientationChangeNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

public extension SBCollectionViewManager {
    func configureView() {
        view?.dataSource = self
        view?.delegate = self
    }

    private func setupOrientationChangeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func orientationChanged() {
        view?.collectionViewLayout.invalidateLayout()
        view?.reloadData()
    }
}

public extension SBCollectionViewManager {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].components.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let component = sections[indexPath.section].components[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: component.reuseIdentifier, for: indexPath)
        configureComponent(component).configure(view: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = sections[indexPath.section]
        let reuseIdentifier: String
        let component: (any ISBViewComponent)?

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            reuseIdentifier = section.header?.reuseIdentifier ?? "HeaderId"
            component = section.header
        default:
            reuseIdentifier = section.footer?.reuseIdentifier ?? "FooterId"
            component = section.footer
        }

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let component = component {
            configureComponent(component).configure(view: view)
        }
        return view
    }
}

public extension SBCollectionViewManager {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let component = sections[indexPath.section].components[indexPath.item]
        let sectionProperty = sections[indexPath.section].property
        return component.sizeItem(at: collectionView.bounds.size, property: sectionProperty)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sections[section].property.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sections[section].property.minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sections[section].property.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let header = sections[section].header else {
            return .zero
        }
        let sectionProperty = sections[section].property
        return header.sizeItem(at: collectionView.bounds.size, property: sectionProperty)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let footer = sections[section].footer else {
            return .zero
        }
        let sectionProperty = sections[section].property
        return footer.sizeItem(at: collectionView.bounds.size, property: sectionProperty)
    }
}

public extension SBCollectionViewManager {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleItemSelection(at: indexPath, with: didSelectItemHandler)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleItemSelection(at: indexPath, with: didDeselectItemHandler)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let component = sections[indexPath.section].components[indexPath.item]
        didWillDisplayItemHandler?(configureComponent(component), indexPath)

        guard let lastComponent = sections[indexPath.section].components.last,
              lastComponent.isEqual(to: component)
        else {
            return
        }

        didGetBottomHandler?(configureComponent(component), indexPath)
    }

    private func handleItemSelection(at indexPath: IndexPath, with handler: SBCollectionViewDelegateHandler?) {
        let component = sections[indexPath.section].components[indexPath.item]
        handler?(configureComponent(component), indexPath)
    }
}

public extension SBCollectionViewManager {
    func didSelectItem(_ completion: @escaping (SBAnyViewComponent, IndexPath) -> Void) {
        didSelectItemHandler = completion
    }

    func didDeselectItem(_ completion: @escaping (SBAnyViewComponent, IndexPath) -> Void) {
        didDeselectItemHandler = completion
    }

    func didWillDisplayItem(_ completion: @escaping (SBAnyViewComponent, IndexPath) -> Void) {
        didWillDisplayItemHandler = completion
    }

    func didGetBottom(_ completion: @escaping (SBAnyViewComponent, IndexPath) -> Void) {
        didGetBottomHandler = completion
    }
}