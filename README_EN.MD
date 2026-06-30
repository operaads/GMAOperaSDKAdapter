# GMAOperaSDKAdapter

Custom mediation adapter for Opera Ads SDK integration with Google Mobile Ads (AdMob) platform.

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/GMAOperaSDKAdapter.svg)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![Platform](https://img.shields.io/cocoapods/p/GMAOperaSDKAdapter.svg?style=flat)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![License](https://img.shields.io/cocoapods/l/GMAOperaSDKAdapter.svg?style=flat)](https://github.com/operaads/GMAOperaSDKAdapter/blob/main/LICENSE)

English | [简体中文](README.MD)

## Overview

GMAOperaSDKAdapter is a custom mediation adapter that enables seamless integration between Opera Advertising SDK (OpAdxSdk) and Google Mobile Ads (AdMob) mediation platform. This adapter bridges Opera Ads SDK callbacks to AdMob's mediation callbacks, enabling ad serving through the AdMob platform.

## Supported Ad Formats

- ✅ Banner Ads (Standard, Adaptive)
- ✅ Interstitial Ads
- ✅ Rewarded Ads
- ✅ Native Ads
- ✅ App Open Ads

## Requirements

- iOS 13.0+
- Google Mobile Ads SDK 12.8.0+
- OpAdxSdk 2.11.2
- Xcode 16.0+
- Swift 5.0+

## Installation

### CocoaPods

Add the following to your `Podfile`:

```ruby
# Google Mobile Ads SDK
pod 'Google-Mobile-Ads-SDK', '~> 12.8'

# Opera Ads SDK
pod 'OpAdxSdk', '2.11.2'

# Opera Ads AdMob Adapter
pod 'GMAOperaSDKAdapter', '2.11.2.0'
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

When configuring ad units in AdMob console:

Mediation -> "Edit mediation group" -> "Edit ad unit mapping"

**Class Name**:
Use this single class name for all ad formats:
OpAdxAdmobMediationAdapter

**Parameter** - JSON format:
```json
{
  "appId": "your_opera_app_id",
  "bundleId": "your_bundle_id",
  "placementId": "your_opera_placement_id"
}
```

Example:
```json
{
  "bundleId": "xxxxxxxxxx",
  "appId": "pubxxxxxxxxxxxxxx/epxxxxxxxxxxxxxx/appxxxxxxxxxxxxxx",
  "placementId": "xxxxxxxxxxxxxxx"
}
```

### 3. Load and Display Ads

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

#### App Open Ads

```swift
import GoogleMobileAds

class AppOpenViewController: UIViewController {
    var appOpenAd: GADAppOpenAd?

    func loadAppOpenAd() {
        GADAppOpenAd.load(withAdUnitID: "your_admob_ad_unit_id",
                          request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("App Open ad failed to load: \(error.localizedDescription)")
                return
            }
            self?.appOpenAd = ad
            self?.appOpenAd?.fullScreenContentDelegate = self
            print("App Open ad loaded successfully")
        }
    }

    func showAppOpenAd() {
        if let ad = appOpenAd {
            ad.present(fromRootViewController: self)
        }
    }
}

extension AppOpenViewController: GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("App Open ad presented")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("App Open ad failed to present: \(error.localizedDescription)")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("App Open ad dismissed")
        appOpenAd = nil
    }
}
```


## Version History

### 2.11.2.0 (2026-06-30)
- Upgraded OpAdxSdk dependency to 2.11.2

### 2.11.1.0 (2026-05-22)
- Upgraded OpAdxSdk dependency to 2.11.1

### 2.9.1.0 (2026-04-08)
- Upgraded OpAdxSdk dependency to 2.9.1

### 2.8.3.0 (2026-03-11)
- Compiled using Xcode (16.2) to enhance compatibility

### 2.8.2.0 (2026-03-10)
- ✅ Support for Google Mobile Ads SDK 12.8+
- ✅ Added App Open ad format support
- ✅ Optimized full-screen ad lifecycle callback order
- ✅ Enhanced error handling and logging
- ✅ Support for all major ad formats

### 2.8.0.0
- Initial release
- Support for Banner, Interstitial, Rewarded, and Native ad formats

## Important Notes

### 1. Initialization Order
Opera Ads SDK will automatically initialize on first ad load, no manual initialization required.

### 2. Callback Order
The adapter strictly follows Google's recommended callback order:

**Interstitial and Rewarded Ad Presentation**:
1. `willPresentFullScreenView()` - About to present full-screen view
2. `reportImpression()` - Report impression
3. For rewarded ads: `didStartVideo()` - Video started playing

**Interstitial and Rewarded Ad Dismissal**:
1. For rewarded ads: `didEndVideo()` - Video ended
2. `willDismissFullScreenView()` - About to dismiss full-screen view
3. `didDismissFullScreenView()` - Full-screen view dismissed

### 3. Native Ad Rendering
Native ad impressions and clicks are automatically tracked by Opera Ads SDK, confirmed via:
- `handlesUserImpressions()` returns `true`
- `handlesUserClicks()` returns `true`

### 4. Error Handling
All errors are returned through AdMob's standard error callbacks with detailed error information.

## Troubleshooting

### Common Issues

**Q: Ads not loading?**
A: Check the following:
1. Verify custom event class name and parameters are correctly configured in AdMob console
2. Ensure Opera Ads SDK is successfully initialized
3. Check console logs for detailed error messages

**Q: Class not found?**
A: Make sure:
1. `GMAOperaSDKAdapter` Pod is correctly installed
2. Class name is configured on the website
3. Use the full class name: `OpAdxAdmobMediationAdapter`
4. Clean and rebuild your project

**Q: Native ad clicks not working?**
A: Ensure all clickable views are properly set in `GADNativeAdView`.

## Sample Project

For a complete sample project, see:
- [OpAdxSDK Demo - AdMob Adapter](https://github.com/operaads/iOS-sdk/tree/main/Demo/AdmobAdapter)

## Technical Support

- 📧 Email: chenl@opera.com
- 📖 Documentation: [Opera Ads iOS SDK Documentation]
- 🐛 Issue Tracker: [GitHub Issues](https://github.com/operaads/GMAOperaSDKAdapter/issues)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Related Links

- [Opera Ads SDK](https://github.com/operaads/iOS-sdk)
- [Google Mobile Ads SDK](https://developers.google.com/admob/ios/quick-start)
- [AdMob Custom Events Documentation](https://developers.google.com/admob/ios/custom-events)
- [CocoaPods](https://cocoapods.org/pods/GMAOperaSDKAdapter)
