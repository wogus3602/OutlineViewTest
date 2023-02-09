import Cocoa

@available(macOS 10.15, *)
class OutlineViewDataSource2<Data: Sequence>: NSObject, NSOutlineViewDataSource
where Data.Element: Identifiable {
    var items: [OutlineViewItem<Data>]
    var dropHandler: DropHandler2<Data.Element>?
    var dragHandler: DragHandler2<Data.Element>?
    
    init(items: [OutlineViewItem<Data>]) {
        self.items = items
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? OutlineViewItem<Data> {
            return item.children?.count ?? 0
        } else {
            return items.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? OutlineViewItem<Data> else {
            return false
        }
        
        return item.children != nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? OutlineViewItem<Data>,
           let children = item.children {
            return children[index]
        } else {
            return items[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let row = outlineView.row(forItem: item)
        
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setPropertyList(row, forType: .outlineViewDraggingIndex)
        
//        if let resourceItem = item as? Data.Element {
//            pasteboardItem.setString(resourceItem.url.absoluteString, forType: .fileURL)
//        }
        
        return pasteboardItem
    }
    
    func outlineView(
        _ outlineView: NSOutlineView,
        validateDrop info: NSDraggingInfo,
        proposedItem item: Any?,
        proposedChildIndex index: Int
    ) -> NSDragOperation {
        guard let dragHandler = dragHandler else {
            return NSDragOperation()
        }
        
        let dragItemInfo = DragItemInfo(
            outlineView: outlineView,
            draggingInfo: info,
            item: (item as? OutlineViewItem<Data>)?.value,
            childIndex: index
        )
        
        return dragHandler(dragItemInfo)
    }
    
    func outlineView(
        _ outlineView: NSOutlineView,
        acceptDrop info: NSDraggingInfo,
        item: Any?,
        childIndex index: Int
    ) -> Bool {
        guard let dropHandler = self.dropHandler else {
            return false
        }
        
        var dropItemInfos: [DropItemInfo2<Data.Element>] = []
        
        info.draggingPasteboard.pasteboardItems?.forEach { droppedPasteboardItem in
            if droppedPasteboardItem.availableType(from: [.outlineViewDraggingIndex]) != nil,
               let draggingItem: OutlineViewItem<Data> = droppedPasteboardItem.draggingItem2(outlineView: outlineView) {
                let parent = outlineView.parent(forItem: draggingItem) as? OutlineViewItem<Data>
                let childIndex = outlineView.childIndex(forItem: draggingItem)
                let dropItem = OutlineViewItemInfo(item: draggingItem.value, parent: parent?.value, childIndex: childIndex, column: -1)
                let dropItemInfo = DropItemInfo2<Data.Element>(type: .item(dropItem))
                dropItemInfos.append(dropItemInfo)
            } else if droppedPasteboardItem.availableType(from: [.fileURL]) != nil,
                      let data = droppedPasteboardItem.data(forType: .fileURL),
                      let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
                dropItemInfos.append(DropItemInfo2<Data.Element>(type: .fileURL(fileURL)))
            }
        }
        
        dropHandler(dropItemInfos, (item as? OutlineViewItem<Data>)?.value, index)
        
        return true
    }
}

extension NSPasteboard.PasteboardType {
    static let outlineViewDraggingIndex = NSPasteboard.PasteboardType("com.snowcorp.elixir.outlineViewDraggingIndex")
}

extension NSDraggingInfo {
    func draggingItem2<D: Sequence>(outlineView: NSOutlineView) -> OutlineViewItem<D>? where D.Element: Identifiable {
        guard let row = draggingPasteboard.propertyList(forType: .outlineViewDraggingIndex) as? Int else {
            return nil
        }

        let item = outlineView.item(atRow: row) as? OutlineViewItem<D>
                
        return item
    }
}

extension NSPasteboardItem {
    func draggingItem2<D: Sequence>(outlineView: NSOutlineView) -> OutlineViewItem<D>? where D.Element: Identifiable {
        guard let row = self.propertyList(forType: .outlineViewDraggingIndex) as? Int else {
            return nil
        }

        let item = outlineView.item(atRow: row) as? OutlineViewItem<D>
        
        return item
    }
}
