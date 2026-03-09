# GMAOperaSDKAdapter

Custom adapter for integrating Opera Ads SDK with Google Mobile Ads (AdMob) mediation platform.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/GMAOperaSDKAdapter.svg)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![Platform](https://img.shields.io/cocoapods/p/GMAOperaSDKAdapter.svg?style=flat)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![License](https://img.shields.io/cocoapods/l/GMAOperaSDKAdapter.svg?style=flat)](https://github.com/luanchen/GMAOperaSDKAdapter/blob/main/LICENSE)

English | [简体中文](README.MD)

## Overview

GMAOperaSDKAdapter is a custom mediation adapter that enables seamless integration of Opera Advertising SDK (OpAdxSdk) with the Google Mobile Ads (AdMob) mediation platform. This adapter bridges Opera Ads SDK callbacks to AdMob mediation callbacks, enabling ad serving through the AdMob platform.

## Supported Ad Formats

- ✅ Banner Ads (Standard, Adaptive)
- ✅ Interstitial Ads
- ✅ Rewarded Ads
- ✅ Native Ads

## Requirements

- iOS 13.0+
- Google Mobile Ads SDK 12.8.0+
- OpAdxSdk 2.8.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

### CocoaPods

Add the following to your `Podfile`:

```ruby
# Google Mobile Ads SDK
pod 'Google-Mobile-Ads-SDK', '~> 12.8'

# Opera Ads SDK
pod 'OpAdxSdk', '~> 2.8.0'

# Opera Ads AdMob Adapter
pod 'GMAOperaSDKAdapter', '~> 2.8.1'
```

Then run:

```bash
pod install
```

## Quick Start

### 1. Initialize Google Mobile Ads SDK

```swift
import GoogleMobileAds

// Initialize in AppDelegate
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start { status in
        print("Google Mobile Ads SDK initialized")
    }
    
    return true
}
```

### 2. Configure Custom Event

When configuring ad units in AdMob dashboard:

1. Select "Mediation"
2. Add "Custom Event"
3. Configure parameters:

**Class Name**:
- Banner: `OpAdxAdmobBannerAd`
- Interstitial: `OpAdxAdmobInterstitialAd`
- Rewarded: `OpAdxAdmobRewardedAd`
- Native: `OpAdxAdmobNativeAd`

**Parameter** - JSON format:
```json
{
  "appId": "your_opera_app_id",
  "bundleId": "your_bundle_id",
  "placementId": "your_opera_placement_id"
}
```

### 3. Load and Show Ads

Use Google Mobile Ads standard APIs to load and show ads:

#### Banner Ads

```swift
import GoogleMobileAds

class BannerViewController: UIViewController {
    var bannerView: GADBannerView!
    
    func loadBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "your_admob_ad_unit_id"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        // Add to view
        view.addSubview(bannerView)
    }
}

extension BannerViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner failed to load: \(error.localizedDescription)")
    }
}
```

#### Interstitial Ads

```swift
import GoogleMobileAds

class InterstitialViewController: UIViewController {
    var interstitialAd: GADInterstitialAd?
    
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "your_admob_ad_unit_id",
                               request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            print("Interstitial loaded successfully")
        }
    }
    
    func showInterstitial() {
        if let ad = interstitialAd {
            ad.present(fromRootViewController: self)
        }
    }
}

extension InterstitialViewController: GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial presented")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Interstitial failed to present: \(error.localizedDescription)")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial dismissed")
        interstitialAd = nil
    }
}
```

#### Rewarded Ads

```swift
import GoogleMobileAds

class RewardedViewController: UIViewController {
    var rewardedAd: GADRewardedAd?
    
    func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: "your_admob_ad_unit_id",
                           request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Rewarded ad failed to load: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded successfully")
        }
    }
    
    func showRewardedAd() {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self) {
                let reward = ad.adReward
                print("User earned reward: \(reward.amount) \(reward.type)")
            }
        }
    }
}

extension RewardedViewController: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Rewarded ad dismissed")
        rewardedAd = nil
    }
}
```

#### Native Ads

```swift
import GoogleMobileAds

class NativeViewController: UIViewController {
    var adLoader: GADAdLoader!
    
    func loadNativeAd() {
        adLoader = GADAdLoader(adUnitID: "your_admob_ad_unit_id",
                               rootViewController: self,
                               adTypes: [.native],
                               options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension NativeViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("Native ad loaded successfully")
        
        // Create custom native ad view
        let nativeAdView = createNativeAdView()
        
        // Bind ad data
        nativeAdView.nativeAd = nativeAd
        
        // Set ad elements
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        if let iconView = nativeAdView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
        }
        
        if let mediaView = nativeAdView.mediaView {
            mediaView.mediaContent = nativeAd.mediaContent
        }
        
        // Add to view
        view.addSubview(nativeAdView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native ad failed to load: \(error.localizedDescription)")
    }
}
```

## Adapter Architecture

### Core Components

```
OpAdxAdapterAdmob/
├── SdkVersion.swift                     # Adapter version
├── OpAdxAdmobMediationAdapter.swift     # Main adapter class
├── OpAdxAdmobInitializer.swift          # SDK initialization manager
├── OpAdxAdmobUtils.swift                # Utility class
├── OpAdxAdmobConstants.swift            # Constants
├── OpAdxAdmobServerParameter.swift      # Server parameter parser
├── OpAdxAdmobBannerAd.swift            # Banner adapter
├── OpAdxAdmobInterstitialAd.swift      # Interstitial adapter
├── OpAdxAdmobRewardedAd.swift          # Rewarded adapter
└── OpAdxAdmobNativeAd.swift            # Native adapter
```

### Callback Mapping

| Opera Ads SDK Callback | Google Mobile Ads Callback |
|------------------------|---------------------------|
| `onAdLoaded` | `completionHandler(self, nil)` |
| `onAdFailedToLoad` | `completionHandler(nil, error)` |
| `onAdDisplayed` | `willPresentFullScreenView()` + `reportImpression()` |
| `onAdClicked` | `reportClick()` |
| `onAdDismissed` | `willDismissFullScreenView()` + `didDismissFullScreenView()` |
| `onAdFailedToShow` | `didFailToPresentWithError()` |
| `didRewardUser` | `didRewardUser()` |

### Native Ad Features

The adapter implements the following native ad protocol methods:

```swift
// Tell AdMob that Opera SDK handles impression tracking
func handlesUserImpressions() -> Bool {
    return true
}

// Tell AdMob that Opera SDK handles click tracking
func handlesUserClicks() -> Bool {
    return true
}

// AdChoices view is automatically added by Opera SDK
var adChoicesView: UIView? {
    return nil
}
```

## Release Notes

### 2.8.1.0 (2026-03-09)
- ✅ Support for Google Mobile Ads SDK 12.8+
- ✅ Added native ad tracking control methods
- ✅ Optimized full-screen ad lifecycle callback order
- ✅ Improved error handling and logging
- ✅ Support for all mainstream ad formats

### 2.8.0.0
- Initial release
- Support for Banner, Interstitial, Rewarded, and Native ad formats

## Important Notes

### 1. Initialization Order
Opera Ads SDK automatically initializes on first ad load, no manual initialization required.

### 2. Callback Order
The adapter strictly follows Google's recommended callback order:

**Interstitial and Rewarded Ad Display**:
1. `willPresentFullScreenView()` - About to present full screen view
2. `reportImpression()` - Report impression
3. For rewarded ads: `didStartVideo()` - Video started

**Interstitial and Rewarded Ad Dismissal**:
1. For rewarded ads: `didEndVideo()` - Video ended
2. `willDismissFullScreenView()` - About to dismiss full screen view
3. `didDismissFullScreenView()` - Dismissed full screen view

### 3. Native Ad Rendering
Native ad impressions and clicks are automatically tracked by Opera Ads SDK, confirmed via:
- `handlesUserImpressions()` returns `true`
- `handlesUserClicks()` returns `true`

### 4. Error Handling
All errors are returned through AdMob's standard error callbacks with detailed error information.

## Debugging

### Enable Logging

```swift
// Google Mobile Ads logging
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = 
    [GADSimulatorID]

// Opera Ads SDK logging (set before SDK initialization)
// See OpAdxSdk documentation for details
```

### Test Ads

Use AdMob test ad unit IDs for testing:
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- Native: `ca-app-pub-3940256099942544/3986624511`

### Common Issues

**Q: Ads not loading?**
A: Check the following:
1. Verify custom event class name and parameters in AdMob dashboard
2. Ensure Opera Ads SDK is successfully initialized
3. Review detailed error messages in logs

**Q: Class not found?**
A: Make sure:
1. `GMAOperaSDKAdapter` Pod is correctly installed
2. Use full class name, e.g., `OpAdxAdmobBannerAd`
3. Clean and rebuild project

**Q: Native ad clicks not working?**
A: Ensure all clickable views are properly set on `GADNativeAdView`.

## Sample Project

For complete sample projects, see:
- [OpAdxSDK Demo - AdMob Adapter](https://github.com/operaads/iOS-sdk/tree/main/Demo/AdmobAdapter)

## Support

- 📧 Email: chenl@opera.com
- 📖 Documentation: [Opera Ads iOS SDK Documentation]
- 🐛 Issue Tracker: [GitHub Issues](https://github.com/luanchen/GMAOperaSDKAdapter/issues)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Related Links

- [Opera Ads SDK](https://github.com/operaads/iOS-sdk)
- [Google Mobile Ads SDK](https://developers.google.com/admob/ios/quick-start)
- [AdMob Custom Events Documentation](https://developers.google.com/admob/ios/custom-events)
- [CocoaPods](https://cocoapods.org/pods/GMAOperaSDKAdapter)
