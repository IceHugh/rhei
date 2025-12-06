import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    // Set initial size to 400x600 to prevent resize glitch
    let newSize = NSSize(width: 400, height: 600)
    let newOrigin = self.frame.origin // Keep default origin or we can center later
    let newFrame = NSRect(origin: newOrigin, size: newSize)
    
    self.contentViewController = flutterViewController
    self.setFrame(newFrame, display: true)
    self.center() // Center on screen immediately

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Hide titlebar for clean custom look
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.isMovableByWindowBackground = true

    super.awakeFromNib()
  }
}
