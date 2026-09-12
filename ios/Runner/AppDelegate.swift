import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO: Replace with a real Maps SDK for iOS key from the Google Cloud
    // console (restricted to this app's bundle id) before release — see the
    // matching TODO in android/app/src/main/res/values/strings.xml. Without
    // a real key the map picker (lib/shared/widgets/map_address_picker.dart)
    // renders a blank/grey map; pin dropping and coordinate capture still
    // work, only tile rendering needs the key.
    GMSServices.provideAPIKey("REPLACE_WITH_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
