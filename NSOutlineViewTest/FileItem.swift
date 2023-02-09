//
//  FileItem.swift
//  NSOutlineViewTest
//
//  Created by woogus on 2023/02/09.
//

import Foundation


class OutlineSampleViewModel: ObservableObject {
    @Published var rootData: [FileItem]

    init() {
        self.rootData = data
    }
    
    func remove(removedItem: [FileItem], dropItem: FileItem?, index: Int) {
        if index == -1 {
            dropItem?.children?.append(contentsOf: removedItem)
        } else {
            dropItem?.children?.insert(contentsOf: removedItem, at: index)
        }
        
        objectWillChange.send()
    }
}


class FileItem: Hashable, Identifiable, CustomStringConvertible {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    var name: String
    var children: [FileItem]? = nil
    var isExpand: DefaultsStorage<Bool> = .init("\(UUID().uuidString)", defaultValue: true)
    
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
    
    init(name: String, children: [FileItem]? = nil) {
        self.name = name
        self.children = children
    }
}

var data = [
    FileItem(name: "doc001.txt"),
    FileItem(
        name: "users",
        children: [
            FileItem(
                name: "user1234",
                children: [
                    FileItem(
                        name: "Photos",
                        children: [
                            FileItem(name: "photo001.jpg"),
                            FileItem(name: "photo002.jpg")]),
                    FileItem(
                        name: "Movies",
                        children: [FileItem(name: "movie001.mp4")]),
                    FileItem(name: "Documents", children: [])]),
            FileItem(
                name: "newuser",
                children: [FileItem(name: "Documents", children: [])])
        ]
    )
]
