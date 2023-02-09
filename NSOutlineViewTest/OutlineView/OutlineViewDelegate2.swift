import Cocoa

@available(macOS 10.15, *)
class OutlineViewDelegate2<Data: Sequence>: NSObject, NSOutlineViewDelegate
where Data.Element: Identifiable & Hashable {
    let content: (Data.Element) -> NSView
    let selectionChanged: (Set<Data.Element>) -> Void
    let separatorInsets: ((Data.Element) -> NSEdgeInsets)?
    var selectedItems: [OutlineViewItem<Data>] = []
    
    var didExpandHandler: ((OutlineViewItem<Data>) -> Void)?
    var willExpandHandler: ((OutlineViewItem<Data>) -> Void)?
    var willCollapseHandler: ((OutlineViewItem<Data>) -> Void)?
    var didCollapseHandler: ((OutlineViewItem<Data>) -> Void)?
    
    init(
        content: @escaping (Data.Element) -> NSView,
        selectionChanged: @escaping (Set<Data.Element>) -> Void,
        separatorInsets: ((Data.Element) -> NSEdgeInsets)?
    ) {
        self.content = content
        self.selectionChanged = selectionChanged
        self.separatorInsets = separatorInsets
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? OutlineViewItem<Data> else {
            return nil
        }
        
        return content(item.value)
    }

    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        if #available(macOS 11.0, *) {
            releaseUnusedRowViews(from: outlineView)
            let rowView = AdjustableSeparatorRowView(frame: .zero)
            guard let item = item as? OutlineViewItem<Data> else {
                return nil
            }
            rowView.separatorInsets = separatorInsets?(item.value)
            return rowView
        } else {
            return nil
        }
    }

    func releaseUnusedRowViews(from outlineView: NSOutlineView) {
        guard #available(macOS 11.0, *) else {
            return
        }

        let purgatoryPath = unmangle("^qnvC`s`-^qnvUhdvOtqf`snqx")
        if let rowViewPurgatory = outlineView.value(forKeyPath: purgatoryPath) as? NSMutableSet {
            rowViewPurgatory
                .compactMap { $0 as? AdjustableSeparatorRowView }
                .forEach {
                    $0.removeFromSuperview()
                    rowViewPurgatory.remove($0)
                }
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        let columnHorizontalInset: CGFloat
        if #available(macOS 11.0, *) {
            if outlineView.effectiveStyle == .plain {
                columnHorizontalInset = 18
            } else {
                columnHorizontalInset = 9
            }
        } else {
            columnHorizontalInset = 9
        }

        guard let column = outlineView.tableColumns.first else {
            return .zero
        }
        
        let indentInset = CGFloat(outlineView.level(forItem: item)) * outlineView.indentationPerLevel
        let width = column.width - indentInset - columnHorizontalInset
        
        guard let item = item as? OutlineViewItem<Data> else {
            return .zero
        }
        
        let view = content(item.value)
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        return view.fittingSize.height
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? OutlineViewItem<Data> else {
            return
        }
        
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        didExpandHandler?(item)
            
        if outlineView.selectedRow == -1 {
            selectRow(in: outlineView)
        }
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? OutlineViewItem<Data> else {
            return
        }
        
        willExpandHandler?(item)
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? OutlineViewItem<Data> else {
            return
        }
        
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        willCollapseHandler?(item)
        
        let isChildrenSelected = isChildrenSelected(outlineView: outlineView, item: item)
        
        if isChildrenSelected {
            let row = outlineView.row(forItem: item)
            outlineView.selectRowIndexes([row], byExtendingSelection: false)
        }
    }
    
    func isChildrenSelected(outlineView: NSOutlineView, item: OutlineViewItem<Data>) -> Bool {
        if let children = item.children {
            for item in children {
                let row = outlineView.row(forItem: item)
                
                if outlineView.selectedRowIndexes.contains(row) {
                    return true
                }
                
                return isChildrenSelected(outlineView: outlineView, item: item)
            }
        }
        
        return false
    }
    
    func outlineViewItemDidCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? OutlineViewItem<Data> else {
            return
        }
        
        didCollapseHandler?(item)
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        let selectedRows = outlineView.selectedRowIndexes
        let selectedItemIndexSet = selectedItemIndexSet(outlineView: outlineView)
        
        if selectedItemIndexSet != selectedRows {
            let selection = selectedRows
                .compactMap { outlineView.item(atRow: $0) }
                .compactMap { $0 as? OutlineViewItem<Data> }
                .map { $0.value }
            selectionChanged(Set(selection))
        }
    }

    private func selectRow(in outlineView: NSOutlineView) {
        let selectedItemIndexSet = selectedItemIndexSet(outlineView: outlineView)
        
        if selectedItemIndexSet.isEmpty {
            outlineView.deselectAll(nil)
        } else {
            outlineView.selectRowIndexes(selectedItemIndexSet, byExtendingSelection: false)
        }
    }

    func changeSelectedItem(to items: [OutlineViewItem<Data>], in outlineView: NSOutlineView) {
        selectedItems = items
        selectRow(in: outlineView)
    }
    
    private func selectedItemIndexSet(outlineView: NSOutlineView) -> IndexSet {
        selectedItems.reduce(into: IndexSet()) {
            let index = outlineView.row(forItem: $1)
            if index > -1 {
                $0.insert(index)
            }
        }
    }
}
