//
//  OutlineViewItemInfo.swift
//  Elixir
//
//  Created by woogus on 2023/02/08.
//  Copyright © 2023 SNOW. All rights reserved.
//

import Foundation

struct OutlineViewItemInfo<T: Identifiable> {
    let item: T
    let parent: T?
    let childIndex: Int
    let column: Int
    
    init(item: T, parent: T?, childIndex: Int, column: Int) {
        self.item = item
        self.parent = parent
        self.childIndex = childIndex
        self.column = column
    }
}
