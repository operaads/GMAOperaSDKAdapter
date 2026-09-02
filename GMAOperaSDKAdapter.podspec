Pod::Spec.new do |spec|
  # ――― 基本信息 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "GMAOperaSDKAdapter"
  spec.version      = "2.14.0.0"
  spec.summary      = "Opera Ads Custom Adapter for Google Mobile Ads (AdMob) Mediation Platform."
  spec.description  = <<-DESC
    GMAOperaSDKAdapter is a custom mediation adapter that enables the integration of 
    Opera Advertising SDK (OpAdxSdk) with the Google Mobile Ads (AdMob) mediation platform.
    
    Supported Ad Formats:
    - Banner Ads (Standard, Adaptive)
    - Interstitial Ads
    - Rewarded Ads
    - Native Ads
    
    This adapter bridges Opera Ads SDK callbacks to Google Mobile Ads mediation callbacks, 
    enabling seamless ad serving through the AdMob platform.
  DESC

  spec.homepage     = "https://github.com/operaads/GMAOperaSDKAdapter"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Opera Ads" => "chenl@opera.com" }

  # ――― 平台设置 ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.platform     = :ios, "13.0"
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.0"

  # ――― 源码位置 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source       = {
    :git => "https://github.com/operaads/GMAOperaSDKAdapter.git", 
    :tag => "#{spec.version}" 
  }

  # ――― 文件与依赖配置 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  # 制作静态包的关键设置
  spec.static_framework = true

  spec.vendored_frameworks = "OpAdxAdapterAdmob.xcframework"
  # 源码路径 - Swift源文件
  # spec.source_files  = "OpAdxAdapterAdmob/**/*.swift"

  # --- 依赖项 ---
  # Google Mobile Ads SDK - 要求12.8或更高版本
  spec.dependency 'Google-Mobile-Ads-SDK', '>= 12.8.0'

  # Opera Ads SDK - 使用CocoaPods发布的版本
  spec.dependency 'OpAdxSdk', '2.14.0'

  # ――― 工程配置 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # 静态库需要 -ObjC 标志以加载 Category
  # spec.pod_target_xcconfig = { 
  #   'OTHER_LDFLAGS' => '-ObjC',
  #   'VALID_ARCHS' => 'arm64 x86_64'
  # }

  # ――― 元数据 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.requires_arc = true
  
end
