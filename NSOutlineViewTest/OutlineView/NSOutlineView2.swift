import SwiftUI
import Cocoa

@available(macOS 10.15, *)
struct NSOutlineView2<Data: Sequence>: NSViewControllerRepresentable where Data.Element: Identifiable & Hashable {
    typealias NSViewControllerType = OutlineViewController<Data>

    let data: Data
    let children: KeyPath<Data.Element, Data?>
    let expand: KeyPath<Data.Element, DefaultsStorage<Bool>>?
    @Binding var selections: Set<Data.Element>
    var content: (Data.Element) -> NSView
    var separatorInsets: ((Data.Element) -> NSEdgeInsets)?
    
    var hideHandler: (() -> Void)?
    var contextMenu: ContextMenuHandler2<Data.Element>?
    var dropHandler: DropHandler2<Data.Element>?
    var dragHandler: DragHandler2<Data.Element>?
    var didExpandHandler: ((OutlineViewItem<Data>) -> Void)?
    var willExpandHandler: ((OutlineViewItem<Data>) -> Void)?
    var willCollapseHandler: ((OutlineViewItem<Data>) -> Void)?
    var didCollapseHandler: ((OutlineViewItem<Data>) -> Void)?
    
    private var _styleStorage: Any?

    @available(macOS 11.0, *)
    var style: NSOutlineView.Style {
        get {
            _styleStorage.flatMap { $0 as? NSOutlineView.Style } ?? .automatic
        }
        set {
            _styleStorage = newValue
        }
    }

    var indentation: CGFloat = 13.0
    var separatorVisibility: SeparatorVisibility
    var separatorColor: NSColor = .separatorColor

    init(
        _ data: Data,
        children: KeyPath<Data.Element, Data?>,
        expand: KeyPath<Data.Element, DefaultsStorage<Bool>>? = nil,
        selection: Binding<Data.Element?>,
        separatorInsets: ((Data.Element) -> NSEdgeInsets)? = nil,
        content: @escaping (Data.Element) -> NSView
    ) {
        self.data = data
        self.children = children
        self.expand = expand
        self._selections = .init {
            if let sel = selection.wrappedValue {
                return Set([sel])
            }
            
            return Set()
        } set: { newValue in
            selection.wrappedValue = newValue.first
        }
        
        self.separatorInsets = separatorInsets
        self.separatorVisibility = .hidden
        self.content = content
    }

    @available(macOS 11.0, *)
    init(
        _ data: Data,
        children: KeyPath<Data.Element, Data?>,
        expand: KeyPath<Data.Element, DefaultsStorage<Bool>>? = nil,
        selections: Binding<Set<Data.Element>>,
        separatorInsets: ((Data.Element) -> NSEdgeInsets)? = nil,
        content: @escaping (Data.Element) -> NSView
    ) {
        self.data = data
        self.children = children
        self.expand = expand
        self._selections = selections
        self.separatorInsets = separatorInsets
        self.separatorVisibility = .visible
        self.content = content
    }
    
    func makeNSViewController(context: Context) -> OutlineViewController<Data> {
        let controller = OutlineViewController(
            data: data,
            children: children,
            expand: expand,
            contextMenu: contextMenu,
            content: content,
            selectionChanged: { selections = $0 },
            separatorInsets: separatorInsets
        )
        controller.setIndentation(to: indentation)
        if #available(macOS 11.0, *) {
            controller.setStyle(to: style)
        }
        return controller
    }

    func updateNSViewController(_ outlineController: OutlineViewController<Data>, context: Context) {
        outlineController.updateData(newValue: data)
        outlineController.setContextMenu(contextMenu)
        outlineController.changeSelectedItem(to: selections)
        outlineController.setRowSeparator(visibility: separatorVisibility)
        outlineController.setRowSeparator(color: separatorColor)
        outlineController.setDropHanlder(dropHandler)
        outlineController.setDragHandler(dragHandler)
        outlineController.setDidExpandHandler(didExpandHandler)
        outlineController.setWillExpandHandler(willExpandHandler)
        outlineController.setWillCollapseHandler(willCollapseHandler)
        outlineController.setDidCollapseHandler(didCollapseHandler)
        outlineController.setHideHandler(hideHandler)
    }
}

@available(macOS 10.15, *)
extension NSOutlineView2 {

    /// Sets the style for the `OutlineView`.
    @available(macOS 11.0, *)
    func outlineViewStyle(_ style: NSOutlineView.Style) -> Self {
        var mutableSelf = self
        mutableSelf.style = style
        return mutableSelf
    }

    /// Sets the width of the indentation per level for the `OutlineView`.
    func outlineViewIndentation(_ width: CGFloat) -> Self {
        var mutableSelf = self
        mutableSelf.indentation = width
        return mutableSelf
    }

    /// Sets the visibility of the separator between rows of this outline view.
    func rowSeparator(_ visibility: SeparatorVisibility) -> Self {
        var mutableSelf = self
        mutableSelf.separatorVisibility = visibility
        return mutableSelf
    }

    /// Sets the color of the separator between rows of this outline view.
    /// The default color for the separator is `NSColor.separatorColor`.
    func rowSeparatorColor(_ color: NSColor) -> Self {
        var mutableSelf = self
        mutableSelf.separatorColor = color
        return mutableSelf
    }
}
