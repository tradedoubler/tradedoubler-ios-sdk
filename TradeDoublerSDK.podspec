Pod::Spec.new do |s|

    s.name         = "TradeDoublerSDK"
    s.version      = "2.2.0"
    s.summary      = "TradeDoubler SDK for iOS."
  
    s.description  = <<-DESC
                     TradeDoubler SDK for iOS. 
                     DESC
  
    s.homepage     = "https://github.com/tradedoubler/tradedoubler-ios-sdk"
  
    # s.license      = { :type => "MIT", :file => "LICENSE" }
  
    s.authors      = { "TradeDoubler" => "marketing@tradedoubler.com" }
  
    s.swift_versions = ['5.0']
  
    s.ios.deployment_target = "13.0"
    s.osx.deployment_target = "10.15"
  
    s.source        = { :git => "https://github.com/tradedoubler/tradedoubler-ios-sdk.git", :tag => s.version }
    s.source_files  = ["TradeDoublerDemo/TradeDoublerSDK/*.swift"]
  
    s.requires_arc = true
  end