import Flutter
import UIKit
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
////    GeneratedPluginRegistrant.register(with: self)
////    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//      return true
//  }
//}


let flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

