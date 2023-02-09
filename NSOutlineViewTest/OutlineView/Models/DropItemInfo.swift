//
//  DropItemInfo.swift
//  Elixir
//
//  Created by woogus on 2023/02/08.
//  Copyright © 2023 SNOW. All rights reserved.
//

import Foundation

struct DropItemInfo2<T: Identifiable> {
    enum `Type` {
        case fileURL(URL)
        case item(OutlineViewItemInfo<T>)
    }
    
    let type: Type
}
