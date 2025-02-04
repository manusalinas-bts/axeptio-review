# Axeptio iOS SDK Documentation

Welcome to the **Axeptio iOS SDK Samples** project! This repository demonstrates how to implement the Axeptio iOS SDK in your mobile apps.

---

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Requirements](#requirements)
4. [Adding the SDK to Your Project](#adding-the-sdk-to-your-project)
   - [Using CocoaPods](#using-cocoapods)
   - [Using Swift Package Manager](#using-swift-package-manager)
5. [Initializing the SDK](#initializing-the-sdk)
6. [Setting Up the SDK UI](#setting-up-the-sdk-ui)
7. [SwiftUI Integration](#swiftui-integration)
8. [App Tracking Transparency (ATT)](#app-tracking-transparency-att)
9. [Responsibilities: Mobile App vs SDK](#responsibilities-mobile-app-vs-sdk)
10. [Get Stored Consents](#get-stored-consents)
11. [Show Consent Popup on Demand](#show-consent-popup-demand)
12. [Clear Consent](#clear-consent-from-userdefaults)
13. [Share Consent with Webviews](#share-consent-with-webviews)
14. [SDK Events](#sdk-events)
15. [Google Consent Mode v2](#google-consent-mode-v2)

---

## Overview

The project consists of 2 modules:

* `sampleSwift`: Illustrates the usage of the **Axeptio SDK** with **Swift** and **Swift Package Manager (SPM)**.
* `sampleObjectiveC`: Demonstrates the integration of the **Axeptio SDK** with **Objective-C** and **CocoaPods**.


> **[!IMPORTANT]**
> Sample apps contain _testable_ versions for `clientId` and `cookies version`. **_You need to have a plan on your Axeptio account for testing your owns consents._**
---

## Getting Started

To get started with implementing the **Axeptio SDK** in your iOS app, follow these steps:

Clone this repository to your local machine:
```shell
git clone https://github.com/axeptio/sample-app-ios
```

For more details, refer to the [Github documentation](#).

---

## Requirements

Our **SDK** is offered as a precompiled binary package (`XCFramework`) compatible with **iOS 15 and later versions**.

---

## Adding the SDK to Your Project

The package can be added using **CocoaPods** and **Swift Package Manager (SPM).**

### Using CocoaPods

1. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if not already installed.
2. Add the following to your `Podfile`:

    ```ruby
    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '15.0'
    use_frameworks!

    target 'MyApp' do
      pod 'AxeptioIOSSDK'
    end
    ```

3. Run `pod install`.

### Using Swift Package Manager

1. Open your Xcode project.
2. Select your project in the **navigator area**.
3. Go to the **Package Dependencies** section and click the **+** button.
4. Enter the package URL: `https://github.com/axeptio/axeptio-ios-sdk`.
5. Select the **axeptio-ios-sdk** package and click **Add Package**.

---

## Initializing the SDK

In your `AppDelegate`, import the `AxeptioSDK` module and `initialize` it with your API key.

### Swift

```swift
import UIKit
import AxeptioSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           let targetService: AxeptioService = .brands // or .publisherTcf
        // sample init
        Axeptio.shared.initialize(targetService: targetService, clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>")

        // or with a token set from an other device (you are in charge to store and pass the token along between devices)
        Axeptio.shared.initialize(targetService: targetService, clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>", token: "<Token>")

        return true
    }
}
```

### Objective-C

```objc
#import "AppDelegate.h"
@import AxeptioSDK;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    AxeptioService targetService = AxeptioServiceBrands; // or AxeptioServicePublisherTcf

    // sample init
    [Axeptio.shared initializeWithTargetService:targetServiceclientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookies Version>"];

    // or with a token set from an other device
    [Axeptio.shared initializeWithTargetService:targetServiceclientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookies Version>" token:@"<Token>"];

    return YES;
}
@end
```

> **Publishers**
You can transfer a user's consents by providing his Axeptio token.

The SDK will automatically update the `UserDefaults` according to the TCFv2 [IAB Requirements](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)

---

## Setting Up the SDK UI

> **[!IMPORTANT]**
> The setupUI method should be called only from your main/entry UIViewController which in most cases should be once per app launch. Therefore, by calling this method the consent notice and preference views will only be displayed if it is required and only once the SDK is ready.

To display UI elements and interact with the user, call the `setupUI` method from your main `UIViewController`.

### Swift

```swift
import UIKit
import AxeptioSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Axeptio.shared.setupUI()
    }
}
```

### Objective-C

```objc
#import "ViewController.h"
@import AxeptioSDK;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Axeptio.shared setupUI];
}
@end
```

---

## SwiftUI Integration

For **SwiftUI** apps, follow these steps to integrate our SDK:

1. Create a `UIViewController` subclass to call `setupUI`.

```swift
import SwiftUI
import AxeptioSDK

class AxeptioViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Axeptio.shared.setupUI()
    }
}
```

2. Create a `UIViewControllerRepresentable` **struct**.

```swift
struct AxeptioView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        return AxeptioViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
```

3. Use the `UIApplicationDelegateAdaptor` to connect the **AppDelegate**.

```swift
import SwiftUI
import AxeptioSDK

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        Axeptio.shared.initialize(clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>")

        return true
    }
}

@main
struct YourSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AxeptioView()
        }
    }
}
```

---

## App Tracking Transparency (ATT)

Required for **iOS 14.5 and later versions**.

The SDK does not request **ATT permissions**. The app is responsible for managing this process following [Apple's guidelines](https://developer.apple.com/app-store/user-privacy-and-data-use/).

Permission for tracking on iOS can be asked by calling the `ATTrackingManager.requestTrackingAuthorization` function in your app.

#### Show the ATT permission then the CMP notice if the user accepts the ATT permission

This sample shows how to: 
* Show the **ATT permission** request if iOS >= 14
* Show the **Axeptio consent** notice if and only if: 
    * The iOS version is >= 15
    * The user accepted the ATT permission

The Axeptio consent notice will only be displayed if the user accepts the ATT permission OR the ATT permission cannot be displayed for any reason (restricted or iOS < 14).

### Swift

```swift
import UIKit
import AppTrackingTransparency
import AxeptioSDK

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            await handleATTAndInitializeAxeptioCMP()
        }
    }

    private func handleATTAndInitializeAxeptioCMP() async {
        if #available(iOS 14, *) {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            initializeAxeptioCMPUI(granted: status == .authorized)

        } else {
            initializeAxeptioCMPUI(granted: true)
        }
    }

    private func initializeAxeptioCMPUI(granted: Bool) {
        if granted {
            Axeptio.shared.setupUI()
        } else {
            Axeptio.shared.setUserDeniedTracking()
        }
    }
}
```

### Objective-C

```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@import AxeptioSDK;

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (@available(iOS 14, *)) {
        [self requestTrackingAuthorization];
    } else {
        [Axeptio.shared setupUI];
    }
}

- (void)requestTrackingAuthorization {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        BOOL isAuthorized = (status == ATTrackingManagerAuthorizationStatusAuthorized);
        [self initializeAxeptioCMPUI:isAuthorized];
    }];
}

- (void)initializeAxeptioCMPUI:(BOOL)granted {
    if (granted) {
        [Axeptio.shared setupUI];
    } else {
        [Axeptio.shared setUserDeniedTracking];
    }
}

@end
```
---

## Responsibilities: Mobile App vs SDK

The **Axeptio SDK** and your mobile application have distinct responsibilities in managing user consent and tracking:

### Mobile Application Responsibilities:
- Implementing and managing the **App Tracking Transparency (ATT) permission** flow
- Deciding when to show the **ATT prompt** relative to the Axeptio CMP
- Properly _declaring data collection practices_ in **App Store privacy** labels
- Handling **SDK events** and updating app behavior based on user consent

### Axeptio SDK Responsibilities:
- Displaying the consent management platform (CMP) interface
- Managing and storing user consent choices
- Sending consent status through APIs

The SDK **does not automatically handle ATT permissions** - this must be explicitly managed by the host application as shown in the implementation examples above.

## Get stored consents

You can retrieve the consents that are stored by the SDK in UserDefaults:

### Swift
```swift
UserDefaults.standard.object(forKey:"Key")
```

### Objective-C
```objc
 [[NSUserDefaults standardUserDefaults] objectForKey:@"Key"]
```
 
For detailed information about stored values and cookies, please refer to the [Axeptio documentation](https://support.axeptio.eu/hc/en-gb/articles/8558526367249-Does-Axeptio-deposit-cookies).

## Show Consent Popup Demand
You can request the consent popup to open on demand.

### Swift

```swift
Axeptio.shared.showConsentScreen()
```

### Objective-C

```objc
[Axeptio.shared showConsentScreen];
```

## Clear consent from UserDefaults
A method is available to **clear consent** from `UserDefault`.

### Swift
```swift
Axeptio.shared.clearConsent()
```

### Objective-C
```objc
[Axeptio.shared  clearConsent];
```

## Share consent with webviews
>*This feature is only available for **publishers** service.*

You can also add the **SDK token** or any other token to any URL:

- Manually with the `axeptioToken` and `keyAxeptioTokenQueryItem` variables:

### Swift
```swift
Axeptio.shared.axeptioToken
Axeptio.shared.keyAxeptioTokenQueryItem
```

```swift
var urlComponents = URLComponents(string: "<Your URL>")
urlComponents?.queryItems = [URLQueryItem(name: Axeptio.shared.keyAxeptioTokenQueryItem, value: <Axeptio.shared.axeptioToken or Your Token>)]
```
### Objective-C
```objc
[Axeptio.shared axeptioToken];
[Axeptio.shared keyAxeptioTokenQueryItem];
```

```objc
NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:@"<Your URL>"];
urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:[Axeptio.shared keyAxeptioTokenQueryItem] value:[Axeptio.shared axeptioToken]]];
```

- Automatically with the `appendAxeptioTokenToURL` function:  

### Swift

```swift
let updatedURL = Axeptio.shared.appendAxeptioTokenToURL(<Your URL>, token: <Axeptio.shared.axeptioToken or Your Token>)
```

### Objective-C

```objc
NSURL *updatedURL = [[Axeptio shared] appendAxeptioTokenToURL:<Your URL> token:<Axeptio.shared.axeptioToken or Your Token>];
```

--- 

## SDK Events

You can **listen the SDK events** using `AxeptioEventListener`.

### Swift

```swift
let listener = AxeptioEventListener()
listener.onPopupClosedEvent = {
    // * * Handle popup closed
    // Retrieve consents from UserDefaults
    // Check user preferences
    // Run external process/services according user consents
}

listener.onConsentChanged = {
    // * * Handle consent change
    // The Google Consent V2 status
    // Do something
}

Axeptio.shared.setEventListener(listener)
```

### Objective-C

```objc
 AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

[axeptioEventListener setOnPopupClosedEvent:^{
    // The CMP notice is being hidden
    // Do something
}];

[axeptioEventListener setOnConsentChanged:^{
    // The consent status of the user has changed.
    // Do something
}];

[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // The Google Consent V2 status
    // Do something
}];

[Axeptio.shared setEventListener:axeptioEventListener];
```

### Popup events

* `onPopupClosedEvent`: When the consent notice is closed.

* `onConsentChanged`: When a consent is given by the user.

* `onGoogleConsentModeUpdate`: When google consent is update by the user.

---

## Google Consent Mode v2

If you haven't already, add [Firebase Analytics](https://developers.google.com/tag-platform/security/guides/app-consent?hl=fr&consentmode=basic&platform=ios) to your iOS project.

To integrate **Google Consent Mode** with the SDK:

1. Register for **Google Consent** updates.
2. Update **Firebase Analytics consent** statuses.


When user consent is collected through your CMP, the SDK will set the `IABTCF_EnableAdvertiserConsentMode` **key** in **UserDefaults** to `true`.

**Axeptio SDK** provides a `callback` or `closure` to listen to **Google Consent updates**. You'll have to map the consent types and status to the corresponding **Firebase models**. You can then update Firebase analytics consents by calling **Firebase analytics** `setConsent()`.


### Swift

```swift
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    Analytics.setConsent([
        .analyticsStorage: consents.analyticsStorage == .granted ? .granted : .denied,
        .adStorage: consents.adStorage == .denied ? .granted : .denied,
        .adUserData: consents.adUserData == .denied ? .granted : .denied,
        .adPersonalization: consents.adPersonalization == .denied ? .granted : .denied
    ])
}

```

### Objective-C

```objc
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
      [FIRAnalytics setConsent:@{
        FIRConsentTypeAnalyticsStorage : [consents analyticsStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdStorage : [consents adStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdUserData : [consents adUserData] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdPersonalization : [consents adPersonalization] ? FIRConsentStatusGranted : FIRConsentStatusDenied
    }];
}];
```

--- 

> For more detailed information, you can visit the [Axeptio documentation](https://support.axeptio.eu/hc/en-gb/articles/8558526367249-Does-Axeptio-deposit-cookies)

