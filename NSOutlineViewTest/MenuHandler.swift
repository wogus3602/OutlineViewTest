import AppKit

class MenuHandler: NSObject {
    private var contextMenuActions = [String: () -> Void]()
    
    @objc func handleMenuEvent(_ sender: Any) {
        let menuItem = sender as! NSMenuItem
        let id = menuItem.identifier!.rawValue
        
        contextMenuActions[id]?()
    }
    
    private func makeMenuItem(item: ContextMenuItem) -> NSMenuItem {
        let menuItem: NSMenuItem
        
        switch item.kind {
        case let .title(title, imageName):
            menuItem = NSMenuItem(title: title,
                                  action: #selector(handleMenuEvent(_:)),
                                  keyEquivalent: item.keyEquivalent)
            
            if item.isEnabled {
                menuItem.target = self
            }
            menuItem.identifier = .init(rawValue: item.id)
            
            if let name = imageName {
                let imageSize = CGSize(width: 18, height: 18)
                menuItem.image = image(name)
                    .resize(size: imageSize)
            }
        case .view(let viewConfig):
            menuItem = NSMenuItem()
            menuItem.view = viewConfig.view
            if item.isEnabled {
                menuItem.target = self
            }
            menuItem.action = #selector(handleMenuEvent(_:))
        case .separator:
            menuItem = .separator()
        }
        
        return menuItem
    }
    
    private func image(_ name: String) -> NSImage {
        if let systemImage = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
            return systemImage
        }
        
        return #imageLiteral(resourceName: name)
    }
    
    func makeContextMenu(menuItems: [ContextMenuItem], menu: NSMenu = .init()) -> NSMenu {
        for item in menuItems {
            if let children = item.children {
                let childMenu = makeContextMenu(menuItems: children, menu: .init(title: ""))
                let menuItem = makeMenuItem(item: item)
                
                menuItem.submenu = childMenu
                menu.addItem(menuItem)
            } else {
                let menuItem = makeMenuItem(item: item)
                menu.addItem(menuItem)
                contextMenuActions[item.id] = item.action
            }
        }
        
        return menu
    }
}

extension NSImage {
    func resize(size targetSize: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
            return representation.draw(in: frame)
        })
        
        return image
    }
}
