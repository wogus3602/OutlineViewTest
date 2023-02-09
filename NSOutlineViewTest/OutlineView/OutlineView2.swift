//
//  OutlineView2.swift
//  Elixir
//
//  Created by woogus on 2023/02/08.
//  Copyright © 2023 SNOW. All rights reserved.
//

import Foundation
import AppKit

class OutlineView2<Data: Sequence>: NSOutlineView where Data.Element: Identifiable {
    weak var focusedTextField: NSTextField?
    var contextMenu: ContextMenuHandler2<Data.Element>?
    var hideHandler: (() -> Void)?
    private let menuHandler = MenuHandler()
    private var contextualRect = NSRect()
    
    init(contextMenu: ContextMenuHandler2<Data.Element>? = nil) {
        self.contextMenu = contextMenu
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if !contextualRect.isEmpty {
            let rectPath = NSBezierPath(rect: contextualRect)
            let fillColor = NSColor.controlAccentColor
            rectPath.lineWidth = 4
            fillColor.set()
            rectPath.stroke()
        }
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        super.menu(for: event)
        
        contextualRect = NSRect()
        
        let targetRow = row(at: convert(event.locationInWindow, from: nil))
        if targetRow != -1 {
            let rect = rect(ofRow: targetRow)
            
            if !targetRow.isMultiple(of: 2) && usesAlternatingRowBackgroundColors {
                contextualRect = .init(
                    x: rect.origin.x,
                    y: rect.origin.y - 2.5,
                    width: rect.width,
                    height: rect.height + 5
                )
            } else {
                contextualRect = rect
            }
        }
        
        setNeedsDisplay(contextualRect)
        
        let row = row(for: event)
        let col = column(for: event)
         
        guard row > -1, let item = item(atRow: row) as? OutlineViewItem<Data> else {
            return nil
        }
        
        let childIndex = childIndex(forItem: item)
        let parent = parent(forItem: item) as? OutlineViewItem<Data>
        let contextMenuInfo = OutlineViewItemInfo<Data.Element>(
            item: item.value,
            parent: parent?.value,
            childIndex: childIndex,
            column: col
        )
        let contextMenu = contextMenu?(contextMenuInfo) ?? []
        let menu = menuHandler.makeContextMenu(menuItems: contextMenu)

        return menu
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
        let row = row(for: event)
        guard row > -1 else {
            return
        }
        let col = column(for: event)
        if let view = view(atColumn: col, row: row, makeIfNecessary: false),
           let textField = view.subviews(ofType: NSTextField.self).first {
            textField.refusesFirstResponder = true
            focusedTextField = textField
        }
    }

    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        super.didCloseMenu(menu, with: event)
        
        if !contextualRect.isEmpty {
            contextualRect = NSRect()
            setNeedsDisplay(bounds)
        }

        focusedTextField?.refusesFirstResponder = false
        focusedTextField = nil
    }
    
    override func keyDown(with event: NSEvent) {
        if event.characters == "h" || event.characters == "H" || event.characters == "ㅗ" {
            self.hideHandler?()
        } else {
            super.keyDown(with: event)
        }
    }
}

extension NSTableView {
    func point(for event: NSEvent) -> NSPoint {
        guard let superview = superview else {
            return .zero
        }
        
        let tableViewOrigin = superview.convert(frame.origin, to: nil)
        return NSPoint(x: abs(event.locationInWindow.x - tableViewOrigin.x),
                       y: abs(event.locationInWindow.y - tableViewOrigin.y))
    }
    
    func row(for event: NSEvent) -> Int {
        row(at: point(for: event))
    }
    
    func column(for event: NSEvent) -> Int {
        column(at: point(for: event))
    }
}

extension NSView {
    func subviews<T: NSView>(ofType type: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        
        for sub in subviews {
            result.append(contentsOf: sub.subviews(ofType: type))
        }
        
        return result
    }
}
