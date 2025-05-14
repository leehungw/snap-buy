target 'SnapBuy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'R.swift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'GoogleSignIn'
  pod 'GoogleSignInSwiftSupport'
  pod 'AppAuth'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
