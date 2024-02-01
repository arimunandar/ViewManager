//
//  SBViewManager.swift
//  TutorialDemo
//
//  Created by Ari Munandar on 31/01/24.
//

import Foundation
import UIKit

public enum SBIdentifier {
    case byID(String)
    case byIndex(Int)
}

public protocol SBViewManager: AnyObject {
    associatedtype ViewType

    var view: ViewType? { get set }
    var sections: [SBSectionComponent] { get set }
    var registeredViewTypes: Set<String> { get set }
    func configureView()
    func registerComponentsIfNeeded()
    func registerCellsIfNeeded()
    func configureComponent(_ component: any ISBViewComponent) -> SBAnyViewComponent
    func performUpdate(_ completion: (() -> Void)?)
    func updateComponent(inSection: SBIdentifier, atItem: SBIdentifier, newComponent: any ISBViewComponent)
    func updateComponent(in sectionIndex: Int, at itemIndex: Int, with newComponent: any ISBViewComponent)
    func updateSupplementaryComponent(inSection: SBIdentifier, kind: SBSectionSupplementaryKind, newComponent: any ISBViewComponent)
    func getSections() -> [SBSectionComponent]
    func getSection(inSection: SBIdentifier) -> SBSectionComponent?
    func getComponent(inSection: SBIdentifier, atItem: SBIdentifier) -> (any ISBViewComponent)?
    func initialSection(section: SBSectionComponent)
    func initialSections(sections: [SBSectionComponent])
    func addComponent(inSection: SBIdentifier, newComponent: any ISBViewComponent)
    func addComponents(inSection: SBIdentifier, newComponents: [any ISBViewComponent])
    func insertComponent(inSection: SBIdentifier, atItem: SBIdentifier, newComponent: any ISBViewComponent)
    func insertComponents(inSection: SBIdentifier, atItems: [SBIdentifier], newComponents: [any ISBViewComponent])
    func moveItem(fromSection currentSection: SBIdentifier, fromItem currentItem: SBIdentifier, toSection targetSection: SBIdentifier, toItem targetItem: SBIdentifier)
    func removeComponent(inSection: SBIdentifier, atItem: SBIdentifier)
    func removeComponents(inSection: SBIdentifier, atItems: [SBIdentifier])
    func removeSupplementaryComponent(inSection: SBIdentifier, kind: SBSectionSupplementaryKind)
    func didSelectItem(_ completion: @escaping (_ item: SBAnyViewComponent, _ indexPath: IndexPath) -> Void)
    func didDeselectItem(_ completion: @escaping (_ item: SBAnyViewComponent, _ indexPath: IndexPath) -> Void)
    func didWillDisplayItem(_ completion: @escaping (_ item: SBAnyViewComponent, _ indexPath: IndexPath) -> Void)
    func didGetBottom(_ completion: @escaping (_ item: SBAnyViewComponent, _ indexPath: IndexPath) -> Void)
}

public extension SBViewManager {
    func registerComponentsIfNeeded() {
        registerCellsIfNeeded()
        registerSupplementaryViewsIfNeeded()
    }

    func registerCellsIfNeeded() {
        sections.forEach { section in
            section.components.forEach { component in
                registerComponent(component)
            }
        }
    }

    private func registerComponent(_ component: any ISBViewComponent) {
        let newComponent = configureComponent(component)
        let identifier = newComponent.reuseIdentifier

        guard !registeredViewTypes.contains(identifier) else {
            return
        }

        if Bundle.main.path(forResource: identifier, ofType: "nib") != nil {
            registerNibForComponent(newComponent)
        } else {
            registerClassForComponent(newComponent)
        }

        registeredViewTypes.insert(identifier)
    }

    private func registerNibForComponent(_ component: SBAnyViewComponent) {
        registerNibForCollectionView(component)
        registerNibForTableView(component)
    }

    private func registerNibForCollectionView(_ component: SBAnyViewComponent) {
        if let view = view as? UICollectionView, let cellType = component.componentType as? UICollectionViewCell.Type {
            view.registerCellNib(cellType)
        }
    }

    private func registerNibForTableView(_ component: SBAnyViewComponent) {
        if let view = view as? UITableView, let cellType = component.componentType as? UITableViewCell.Type {
            view.registerCellNib(cellType)
        }
    }

    private func registerClassForComponent(_ component: SBAnyViewComponent) {
        registerClassForCollectionView(component)
        registerClassForTableView(component)
    }

    private func registerClassForCollectionView(_ component: SBAnyViewComponent) {
        if let view = view as? UICollectionView, let cellType = component.componentType as? UICollectionViewCell.Type {
            view.registerCellClass(cellType)
        }
    }

    private func registerClassForTableView(_ component: SBAnyViewComponent) {
        if let view = view as? UITableView, let cellType = component.componentType as? UITableViewCell.Type {
            view.registerCellClass(cellType)
        }
    }

    private func registerSupplementaryViewsIfNeeded() {
        sections.forEach { section in
            registerSupplementaryComponent(kind: UICollectionView.elementKindSectionHeader, component: section.header)
            registerSupplementaryComponent(kind: UICollectionView.elementKindSectionFooter, component: section.footer)
        }
    }

    private func registerSupplementaryComponent(kind: String, component: (any ISBViewComponent)?) {
        guard let component = component else {
            return
        }

        let newComponent = configureComponent(component)
        let identifier = String(describing: "\(newComponent.componentType)|\(kind)")

        guard !registeredViewTypes.contains(identifier) else {
            return
        }

        if Bundle.main.path(forResource: String(describing: newComponent.componentType), ofType: "nib") != nil {
            registerNibForSupplementaryComponent(newComponent, kind: kind)
        } else {
            registerClassForSupplementaryComponent(newComponent, kind: kind)
        }

        registeredViewTypes.insert(identifier)
    }

    private func registerNibForSupplementaryComponent(_ component: SBAnyViewComponent, kind: String) {
        if let view = view as? UICollectionView, let viewType = component.componentType as? UICollectionReusableView.Type {
            view.registerSupplementaryNib(viewType, forSupplementaryViewOfKind: kind)
        }

        if let view = view as? UITableView, let viewType = component.componentType as? UITableViewHeaderFooterView.Type {
            view.registerSupplementaryNib(viewType)
        }
    }

    private func registerClassForSupplementaryComponent(_ component: SBAnyViewComponent, kind: String) {
        if let view = view as? UICollectionView, let viewType = component.componentType as? UICollectionReusableView.Type {
            view.registerSupplementaryClass(viewType, forSupplementaryViewOfKind: kind)
        }

        if let view = view as? UITableView, let viewType = component.componentType as? UITableViewHeaderFooterView.Type {
            view.registerSupplementaryClass(viewType)
        }
    }

    func configureComponent(_ component: any ISBViewComponent) -> SBAnyViewComponent {
        guard let component = component as? SBAnyViewComponent else {
            return SBAnyViewComponent(component)
        }
        return component
    }
}

public extension SBViewManager {
    func getSections() -> [SBSectionComponent] {
        return sections
    }

    func getSection(inSection: SBIdentifier) -> SBSectionComponent? {
        switch inSection {
        case .byID(let sectionId):
            return sections.first(where: { $0.id == sectionId })
        case .byIndex(let sectionIndex):
            guard sectionIndex < sections.count else {
                print("Invalid section index")
                return nil
            }
            return sections[sectionIndex]
        }
    }

    func getComponent(inSection: SBIdentifier, atItem: SBIdentifier) -> (any ISBViewComponent)? {
        guard let components = getSection(inSection: inSection)?.components else {
            return nil
        }

        switch atItem {
        case .byID(let itemId):
            return components.first(where: { $0.id == itemId })
        case .byIndex(let itemIndex):
            return itemIndex < components.count ? components[itemIndex] : nil
        }
    }
}

public extension SBViewManager {
    func initialSection(section: SBSectionComponent) {
        initialSections(sections: [section])
    }

    func initialSections(sections: [SBSectionComponent]) {
        self.sections = sections
        registerComponentsIfNeeded()
        if let view = view as? UITableView {
            view.reloadData()
        }

        if let view = view as? UICollectionView {
            view.reloadData()
        }
    }
}

public extension SBViewManager {
    func performUpdate(_ completion: (() -> Void)?) {
        UIView.performWithoutAnimation {
            if let view = view as? UICollectionView {
                view.performBatchUpdates({
                    completion?()
                }, completion: nil)
            }

            if let view = view as? UITableView {
                UIView.performWithoutAnimation {
                    view.beginUpdates()
                    completion?()
                    view.endUpdates()
                }
            }
        }
    }

    func addComponent(inSection: SBIdentifier, newComponent: any ISBViewComponent) {
        addComponents(inSection: inSection, newComponents: [newComponent])
    }

    func addComponents(inSection: SBIdentifier, newComponents: [any ISBViewComponent]) {
        var sectionIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        if let sectionIndex = sectionIndex {
            let startingIndex = sections[sectionIndex].components.count
            let newAnyComponents = newComponents.map { configureComponent($0) }
            sections[sectionIndex].components.append(contentsOf: newAnyComponents)

            registerCellsIfNeeded()

            performUpdate { [weak self] in
                let indexPaths = newAnyComponents.indices.map { IndexPath(item: startingIndex + $0, section: sectionIndex) }
                if let view = self?.view as? UICollectionView {
                    view.insertItems(at: indexPaths)
                }

                if let view = self?.view as? UITableView {
                    view.insertRows(at: indexPaths, with: .automatic)
                }
            }
        }
    }

    func updateComponent(inSection: SBIdentifier, atItem: SBIdentifier, newComponent: any ISBViewComponent) {
        var sectionIndex: Int?
        var itemIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        switch atItem {
        case .byID(let itemId):
            if let sectionIndex = sectionIndex {
                itemIndex = sections[sectionIndex].components.firstIndex(where: { $0.id == itemId })
            }
        case .byIndex(let index):
            itemIndex = index
        }

        if let sectionIndex = sectionIndex, let itemIndex = itemIndex {
            updateComponent(in: sectionIndex, at: itemIndex, with: newComponent)
        }
    }

    func updateComponent(in sectionIndex: Int, at itemIndex: Int, with newComponent: any ISBViewComponent) {
        guard itemIndex < sections[sectionIndex].components.count else {
            print("Invalid item index")
            return
        }

        let newAnyComponent = configureComponent(newComponent)
        sections[sectionIndex].components[itemIndex] = newAnyComponent

        registerCellsIfNeeded()

        performUpdate { [weak self] in
            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            if let view = self?.view as? UICollectionView {
                view.reloadItems(at: [indexPath])
            }

            if let view = self?.view as? UITableView {
                view.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func updateSupplementaryComponent(inSection: SBIdentifier, kind: SBSectionSupplementaryKind, newComponent: any ISBViewComponent) {
        var sectionIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        if let sectionIndex = sectionIndex {
            let newAnyComponent = configureComponent(newComponent)
            if kind == .header {
                sections[sectionIndex].header = newAnyComponent
            } else {
                sections[sectionIndex].footer = newAnyComponent
            }

            registerSupplementaryViewsIfNeeded()

            performUpdate { [weak self] in
                self?.reloadSection(sectionIndex: sectionIndex)
            }
        }
    }

    func insertComponent(inSection: SBIdentifier, atItem: SBIdentifier, newComponent: any ISBViewComponent) {
        insertComponents(inSection: inSection, atItems: [atItem], newComponents: [newComponent])
    }

    func insertComponents(inSection: SBIdentifier, atItems: [SBIdentifier], newComponents: [any ISBViewComponent]) {
        var sectionIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        if let sectionIndex = sectionIndex {
            var indicesToInsert: [Int] = []

            for item in atItems {
                switch item {
                case .byID(let itemId):
                    if let index = sections[sectionIndex].components.firstIndex(where: { $0.id == itemId }) {
                        indicesToInsert.append(index)
                    }
                case .byIndex(let index):
                    if index <= sections[sectionIndex].components.count {
                        indicesToInsert.append(index)
                    }
                }
            }

            let newAnyComponents = newComponents.map { configureComponent($0) }
            for (index, component) in zip(indicesToInsert, newAnyComponents) {
                sections[sectionIndex].components.insert(component, at: index)
            }

            registerCellsIfNeeded()

            performUpdate { [weak self] in
                let indexPaths = indicesToInsert.map { IndexPath(item: $0, section: sectionIndex) }

                if let view = self?.view as? UICollectionView {
                    view.insertItems(at: indexPaths)
                }

                if let view = self?.view as? UITableView {
                    view.insertRows(at: indexPaths, with: .automatic)
                }
            }
        }
    }

    func moveItem(fromSection currentSection: SBIdentifier, fromItem currentItem: SBIdentifier, toSection targetSection: SBIdentifier, toItem targetItem: SBIdentifier) {
        var currentSectionIndex: Int?
        var currentItemIndex: Int?
        var targetSectionIndex: Int?
        var targetItemIndex: Int?

        switch currentSection {
        case .byID(let sectionId):
            currentSectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            currentSectionIndex = index < sections.count ? index : nil
        }

        switch targetSection {
        case .byID(let sectionId):
            targetSectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            targetSectionIndex = index < sections.count ? index : nil
        }

        if let currentSectionIndex = currentSectionIndex, let targetSectionIndex = targetSectionIndex {
            switch currentItem {
            case .byID(let itemId):
                currentItemIndex = sections[currentSectionIndex].components.firstIndex(where: { $0.id == itemId })
            case .byIndex(let index):
                currentItemIndex = index < sections[currentSectionIndex].components.count ? index : nil
            }

            switch targetItem {
            case .byID(let itemId):
                targetItemIndex = sections[targetSectionIndex].components.firstIndex(where: { $0.id == itemId })
            case .byIndex(let index):
                targetItemIndex = index <= sections[targetSectionIndex].components.count ? index : nil
            }

            if let currentItemIndex = currentItemIndex, let targetItemIndex = targetItemIndex {
                let component = sections[currentSectionIndex].components.remove(at: currentItemIndex)
                sections[targetSectionIndex].components.insert(component, at: targetItemIndex)

                performUpdate { [weak self] in
                    let currentIndexPath = IndexPath(item: currentItemIndex, section: currentSectionIndex)
                    let targetIndexPath = IndexPath(item: targetItemIndex, section: targetSectionIndex)

                    if let view = self?.view as? UICollectionView {
                        view.moveItem(at: currentIndexPath, to: targetIndexPath)
                    }

                    if let view = self?.view as? UITableView {
                        view.moveRow(at: currentIndexPath, to: targetIndexPath)
                    }
                }
            } else {
                print("Invalid item index")
            }
        } else {
            print("Invalid section index")
        }
    }

    func removeComponent(inSection: SBIdentifier, atItem: SBIdentifier) {
        removeComponents(inSection: inSection, atItems: [atItem])
    }

    func removeComponents(inSection: SBIdentifier, atItems: [SBIdentifier]) {
        var sectionIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        if let sectionIndex = sectionIndex {
            var indicesToRemove: [Int] = []

            for item in atItems {
                switch item {
                case .byID(let itemId):
                    if let index = sections[sectionIndex].components.firstIndex(where: { $0.id == itemId }) {
                        indicesToRemove.append(index)
                    }
                case .byIndex(let index):
                    if index < sections[sectionIndex].components.count {
                        indicesToRemove.append(index)
                    }
                }
            }

            indicesToRemove.reversed().forEach { sections[sectionIndex].components.remove(at: $0) }

            performUpdate { [weak self] in
                let indexPaths = indicesToRemove.map { IndexPath(item: $0, section: sectionIndex) }

                if let view = self?.view as? UICollectionView {
                    view.deleteItems(at: indexPaths)
                }

                if let view = self?.view as? UITableView {
                    view.deleteRows(at: indexPaths, with: .automatic)
                }
            }
        }
    }

    func removeSupplementaryComponent(inSection: SBIdentifier, kind: SBSectionSupplementaryKind) {
        var sectionIndex: Int?

        switch inSection {
        case .byID(let sectionId):
            sectionIndex = sections.firstIndex(where: { $0.id == sectionId })
        case .byIndex(let index):
            sectionIndex = index < sections.count ? index : nil
        }

        if let sectionIndex = sectionIndex {
            switch kind {
            case .header:
                sections[sectionIndex].header = nil
            case .footer:
                sections[sectionIndex].footer = nil
            }

            performUpdate { [weak self] in
                self?.reloadSection(sectionIndex: sectionIndex)
            }
        }
    }

    private func reloadSection(sectionIndex: Int) {
        let indexPath = IndexPath(item: 0, section: sectionIndex)
        if let view = view as? UICollectionView {
            view.reloadSections(IndexSet(integer: indexPath.section))
        }

        if let view = view as? UITableView {
            view.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
}