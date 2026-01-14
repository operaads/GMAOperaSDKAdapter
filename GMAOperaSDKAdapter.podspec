Pod::Spec.new do |spec|
  # ―――  基本信息  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "GMAOperaSDKAdapter"
  spec.version      = "2.2.16.0"
  spec.summary      = "Opera Ads Adapter for Google(Admob) Mediation."

  spec.description  = <<-DESC
    GMAOperaSDKAdapter is a custom adapter that enables the integration of Opera Ads 
    via the Google(Admob) mediation platform. 
    It allows publishers to maximize revenue by including Opera's demand in their Google(Admob) waterfall.
  DESC

  spec.homepage     = "https://github.com/operaads/GMAOperaSDKAdapter"
  spec.license      = { :type => "Commercial", :file => "LICENSE" }
  spec.author       = { "opera" => "chenl@opera.com" }

  # ―――  平台设置  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.platform     = :ios, "13.0" 
  spec.swift_version = "5.0"

  # ―――  源码位置  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source = { 
      :git => "https://github.com/operaads/GMAOperaSDKAdapter.git", 
      :tag => "#{spec.version}" 
  }

  # ―――  文件配置  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.vendored_frameworks = "OpAdxAdapterAdmob.xcframework"
  spec.static_framework = true

  
  spec.dependency 'Google-Mobile-Ads-SDK','~>12.8'
  
  spec.dependency 'OpAdxSdk', '~> 2.2.16'    


  # ―――  工程配置  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }

end