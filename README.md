# BilliardsTracker

BilliardsTracker is an app that allows users to track their billiards training using Apple Watch gestures and monitor session progress and statistics on iPhone device.

BilliardsTracker is built using the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and SwiftUI.

[![Download BilliardsTracker on the App Store](https://www.ioys.lt/BilliardsTracker/images/appstore.png)](https://apps.apple.com/app/id1580929676)

[![BilliardsTracker screenshots](https://www.ioys.lt/BilliardsTracker/images/collage.png)](https://apps.apple.com/app/id1580929676)

# Usage
1. Make sure that you have paired iOS and WatchOS simulators:
    ```sh
    xcrun simctl list
    ```
2. If needed you can pair the devices by running:
    ```sh
    xcrun simctl pair <watch device id> <phone device id>
    ```
3. Clone the project:
    ```sh
    git clone https://github.com/brien84/BilliardsTracker.git
    ```
4. Open the project in Xcode:
    ```sh
    cd BilliardsTracker
    open BilliardsTracker.xcodeproj
    ```
5. Run `BilliardsTracker` and `BilliardsTrackerWatchApp` targets on the paired iOS and WatchOS simulators.
6. If you're having trouble establishing a connection between the devices, try setting the `WKRunsIndependentlyOfCompanionApp` property in the `info.plist` file of the `BilliardsTrackerWatchApp` target to `false`.
