//
//  DefaultsStorage.swift
//  NSOutlineViewTest
//
//  Created by woogus on 2023/02/09.
//

import Foundation

/**
 property list object에 대해서만 사용해야함
 그 외 타입에 대해선 Codable, JSONEncoder를 통한 별도 decode/encode 작업 추가 필요
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html
 */
@propertyWrapper
struct DefaultsStorage<T> {
    private let key: String
    private let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
