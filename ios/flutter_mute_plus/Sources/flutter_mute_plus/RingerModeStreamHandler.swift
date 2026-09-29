import Flutter
import UIKit

// iOS posts no notification for the mute switch, so it is polled while the app is active.
class RingerModeStreamHandler: NSObject, FlutterStreamHandler {

  private static let pollInterval: TimeInterval = 1

  private var events: FlutterEventSink?
  private var timer: Timer?
  private var lastMode: FlutterMutePlusPlugin.RingerMode?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.events = events
    #if !targetEnvironment(simulator)
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(startPolling), name: UIApplication.didBecomeActiveNotification, object: nil)
    center.addObserver(self, selector: #selector(stopPolling), name: UIApplication.willResignActiveNotification, object: nil)
    if UIApplication.shared.applicationState == .active {
      startPolling()
    }
    #endif
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    stopPolling()
    events = nil
    lastMode = nil
    return nil
  }

  @objc private func startPolling() {
    guard timer == nil else { return }
    timer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
      self?.detect()
    }
    // lastMode survives inactive periods, so a switch flipped from Control Center is reported on return.
    detect()
  }

  @objc private func stopPolling() {
    timer?.invalidate()
    timer = nil
  }

  private func detect() {
    MuteDetect.shared.detectSound { [weak self] isMute in
      guard let self = self, self.timer != nil else { return }
      let mode: FlutterMutePlusPlugin.RingerMode = isMute ? .vibrate : .normal
      defer { self.lastMode = mode }
      guard let lastMode = self.lastMode, lastMode != mode else { return }
      self.events?(mode.rawValue)
    }
  }
}
