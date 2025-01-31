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

    // Outlets
    @IBOutlet private weak var lblError: UILabel!

    // Google Ads
    private var bannerView: GADBannerView!
    private var interstitialView: GADInterstitialAd?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleBanner()
        setupAxeptioListeners()
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

    // MARK: Setups
    private func setupAxeptioListeners() {
        let axeptioListener = AxeptioEventListener()
        axeptioListener.onPopupClosedEvent = { [weak self] in
            self?.showMessage("Consent was closed")
        }
        axeptioListener.onConsentChanged = { [weak self] in
            self?.showMessage("Consent changed")
        }
        axeptioListener.onGoogleConsentModeUpdate = { [weak self] google in
            self?.showMessage("Google consednt updated")

            Analytics.setConsent([
                .analyticsStorage: google.analyticsStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adStorage: google.adStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adUserData: google.adUserData == GoogleConsentStatus.granted ? .granted : .denied,
                .adPersonalization: google.adPersonalization == GoogleConsentStatus.granted ? .granted : .denied
            ])
        }

        Axeptio.shared.setEventListener(axeptioListener)
    }

    private func setupGoogleBanner() {
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.delegate = self

        addBannerViewToView(bannerView)
    }

    // MARK: UI Utils
    private func showMessage(_ message: String) {
        lblError.backgroundColor = .systemYellow
        lblError.text = message

        // Cancel previous execution
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cleanMessage), object: nil)

        // Schedule clean message after 5 min
        perform(#selector(cleanMessage), with: nil, afterDelay: 5)
    }

    @objc
    private func cleanMessage() {
        lblError.backgroundColor = .clear
        lblError.text = nil
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

    // MARK: Button Actions
    @IBAction private func showAxeptioConsent(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            // Axeptio Google v2 Concent
            Axeptio.shared.initialize(targetService: .brands, clientId: "679901100d9a47f71b01afdf", cookiesVersion: "appxeptio-google-manu")
            showMessage("Showing Axeptio Google v2 Consent")

        default:
            // Axeptio Banner Consent
            Axeptio.shared.initialize(targetService: .brands, clientId: "679901100d9a47f71b01afdf", cookiesVersion: "appxeptio-en-MX-LAT")
            showMessage("Showing Axeptio Banner Consent")
        }

        // Launching consent
        Axeptio.shared.showConsentScreen()
    }

    @IBAction private func showGoogleAd(_ sender: UIButton) {

        switch sender.tag {
        case 1:

            Task {
                do {
                    // "ca-app-pub-7637060564520573/2715222893" // real project
                    let myAd = try await GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest())

                    showMessage("Loading Google Ad Intersitial Fullscreen")

                    interstitialView = myAd
                    interstitialView?.fullScreenContentDelegate = self
                    interstitialView?.present(fromRootViewController: self)

                } catch {
                    showMessage(error.localizedDescription)
                }
            }

        default:
            showMessage("Loading Google Ad Banner")

            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }

    @IBAction private func clearConsent() {
        Axeptio.shared.clearConsent()
        showMessage("UserDefaults consent data cleaned")
    }

    @IBAction private func showBrowser() {
        print("Browser shown")

    }
}

// MARK: - Google Ads Setup (GADBannerViewDelegate & GADFullScreenContentDelegate)
extension ViewController: GADBannerViewDelegate, GADFullScreenContentDelegate {

    // For Banner
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        showMessage("Google Ad Banner Error: \(error.localizedDescription)")
    }

    // For Interstitial
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        showMessage("Google Ad Interstitial Error: \(error.localizedDescription)")
    }
}
