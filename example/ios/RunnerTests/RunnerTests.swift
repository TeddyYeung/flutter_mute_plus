import Flutter
import UIKit
import XCTest


@testable import flutter_mute_plus

class RunnerTests: XCTestCase {

  func testGetRingerModeReturnsNormalOnSimulator() {
    let plugin = FlutterMutePlusPlugin()

    let call = FlutterMethodCall(methodName: "getRingerMode", arguments: nil)

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! Int, FlutterMutePlusPlugin.RingerMode.normal.rawValue)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

}
