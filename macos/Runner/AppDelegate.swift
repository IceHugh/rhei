import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var statusItem: NSStatusItem?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let timerChannel = FlutterMethodChannel(name: "com.example.flow/timer",
                                              binaryMessenger: controller.engine.binaryMessenger)
    
    timerChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      if call.method == "updateTimer" {
        if let args = call.arguments as? [String: Any],
           let timeText = args["time"] as? String {
           self.updateStatusItem(text: timeText)
        }
        result(nil)
      } else if call.method == "clearTimer" {
        self.removeStatusItem()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    super.applicationDidFinishLaunching(notification)
  }

  func updateStatusItem(text: String) {
    if statusItem == nil {
      statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
      if let button = statusItem?.button {
        button.action = #selector(statusBarButtonClicked(_:))
        button.target = self
      }
    }
    if let button = statusItem?.button {
      button.title = text
    }
  }

  @objc func statusBarButtonClicked(_ sender: Any?) {
    NSApp.activate(ignoringOtherApps: true)
    mainFlutterWindow?.makeKeyAndOrderFront(nil)
  }

  func removeStatusItem() {
    if let item = statusItem {
      NSStatusBar.system.removeStatusItem(item)
      statusItem = nil
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}