//
//  ContentView.swift
//  NSOutlineViewTest
//
//  Created by woogus on 2023/02/09.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    @StateObject var dataSource = OutlineSampleViewModel()
    
    @State var selection: Set<FileItem> = []
    @State var separatorColor: Color = Color(NSColor.separatorColor)
    @State var separatorEnabled = false
    @State var refreshID = UUID()
    
    var body: some View {
        VStack {
            Button("Refresh") {
                refreshID = UUID()
            }
            outlineView
            Divider()
            configBar
        }
        .background(
            colorScheme == .light
                ? Color(NSColor.textBackgroundColor)
                : Color.clear
        )
    }

    var outlineView: some View {
        NSOutlineView2(
            dataSource.rootData,
            children: \.children,
            expand: \.isExpand,
            selections: $selection,
            separatorInsets: { fileItem in
                NSEdgeInsets(top: 0, left: 23, bottom: 0, right: 0)
            }
        ) { fileItem in
            RowContent(fileItem: fileItem).nsView
        }
        .outlineViewStyle(.inset)
        .outlineViewIndentation(20)
        .rowSeparator(separatorEnabled ? .visible : .hidden)
        .rowSeparatorColor(NSColor(separatorColor))
        .onDrag { info in
            return .move
        }
        .onDrop { dropInfos, item, index in
            let itemInfos = dropInfos.compactMap { dropInfo -> OutlineViewItemInfo<FileItem>? in
                switch dropInfo.type {
                case let .item(info):
                    return info
                default:
                    return nil
                }
            }
           
            let removedItem = itemInfos.compactMap { itemInfo -> FileItem? in
                itemInfo.parent?.children?.remove(at: itemInfo.childIndex)
            }
            
            self.dataSource.remove(removedItem: removedItem, dropItem: item, index: index)
            
        }
        .id(refreshID)
    }
    
    var configBar: some View {
        HStack {
            Spacer()
            ColorPicker(
                "Set separator color:",
                selection: $separatorColor)
            Button(
                "Toggle separator",
                action: { separatorEnabled.toggle() })
        }
        .padding([.leading, .bottom, .trailing], 8)
    }
    
    struct RowContent: View, CellWrappable {
        let fileItem: FileItem
        @State var text: String
        
        init(fileItem: FileItem) {
            self.fileItem = fileItem
            text = fileItem.name
        }
        
        var body: some View {
            HStack(spacing: 5) {
                TextField("Title", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: text) { newText in
                fileItem.name = newText
            }
        }
    }
}

protocol CellWrappable: View {}

extension CellWrappable {
    var nsView: NSView {
        CellWrapper(rootView: self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class FileItemView: NSTableCellView {
    init(fileItem: FileItem) {
        let field = NSTextField(string: fileItem.description)
        field.isEditable = true
        field.isSelectable = false
        field.isBezeled = false
        field.drawsBackground = false
        field.usesSingleLineMode = false
        field.cell?.wraps = true
        field.cell?.isScrollable = false

        super.init(frame: .zero)

        addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
