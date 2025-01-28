//
//  ViewController.swift
//  AppXeptio
//
//  Created by Manuel Salinas on 1/27/25.
//

import UIKit
import AxeptioSDK
import AppTrackingTransparency
import FirebaseAnalytics
import GoogleMobileAds

class ViewController: UIViewController {

    @IBOutlet private weak var lblError: UILabel!

    // Google Ads
    private var bannerView: GADBannerView!
    private var interstitialView: GADInterstitialAd?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleBanner()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            await requestATTpermission()
        }
    }

    // MARK: App Tracking Transparency
    private func requestATTpermission() async {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        let isAuthorized = (status == .authorized)
        initializeAxeptioCMPUI(isAuthorized)
    }

    private func initializeAxeptioCMPUI(_ granted: Bool) {
        if granted {
            Axeptio.shared.setupUI()
        } else {
            Axeptio.shared.setUserDeniedTracking()
        }
    }

    // MARK: Axeptio Listeners
    private func setupAxeptioListeners() {
        let axeptioListener = AxeptioEventListener()
        axeptioListener.onPopupClosedEvent = {
            print("Popup was closed")
        }
        axeptioListener.onConsentChanged = {
            print("Consent changed")
        }
        axeptioListener.onGoogleConsentModeUpdate = { google in
            print(google.description)

            Analytics.setConsent([
                .analyticsStorage: google.analyticsStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adStorage: google.adStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adUserData: google.adUserData == GoogleConsentStatus.granted ? .granted : .denied,
                .adPersonalization: google.adPersonalization == GoogleConsentStatus.granted ? .granted : .denied
            ])

        }

        Axeptio.shared.setEventListener(axeptioListener)
    }

    // MARK: UI Messages
    private func showMessage(_ message: String) {
        lblError.text = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.lblError.text = nil
        }
    }
}

// MARK: - Button Actions
extension ViewController {
    @IBAction private func showAxeptioConsent() {
        Axeptio.shared.showConsentScreen()
        print("Consent shown")
    }

    @IBAction private func showGoogleAd(_ sender: UIButton) {

        switch sender.tag {
        case 1:

            Task {
                do {
                    // "ca-app-pub-7637060564520573/2715222893" // real project
                    let myAd = try await GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest())

                    interstitialView = myAd
                    interstitialView?.fullScreenContentDelegate = self
                    interstitialView?.present(fromRootViewController: self)

                } catch {
                    showMessage(error.localizedDescription)
                }
            }

        default:
            print("Google Ad Banner shown")

            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }

    @IBAction private func clearConsent() {
        Axeptio.shared.clearConsent()
        print("Consent cleared")
    }

    @IBAction private func showBrowser() {
        print("Browser shown")

    }
}

// MARK: - Google Ads Setup
extension ViewController: GADBannerViewDelegate, GADFullScreenContentDelegate {
    private func setupGoogleBanner() {
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.delegate = self

        addBannerViewToView(bannerView)
    }

    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        // This example doesn't give width or height constraints, as the provided
        // ad size gives the banner an intrinsic content size to size the view.
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
          NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
      }

    // For Banner
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        print("Google Ad Banner Error: ", error.localizedDescription)
        showMessage(error.localizedDescription)
    }

    // For Interstitial
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Google Ad Interstitial Error: ", error.localizedDescription)
        showMessage(error.localizedDescription)
    }
}
