//
//  TableViewManager.swift
//  TutorialDemo
//
//  Created by Ari Munandar on 23/12/23.
//

import Foundation
import UIKit

public typealias TableViewDelegateHandler = (_ item: AnyViewComponent, _ indexPath: IndexPath) -> Void

public final class TableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate, ViewManager {
    public typealias ViewType = UITableView
    public weak var view: ViewType?

    public var sections: [SectionComponent] = []
    public var registeredViewTypes = Set<String>()
    private var didSelectItemHandler: TableViewDelegateHandler?
    private var didDeselectItemHandler: TableViewDelegateHandler?
    private var didWillDisplayItemHandler: TableViewDelegateHandler?
    private var didGetBottomHandler: TableViewDelegateHandler?

    public init(tableView: UITableView?) {
        self.view = tableView
        super.init()
        configureView()
        setupOrientationChangeNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TableViewManager {
    public func configureView() {
        if #available(iOS 15.0, *) {
            view?.sectionHeaderTopPadding = 0
        } else {
            view?.contentInsetAdjustmentBehavior = .never
        }

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
        view?.reloadData()
    }
}

public extension TableViewManager {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].components.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = sections[indexPath.section].components[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: component.reuseIdentifier, for: indexPath)
        configureComponent(component).configure(view: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let component = sections[section].header else {
            return nil
        }

        if let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: component.reuseIdentifier) {
            configureComponent(component).configure(view: cell)
            return cell
        }

        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let component = sections[section].footer,
              let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: component.reuseIdentifier)
        else {
            return nil
        }

        configureComponent(component).configure(view: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let component = sections[indexPath.section].components[indexPath.item]
        didWillDisplayItemHandler?(configureComponent(component), indexPath)

        guard let lastComponent = sections[indexPath.section].components.last,
              lastComponent.isEqual(to: component)
        else {
            return
        }

        didGetBottomHandler?(configureComponent(component), indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = sections[indexPath.section].components[indexPath.row].height()
        return height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = sections[section].header?.height() ?? 0.0
        return height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height = sections[section].footer?.height() ?? 0.0
        return height
    }
}

public extension TableViewManager {
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
}
