import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

