platform :ios, '8.4'
use_frameworks!

target 'SNUTT' do
  pod 'EGOTableViewPullRefreshAndLoadMore'
  pod 'Alamofire', '~> 3.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyJSON', '~> 2.3'
  pod 'B68UIFloatLabelTextField', :git => 'https://github.com/Rajin9601/B68FloatingLabelTextField.git', :branch => 'Swift_2.0'
  pod 'ChameleonFramework/Swift'
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
  pod 'DZNEmptyDataSet'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
