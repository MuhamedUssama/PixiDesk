import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var pendingImagePaths: [String] = []

  override func application(_ sender: NSApplication, openFiles filenames: [String]) {
    if let window = mainFlutterWindow as? MainFlutterWindow {
      window.acceptImagePaths(filenames)
    } else { pendingImagePaths.append(contentsOf: filenames) }
    sender.reply(toOpenOrPrint: .success)
  }

  func deliverPendingImages(to window: MainFlutterWindow) {
    guard !pendingImagePaths.isEmpty else { return }
    window.acceptImagePaths(pendingImagePaths)
    pendingImagePaths.removeAll()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    if let window = mainFlutterWindow as? MainFlutterWindow { deliverPendingImages(to: window) }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
