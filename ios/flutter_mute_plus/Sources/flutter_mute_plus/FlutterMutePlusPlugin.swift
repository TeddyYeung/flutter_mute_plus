import Flutter
import UIKit

public class FlutterMutePlusPlugin: NSObject, FlutterPlugin {

  enum RingerMode: Int {
    case normal = 0
    case silent = 1
    case vibrate = 2
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_mute_plus", binaryMessenger: registrar.messenger())
    let instance = FlutterMutePlusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getRingerMode":
      // TARGET_OS_SIMULATOR is a C macro and no longer resolves in Swift since Xcode 16.
      #if targetEnvironment(simulator)
      result(RingerMode.normal.rawValue)
      #else
      MuteDetect.shared.detectSound { isMute in
        result((isMute ? RingerMode.vibrate : RingerMode.normal).rawValue)
      }
      #endif
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
