# GMAOperaSDKAdapter
# GMAOperaSDKAdapter

Opera Ads SDK 的 Google Mobile Ads (AdMob) 聚合平台自定义适配器。

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/GMAOperaSDKAdapter.svg)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![Platform](https://img.shields.io/cocoapods/p/GMAOperaSDKAdapter.svg?style=flat)](https://cocoapods.org/pods/GMAOperaSDKAdapter)
[![License](https://img.shields.io/cocoapods/l/GMAOperaSDKAdapter.svg?style=flat)](https://github.com/operaads/GMAOperaSDKAdapter/blob/main/LICENSE)

[English](README_EN.MD) | 简体中文

## 概述

GMAOperaSDKAdapter 是一个自定义聚合适配器，使 Opera Advertising SDK (OpAdxSdk) 能够与 Google Mobile Ads (AdMob) 聚合平台无缝集成。该适配器将 Opera Ads SDK 的回调桥接到 AdMob 的聚合回调，实现通过 AdMob 平台进行广告投放。

## 支持的广告格式

- ✅ Banner 广告（标准、自适应）
- ✅ 插屏广告（Interstitial）
- ✅ 激励广告（Rewarded）
- ✅ 原生广告（Native）
- ✅ 开屏广告（AppOpen）

## 版本要求

- iOS 13.0+
- Google Mobile Ads SDK 12.8.0+
- OpAdxSdk 2.12.0
- Xcode 16.0+
- Swift 5.0+

## 安装

### CocoaPods

在您的 `Podfile` 中添加：

```ruby
# Google Mobile Ads SDK
pod 'Google-Mobile-Ads-SDK', '~> 12.8'

# Opera Ads SDK
pod 'OpAdxSdk', '2.12.0'

# Opera Ads AdMob 适配器
pod 'GMAOperaSDKAdapter', '2.12.0.0'
```

然后运行：

```bash
pod install
```

## 快速开始

### 1. 初始化 Google Mobile Ads SDK

```swift
import GoogleMobileAds

// 在 AppDelegate 中初始化
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 初始化 Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start { status in
        print("Google Mobile Ads SDK initialized")
    }
    
    return true
}
```

### 2. 配置自定义广告事件

在 AdMob 后台配置广告单元时：

Mediation -> "Edit mediation group" -> "Edit ad unit mapping" 

**类名（Class Name）**：
所有广告都只用这一个类名
OpAdxAdmobMediationAdapter

**参数（Parameter）** - JSON格式：
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

### 3. 加载和展示广告

使用 Google Mobile Ads 标准 API 加载和展示广告：

#### Banner 广告

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
        
        // 添加到视图
        view.addSubview(bannerView)
    }
}

extension BannerViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner 加载成功")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner 加载失败: \(error.localizedDescription)")
    }
}
```

#### 插屏广告

```swift
import GoogleMobileAds

class InterstitialViewController: UIViewController {
    var interstitialAd: GADInterstitialAd?
    
    func loadInterstitial() {
        GADInterstitialAd.load(withAdUnitID: "your_admob_ad_unit_id",
                               request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("插屏广告加载失败: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            print("插屏广告加载成功")
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
        print("插屏广告展示")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("插屏广告展示失败: \(error.localizedDescription)")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("插屏广告关闭")
        interstitialAd = nil
    }
}
```

#### 激励广告

```swift
import GoogleMobileAds

class RewardedViewController: UIViewController {
    var rewardedAd: GADRewardedAd?
    
    func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: "your_admob_ad_unit_id",
                           request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("激励广告加载失败: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("激励广告加载成功")
        }
    }
    
    func showRewardedAd() {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: self) {
                let reward = ad.adReward
                print("用户获得奖励: \(reward.amount) \(reward.type)")
            }
        }
    }
}

extension RewardedViewController: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("激励广告关闭")
        rewardedAd = nil
    }
}
```

#### 原生广告

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
        print("原生广告加载成功")
        
        // 创建自定义原生广告视图
        let nativeAdView = createNativeAdView()
        
        // 绑定广告数据
        nativeAdView.nativeAd = nativeAd
        
        // 设置广告元素
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        if let iconView = nativeAdView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
        }
        
        if let mediaView = nativeAdView.mediaView {
            mediaView.mediaContent = nativeAd.mediaContent
        }
        
        // 添加到视图
        view.addSubview(nativeAdView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("原生广告加载失败: \(error.localizedDescription)")
    }
}
```

#### 开屏广告

```swift
import GoogleMobileAds

class AppOpenViewController: UIViewController {
    var appOpenAd: GADAppOpenAd?

    func loadAppOpenAd() {
        GADAppOpenAd.load(withAdUnitID: "your_admob_ad_unit_id",
                          request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("开屏广告加载失败: \(error.localizedDescription)")
                return
            }
            self?.appOpenAd = ad
            self?.appOpenAd?.fullScreenContentDelegate = self
            print("开屏广告加载成功")
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
        print("开屏广告展示")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("开屏广告展示失败: \(error.localizedDescription)")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("开屏广告关闭")
        appOpenAd = nil
    }
}
```


## 版本历史

### 2.12.0.0 (2026-07-31)
- 升级依赖 OpAdxSdk 至 2.12.0

### 2.11.2.0 (2026-06-30)
- 升级依赖 OpAdxSdk 至 2.11.2

### 2.11.1.0 (2026-05-22)
- 升级依赖 OpAdxSdk 至 2.11.1

### 2.9.1.0 (2026-04-08)
- 升级依赖 OpAdxSdk 至 2.9.1

### 2.8.3.0 (2026-03-11)
- 使用xcode(16.2)编译,提高兼容性

### 2.8.2.0 (2026-03-10)
- ✅ 支持 Google Mobile Ads SDK 12.8+
- ✅ 添加开屏广告的支持
- ✅ 优化全屏广告生命周期回调顺序
- ✅ 完善错误处理和日志
- ✅ 支持所有主流广告格式

### 2.8.0.0
- 初始版本
- 支持 Banner、Interstitial、Rewarded、Native 广告格式

## 注意事项

### 1. 初始化顺序
Opera Ads SDK 会在首次加载广告时自动初始化，无需手动初始化。

### 2. 回调顺序
适配器严格遵循 Google 文档推荐的回调顺序：

**插屏广告和激励广告展示**：
1. `willPresentFullScreenView()` - 即将展示全屏视图
2. `reportImpression()` - 报告曝光
3. 对于激励广告：`didStartVideo()` - 视频开始播放

**插屏广告和激励广告关闭**：
1. 对于激励广告：`didEndVideo()` - 视频结束播放
2. `willDismissFullScreenView()` - 即将关闭全屏视图
3. `didDismissFullScreenView()` - 已关闭全屏视图

### 3. 原生广告渲染
原生广告的曝光和点击由 Opera Ads SDK 自动追踪，AdMob 会通过以下方法确认：
- `handlesUserImpressions()` 返回 `true`
- `handlesUserClicks()` 返回 `true`

### 4. 错误处理
所有错误都会通过 AdMob 的标准错误回调返回，包含详细的错误信息。

## 调试

### 常见问题

**Q: 广告无法加载？**
A: 检查以下项：
1. AdMob 后台自定义事件配置的类名和参数是否正确
2. Opera Ads SDK 是否成功初始化
3. 查看日志中的详细错误信息

**Q: 类名找不到？**
A: 确保：
1. `GMAOperaSDKAdapter` Pod 已正确安装
2. 网站上类名已配置完成
3. 使用完整类名，`OpAdxAdmobMediationAdapter`
4. 清理并重新构建项目

**Q: 原生广告点击无效？**
A: 确保正确设置了 `GADNativeAdView` 的所有可点击视图。

## 示例项目

完整的示例项目请参考：
- [OpAdxSDK Demo - AdMob Adapter](https://github.com/operaads/iOS-sdk/tree/main/Demo/AdmobAdapter)

## 技术支持

- 📧 Email: chenl@opera.com
- 📖 文档: [Opera Ads iOS SDK 文档]
- 🐛 问题反馈: [GitHub Issues](https://github.com/operaads/GMAOperaSDKAdapter/issues)

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 相关链接

- [Opera Ads SDK](https://github.com/operaads/iOS-sdk)
- [Google Mobile Ads SDK](https://developers.google.com/admob/ios/quick-start)
- [AdMob 自定义事件文档](https://developers.google.com/admob/ios/custom-events)
- [CocoaPods](https://cocoapods.org/pods/GMAOperaSDKAdapter)
