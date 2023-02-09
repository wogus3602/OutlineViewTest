//
//  DragItemInfo.swift
//  Elixir
//
//  Created by woogus on 2023/02/09.
//  Copyright © 2023 SNOW. All rights reserved.
//

import Foundation
import AppKit

struct DragItemInfo<T: Identifiable> {
    let outlineView: NSOutlineView
    let draggingInfo: NSDraggingInfo
    let item: T?
    let childIndex: Int
    
    init(outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, item: T?, childIndex: Int) {
        self.outlineView = outlineView
        self.draggingInfo = draggingInfo
        self.item = item
        self.childIndex = childIndex
    }
}
