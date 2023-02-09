//
//  ContextMenuItem.swift
//  NSOutlineViewTest
//
//  Created by woogus on 2023/02/09.
//

import Foundation
import AppKit

struct ContextMenuItem {
    init(_ kind: ContextMenuItem.Kind,
         keyEquivalent: String = "",
         isEnabled: Bool = true,
         action: (() -> Void)? = nil,
         children: [ContextMenuItem]? = nil) {
        self.kind = kind
        self.isEnabled = isEnabled
        self.action = action
        self.children = children
        self.keyEquivalent = keyEquivalent
    }
    
    struct MenuCustomView {
        init(_ view: NSView, width: CGFloat, height: CGFloat) {
            view.frame = .init(x: 0, y: 0, width: width, height: height)
            self.view = view
        }
        
        let view: NSView
    }
    
    enum Kind {
        case title(String, imageName: String? = nil)
        case view(MenuCustomView)
        case separator
    }
    
    let id = UUID().uuidString
    var keyEquivalent: String
    var kind: Kind
    var isEnabled: Bool
    var action: (() -> Void)?
    var children: [Self]?
    
    static let separator: Self = .init(.separator)
    static let empty: Self = .init(.title("Empty"))
}

