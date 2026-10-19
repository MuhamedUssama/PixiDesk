import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var imageChannel: FlutterMethodChannel?
  private var intakeChannel: FlutterMethodChannel?
  private var pendingOpenPaths: [String] = []
  private var intakeReady = false

  func acceptImagePaths(_ paths: [String]) {
    if intakeReady { intakeChannel?.invokeMethod("openFiles", arguments: paths) }
    else { pendingOpenPaths.append(contentsOf: paths) }
  }
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    imageChannel = FlutterMethodChannel(name: "pixidesk/images", binaryMessenger: flutterViewController.engine.binaryMessenger)
    imageChannel?.setMethodCallHandler { call, result in
      guard call.method == "pasteImage" else { result(FlutterMethodNotImplemented); return }
      guard let image = NSImage(pasteboard: NSPasteboard.general),
            let tiff = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:]) else {
        result(nil); return
      }
      result(FlutterStandardTypedData(bytes: png))
    }
    intakeChannel = FlutterMethodChannel(name: "pixidesk/image_intake", binaryMessenger: flutterViewController.engine.binaryMessenger)
    intakeChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      if call.method == "takeOpenFiles" {
        self.intakeReady = true
        result(self.pendingOpenPaths)
        self.pendingOpenPaths.removeAll()
      } else { result(FlutterMethodNotImplemented) }
    }

    super.awakeFromNib()
    (NSApp.delegate as? AppDelegate)?.deliverPendingImages(to: self)
  }
}
