import AppKit
import SwiftUI
import Combine

class CellWrapper<Content: View>: NSTableCellView, ObservableObject {
    @Published var isSelected: Bool = false
    @Published var isHovering: Bool = false
    
    init(rootView: Content) {
        super.init(frame: .zero)
        
        let view = rootView.environmentObject(self)
        
        let hostingView = NSHostingView(rootView: view)
        
        addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        trackingAreas.forEach { (area) in
            removeTrackingArea(area)
        }
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .inVisibleRect,
            .activeInKeyWindow
        ]
        
        let newArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(newArea)
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.isHovering = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.isHovering = false
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            isSelected = newValue == .emphasized
        }
    }
    
    var textColor: Color {
        isSelected ? .white : Color(NSColor.labelColor)
    }
}
