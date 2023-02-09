//
//  NSOutlineView2+.swift
//  Elixir
//
//  Created by woogus on 2023/02/08.
//  Copyright © 2023 SNOW. All rights reserved.
//

import Foundation
import AppKit

typealias ContextMenuHandler2<DataElement: Identifiable> = (OutlineViewItemInfo<DataElement>) -> [ContextMenuItem]
typealias DropHandler2<DataElement: Identifiable> = ([DropItemInfo2<DataElement>], DataElement?, Int) -> Void
typealias DragHandler2<DataElement: Identifiable> = (DragItemInfo<DataElement>) -> NSDragOperation

extension NSOutlineView2 {
    func contextMenu(menu: @escaping ContextMenuHandler2<Data.Element>) -> Self {
        var mutableSelf = self
        mutableSelf.contextMenu = menu
        return mutableSelf
    }
    
    func onDrop(perform handler: @escaping DropHandler2<Data.Element>) -> Self {
        var mutableSelf = self
        mutableSelf.dropHandler = handler
        return mutableSelf
    }
    
    func onDrag(perform handler: @escaping DragHandler2<Data.Element>) -> Self {
        var mutableSelf = self
        mutableSelf.dragHandler = handler
        return mutableSelf
    }
    
    func didExpand(perform handler: @escaping (OutlineViewItem<Data>) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.didExpandHandler = handler
        return mutableSelf
    }
    
    func willExpand(perform handler: @escaping (OutlineViewItem<Data>) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.willExpandHandler = handler
        return mutableSelf
    }
    
    func willCollapse(perform handler: @escaping (OutlineViewItem<Data>) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.willCollapseHandler = handler
        return mutableSelf
    }
    
    func didCollapse(perform handler: @escaping (OutlineViewItem<Data>) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.didCollapseHandler = handler
        return mutableSelf
    }
    
    func onHideCommand(perform handler: @escaping () -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.hideHandler = handler
        return mutableSelf
    }
}
