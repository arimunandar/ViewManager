//
//  ViewManager.swift
//  ViewManager
//
//  Created by Ari Munandar on 31/01/24.
//

import Foundation
import UIKit

public protocol IViewComponent {
    associatedtype ViewType: UIView
    var id: String { get }
    var reuseIdentifier: String { get }
    func configure(view: ViewType)
    func sizeItem(at size: CGSize, property: SectionProperty) -> CGSize
    func height() -> CGFloat
    func isEqual(to other: any IViewComponent) -> Bool
}

public extension IViewComponent {
    var id: String {
        UUID().uuidString
    }

    var reuseIdentifier: String {
        String(describing: ViewType.self)
    }
}

public extension IViewComponent where Self: Equatable {
    func isEqual(to other: any IViewComponent) -> Bool {
        guard let otherComponent = other as? Self else {
            return false
        }
        return self == otherComponent
    }
}

public extension IViewComponent where ViewType: UITableViewCell {
    func sizeItem(at size: CGSize, property: SectionProperty) -> CGSize {
        return .zero
    }
}

public extension IViewComponent where ViewType: UITableViewHeaderFooterView {
    func sizeItem(at size: CGSize, property: SectionProperty) -> CGSize {
        return .zero
    }
}

public extension IViewComponent where ViewType: UICollectionViewCell {
    func height() -> CGFloat {
        return 0.0
    }
}

public extension IViewComponent where ViewType: UICollectionReusableView {
    func height() -> CGFloat {
        return 0.0
    }
}

public struct AnyViewComponent: IViewComponent, Equatable {
    public let id: String
    public let componentType: ViewType.Type
    public let reuseIdentifier: String

    private let configureViewClosure: (ViewType) -> Void
    private let sizeItemClosure: (CGSize, SectionProperty) -> CGSize
    private let heightClosure: () -> CGFloat

    public init<C: IViewComponent>(_ component: C) where C.ViewType: ViewType {
        self.init(id: component.id, component)
    }

    public init<C: IViewComponent>(id: String, _ component: C) where C.ViewType: ViewType {
        self.id = id
        reuseIdentifier = component.reuseIdentifier
        componentType = C.ViewType.self

        configureViewClosure = { view in
            guard let typedView = view as? C.ViewType else {
                return
            }
            component.configure(view: typedView)
        }

        sizeItemClosure = { size, property in
            component.sizeItem(at: size, property: property)
        }

        heightClosure = {
            component.height()
        }
    }

    public func configure(view: UIView) {
        configureViewClosure(view)
    }

    public func sizeItem(at size: CGSize, property: SectionProperty) -> CGSize {
        sizeItemClosure(size, property)
    }

    public func height() -> CGFloat {
        heightClosure()
    }

    public static func == (lhs: AnyViewComponent, rhs: AnyViewComponent) -> Bool {
        lhs.id == rhs.id && lhs.reuseIdentifier == rhs.reuseIdentifier && lhs.componentType == rhs.componentType
    }
}

public struct SectionComponent {
    public var id: String = UUID().uuidString
    public var components: [any IViewComponent]
    public var header: (any IViewComponent)?
    public var footer: (any IViewComponent)?
    public var property: SectionProperty = .init()

    public init(id: String = UUID().uuidString, components: [any IViewComponent], header: (any IViewComponent)? = nil, footer: (any IViewComponent)? = nil, property: SectionProperty = .init()) {
        self.id = id
        self.components = components
        self.header = header
        self.footer = footer
        self.property = property
    }

    static func == (lhs: SectionComponent, rhs: SectionComponent) -> Bool {
        guard lhs.id == rhs.id, lhs.components.count == rhs.components.count else {
            return false
        }

        for (lhsComponent, rhsComponent) in zip(lhs.components, rhs.components) {
            if !lhsComponent.isEqual(to: rhsComponent) {
                return false
            }
        }

        if let lhsHeader = lhs.header, let rhsHeader = rhs.header {
            if !lhsHeader.isEqual(to: rhsHeader) {
                return false
            }
        } else if lhs.header != nil || rhs.header != nil {
            return false
        }

        if let lhsFooter = lhs.footer, let rhsFooter = rhs.footer {
            if !lhsFooter.isEqual(to: rhsFooter) {
                return false
            }
        } else if lhs.footer != nil || rhs.footer != nil {
            return false
        }

        return true
    }
}

public struct SectionProperty {
    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var sectionInset: UIEdgeInsets = .zero
    public var footerReferenceSize: CGSize = .zero
    public var headerReferenceSize: CGSize = .zero

    public init(minimumLineSpacing: CGFloat = 0, minimumInteritemSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero, footerReferenceSize: CGSize = .zero, headerReferenceSize: CGSize = .zero) {
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInset = sectionInset
        self.footerReferenceSize = footerReferenceSize
        self.headerReferenceSize = headerReferenceSize
    }
}

public enum SectionSupplementaryKind {
    case header
    case footer

    public var value: String {
        switch self {
        case .header:
            return "Header"
        case .footer:
            return "Footer"
        }
    }
}
