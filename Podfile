platform :ios, '10.0'
use_frameworks!

target 'SNUTT' do
  pod 'EGOTableViewPullRefreshAndLoadMore'
  pod 'Alamofire'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyJSON'
  pod 'B68UIFloatLabelTextField', :git => 'https://github.com/JSKeum/B68FloatingLabelTextField.git'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/JSKeum/Chameleon.git'
  pod 'ActionSheetPicker-3.0'
  pod 'Color-Picker-for-iOS', '~> 2.0'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'Carte'
  pod 'SwiftyUserDefaults', :git => 'https://github.com/Rajin9601/SwiftyUserDefaults.git'
  pod 'TTRangeSlider'
  pod 'Firebase'
  pod 'Firebase/Messaging'
  pod 'DZNEmptyDataSet', :git => 'https://github.com/Rajin9601/DZNEmptyDataSet.git', :branch => 'fix-hitTest'
  pod 'TPKeyboardAvoiding'
  pod 'MarqueeLabel/Swift'
  pod 'UITextView+Placeholder', '~> 1.2'
end

target 'SNUTT Today' do
  pod 'SwiftyJSON'
  pod 'SwiftyUserDefaults', :git => 'https://github.com/Rajin9601/SwiftyUserDefaults.git'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
      config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
