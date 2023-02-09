import Cocoa

@available(macOS 10.15, *)
class OutlineViewController<Data: Sequence>: NSViewController where Data.Element: Identifiable & Hashable {
    let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
    
    let outlineView: OutlineView2<Data>
    let dataSource: OutlineViewDataSource2<Data>
    // swiftlint:disable weak_delegate
    let delegate: OutlineViewDelegate2<Data>
    let updater = OutlineViewUpdater<Data>()

    let childrenPath: KeyPath<Data.Element, Data?>
    let expandPath: KeyPath<Data.Element, DefaultsStorage<Bool>>?
    
    init(
        data: Data,
        children: KeyPath<Data.Element, Data?>,
        expand: KeyPath<Data.Element, DefaultsStorage<Bool>>?,
        contextMenu: ContextMenuHandler2<Data.Element>?,
        content: @escaping (Data.Element) -> NSView,
        selectionChanged: @escaping (Set<Data.Element>) -> Void,
        separatorInsets: ((Data.Element) -> NSEdgeInsets)?
    ) {
        outlineView = OutlineView2(contextMenu: contextMenu)
        scrollView.documentView = outlineView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = true
        scrollView.drawsBackground = false

        outlineView.autoresizesOutlineColumn = false
        outlineView.headerView = nil
        outlineView.usesAutomaticRowHeights = true
        outlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        outlineView.allowsMultipleSelection = true
        outlineView.registerForDraggedTypes([.URL, .outlineViewDraggingIndex])

        let onlyColumn = NSTableColumn()
        onlyColumn.resizingMask = .autoresizingMask
        outlineView.addTableColumn(onlyColumn)

        dataSource = OutlineViewDataSource2(
            items: data.map { OutlineViewItem(value: $0, children: children, expand: expand) }
        )
        
        delegate = OutlineViewDelegate2(
            content: content,
            selectionChanged: selectionChanged,
            separatorInsets: separatorInsets
        )
        
        outlineView.dataSource = dataSource
        outlineView.delegate = delegate

        childrenPath = children
        expandPath = expand

        super.init(nibName: nil, bundle: nil)

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func loadView() {
        view = NSView()
    }

    override func viewWillAppear() {
        // Size the column to take the full width. This combined with
        // the uniform column autoresizing style allows the column to
        // adjust its width with a change in width of the outline view.
        outlineView.sizeLastColumnToFit()
        super.viewWillAppear()
    }
}

// MARK: - Performing updates
@available(macOS 10.15, *)
extension OutlineViewController {
    func updateData(newValue: Data) {
        let newState = newValue.map { OutlineViewItem(value: $0, children: childrenPath, expand: expandPath) }

        outlineView.beginUpdates()

        let oldState = dataSource.items
        dataSource.items = newState
        updater.performUpdates(outlineView: outlineView, oldState: oldState, newState: newState, parent: nil)

        outlineView.endUpdates()
    }

    func changeSelectedItem(to items: Set<Data.Element>) {
        delegate.changeSelectedItem(
            to: items.map { OutlineViewItem(value: $0, children: childrenPath, expand: expandPath) },
            in: outlineView
        )
    }

    @available(macOS 11.0, *)
    func setStyle(to style: NSOutlineView.Style) {
        outlineView.style = style
    }

    func setIndentation(to width: CGFloat) {
        outlineView.indentationPerLevel = width
    }

    func setRowSeparator(visibility: SeparatorVisibility) {
        switch visibility {
        case .hidden:
            outlineView.gridStyleMask = []
        case .visible:
            outlineView.gridStyleMask = .solidHorizontalGridLineMask
        }
    }

    func setRowSeparator(color: NSColor) {
        guard color != outlineView.gridColor else {
            return
        }
        
        outlineView.gridColor = color
        outlineView.reloadData()
    }
    
    func setContextMenu(_ contextMenu: ContextMenuHandler2<Data.Element>?) {
        outlineView.contextMenu = contextMenu
    }
    
    func setDropHanlder(_ dropHandler: DropHandler2<Data.Element>?) {
        dataSource.dropHandler = dropHandler
    }
    
    func setDragHandler(_ dragHandler: DragHandler2<Data.Element>?) {
        dataSource.dragHandler = dragHandler
    }
    
    func setDidExpandHandler(_ didExpandHandler: ((OutlineViewItem<Data>) -> Void)?) {
        delegate.didExpandHandler = didExpandHandler
    }
    
    func setWillExpandHandler(_ willExpandHandler: ((OutlineViewItem<Data>) -> Void)?) {
        delegate.willExpandHandler = willExpandHandler
    }
    
    func setWillCollapseHandler(_ willCollapseHandler: ((OutlineViewItem<Data>) -> Void)?) {
        delegate.willCollapseHandler = willCollapseHandler
    }
    
    func setDidCollapseHandler(_ didCollapseHandler: ((OutlineViewItem<Data>) -> Void)?) {
        delegate.didCollapseHandler = didCollapseHandler
    }
    
    func setHideHandler(_ hideHandler: (() -> Void)?) {
        outlineView.hideHandler = hideHandler
    }
}
