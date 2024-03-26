//
//  CollectionViewManager.swift
//  ViewManager
//
//  Created by Ari Munandar on 23/12/23.
//

import Foundation
import UIKit

public typealias CollectionViewDelegateHandler = (_ item: AnyViewComponent, _ indexPath: IndexPath) -> Void

public final class CollectionViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ViewManager {
    
    public typealias ViewType = UICollectionView
    public weak var view: ViewType?
    public var shouldAnimateOnReload: Bool = true

    public var sections: [SectionComponent] = []
    public var registeredViewTypes = Set<String>()
    private var didSelectItemHandler: CollectionViewDelegateHandler?
    private var didDeselectItemHandler: CollectionViewDelegateHandler?
    private var didWillDisplayItemHandler: CollectionViewDelegateHandler?
    private var didGetBottomHandler: CollectionViewDelegateHandler?
    private var didScrollViewHandler: ((_ scrollView: UIScrollView) -> Void)?

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

public extension CollectionViewManager {
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

public extension CollectionViewManager {
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
        let component: (any IViewComponent)?

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

public extension CollectionViewManager {
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

public extension CollectionViewManager {
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

    private func handleItemSelection(at indexPath: IndexPath, with handler: CollectionViewDelegateHandler?) {
        let component = sections[indexPath.section].components[indexPath.item]
        handler?(configureComponent(component), indexPath)
    }
}

public extension CollectionViewManager {
    func didSelectItem(_ completion: @escaping (AnyViewComponent, IndexPath) -> Void) {
        didSelectItemHandler = completion
    }

    func didDeselectItem(_ completion: @escaping (AnyViewComponent, IndexPath) -> Void) {
        didDeselectItemHandler = completion
    }

    func didWillDisplayItem(_ completion: @escaping (AnyViewComponent, IndexPath) -> Void) {
        didWillDisplayItemHandler = completion
    }

    func didGetBottom(_ completion: @escaping (AnyViewComponent, IndexPath) -> Void) {
        didGetBottomHandler = completion
    }
    
    public func didScrollView(_ completion: @escaping (UIScrollView) -> Void) {
        didScrollViewHandler = completion
    }
}


extension CollectionViewManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollViewHandler?(scrollView)
    }
}
