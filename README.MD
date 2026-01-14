# GMAOperaSDKAdapter iOS Change Log (Swift)

(2.2.16.0) - GMAOperaSDKAdapter init

---

# GMAOperaSDKAdapter 适用于(Google-Mobile-Ads-SDK >= 12.8.0)


**GMAOperaSDKAdapter** 是 Opera Ads SDK 的 **Google(Admob)** 聚合适配器。
通过集成此适配器，您可以在 Google(Admob) 的聚合瀑布流（Waterfall）或 Bidding 系统中加载并展示 Opera 的广告资源，从而最大化您的变现收益。

---

## 📋 功能特性

- [x] 支持 Google(Admob) 自定义 Adapter 接入
- [x] 支持 Native（原生）、Banner、Interstitial、Rewarded广告格式
- [x] 自动处理 Opera SDK 的状态检测与 Mediation 参数注入
- [x] 支持 CocoaPods 一键集成

## 🛠 安装指南

### 使用 CocoaPods (推荐)

在您的项目的 `Podfile` 中添加以下代码：

```ruby
source '[https://github.com/CocoaPods/Specs.git]'

target 'YourProjectTarget' do
    # 添加 TopOn 主 SDK (如果没有)
    pod 'Google-Mobile-Ads-SDK',    '~>12.8.0'

    # 添加 Opera 聚合适配器
    pod 'GMAOperaSDKAdapter'
end
运行安装命令：

Bash
pod install
🚀 快速开始
1. 初始化 SDK (Required)

Adapter不再需要外部初始化代码，内部会自动初始化OpAdxSdk。

2. Google(Admob) 后台配置

要在 Google(Admob) 聚合管理后台中启用 Opera 广告源，请按照以下步骤添加 Custom Network (自定义广告平台)：

登录 Google(Admob) 开发者后台。

进入 广告单元配置 - 配置参数

"{ "bundleId":xxxxxxxxxx", "appId":"pubxxxxxxxxxxxxxx/epxxxxxxxxxxxxxx/appxxxxxxxxxxxxxx", "placementId": "xxxxxxxxxxxxxxx" }

添加 appId (pub1xxxxxxxxx/ep1xxxxxxxxx/app1xxxxxxxxx)
添加 placementId xxxxxxxxxxxxxxx
添加 bundleId  (苹果的appid,一串数字)

添加一个新的自定义广告源，并填写以下 Adapter 类名信息：

广告类型 (Ad Type)        Adapter 类名 (Class Name)
Native (原生广告)           OpAdxAdmobMediationAdapter
Banner (横幅广告)           OpAdxAdmobMediationAdapter
Interstitial (插屏广告)     OpAdxAdmobMediationAdapter
RewardVideo (激励广告)      OpAdxAdmobMediationAdapter


```
