import Flutter
import UIKit

public class SwiftLozzaxCoinPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "oxen_coin", binaryMessenger: registrar.messenger())
        let instance = SwiftLozzaxCoinPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
