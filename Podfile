platform :ios, '8.4'
use_frameworks!

target 'SNUTT' do
  pod 'EGOTableViewPullRefreshAndLoadMore'
  pod 'Alamofire'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyJSON'
  pod 'B68UIFloatLabelTextField', :git => 'https://github.com/Rajin9601/B68FloatingLabelTextField.git', :branch => 'Swift_3.0'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
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
  pod 'Swinject'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxDataSources', '~> 3.0'
  pod 'SnapKit', '~> 4.0.0'
  pod 'Moya/RxSwift'
end

target 'SNUTT Today' do
  pod 'SwiftyJSON'
  pod 'SwiftyUserDefaults', :git => 'https://github.com/Rajin9601/SwiftyUserDefaults.git'
end

post_install do |installer|
  swift3 = ['EGOTableViewPullRefreshAndLoadMore', 'SwiftyJSON', 'B68UIFloatLabelTextField', 'ChameleonFramwork/Swift', 'ActionSheePicker-3.0', 'Color-Picker-for-iOS', 'Carte', 'SwiftyUserDefaults', 'TTRangeSlider', 'DNZEmptyDataSet', 'TPKeyboardAvoiding', 'UITextView+Placeholder']
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if swift3.include?(target.name)
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
