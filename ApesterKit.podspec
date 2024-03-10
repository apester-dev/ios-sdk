#
# Be sure to run `pod lib lint ApesterKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ApesterKit'
    s.version          = '3.3.16'
    s.summary          = 'ApesterKit provides a light-weight framework that loads Apester Unit in a webView'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    'ApesterKit provides a light-weight framework that loads Apester Unit in a webView'
    DESC
    s.homepage         = 'https://github.com/apester-dev/ios-sdk'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = {
        'Hasan Sa'        => 'hasansa007@gmail.com'  ,
        'ArkadiYoskovitz' => 'arkadiy@gini-apps.com'
    }
    s.source           = { :git => 'https://github.com/apester-dev/ios-sdk.git', :tag => "v"+s.version.to_s }
    
    ios_deployment_target   = '13.0'
    s.platform              = :ios
    s.ios.deployment_target = ios_deployment_target
    
    s.frameworks = 'Foundation','UIKit', 'WebKit', 'SafariServices' , 'OSLog', 'AdSupport'
    
    s.static_framework = true
    s.swift_version = '5.0'
    
    s.default_subspecs      = 'Content'
    s.scheme                = { :code_coverage => true }
    
    s.subspec   'Content_Core'    do |content|
        # content.pod_target_xcconfig = {
        #   'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load'
        # }
        content.source_files =
        'Sources/ApesterKit/Content/Classes/Common/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/Services/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/Logger/**/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/Helpers/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/FastStrip/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/_Display/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/Data/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/Loader/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/Bidding/*.{h,m,swift}',
        'Sources/ApesterKit/Content/Classes/Deprecated/*.{h,m,swift}'
        content.dependency 'ApesterObjcBridging', '3.3.16'
        content.dependency 'OpenWrapSDK' , '~> 2.7.0'
        content.dependency 'DTBiOSSDK', '~> 0.0.1'
    end
    s.subspec   'ContentAdmob'    do |content|
        content.source_files = 'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/AdMob/*.{h,m,swift}'
        content.dependency 'ApesterKit/Content_Core'
        content.dependency 'Google-Mobile-Ads-SDK', '~> 11.0'
    end
    s.subspec   'ContentPubmatic' do |content|
        content.source_files = 'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/PubMatic/*.{h,m,swift}'
        content.dependency 'ApesterKit/Content_Core'
        content.dependency 'OpenWrapSDK' , '~> 2.7.0'
    end
    s.subspec   'ContentAmazon'   do |content|
        content.source_files = 'Sources/ApesterKit/Content/Classes/EmbededUnit/AdProvider/Amazon/*.{h,m,swift}'
        content.dependency 'ApesterKit/Content_Core'
        content.dependency 'ApesterKit/ContentPubmatic'
        content.dependency 'OpenWrapHandlerDFP'        , '~> 3.1.0'
        content.dependency 'AmazonPublisherServicesSDK', '~> 4.6.0'
    end
    s.subspec   'Content'         do |content|
        content.dependency 'ApesterKit/Content_Core'
        content.dependency 'ApesterKit/ContentAdmob'
        content.dependency 'ApesterKit/ContentPubmatic'
        content.dependency 'ApesterKit/ContentAmazon'
    end

    s.app_spec  'zHostApp'        do |app_spec|
        app_spec.scheme              = {
            :code_coverage           => true ,
            :launch_arguments        => [ ]
        }
        app_spec.source_files        = 'Sources/ApesterKit/App/Classes/**/*.{h,m,swift}'
        app_spec.resources           = 'Sources/ApesterKit/App/Assets/**/*.{xib,storyboard,*.xcassets}'
        app_spec.preserve_paths      = [
            'App/**/*.{h,m,swift}',
            'App/**/*.{xib,storyboard}'
        ]
        app_spec.info_plist          = {
          'CFBundleIdentifier'                    => 'com.apesterkit.hostapp',
          'UIStatusBarStyle'                      => 'UIStatusBarStyleLightContent',
          'UIApplicationSceneManifest'            => {
            'UIApplicationSupportsMultipleScenes' => false,
            'UISceneConfigurations' => {
              'UIWindowSceneSessionRoleApplication' => [
              {
                'UISceneConfigurationName' => 'Default Configuration',
                'UISceneDelegateClassName' => '$(PRODUCT_MODULE_NAME).SceneDelegate'
              }
              ]
            }
          },
          'UILaunchStoryboardName'                => 'LaunchScreen',
          'UISupportedInterfaceOrientations'      => [
          'UIInterfaceOrientationPortrait',
          'UIInterfaceOrientationLandscapeLeft',
          'UIInterfaceOrientationLandscapeRight',
          ],
          'UISupportedInterfaceOrientations~ipad' => [
          'UIInterfaceOrientationPortrait',
          'UIInterfaceOrientationLandscapeLeft',
          'UIInterfaceOrientationLandscapeRight',
          ],
          'NSAppTransportSecurity'                => {
            'NSAllowsArbitraryLoads' => true
          },
          'GADApplicationIdentifier'              => 'ca-app-pub-7862987392320388~1726030239',
          'SKAdNetworkItems'                      => [
          { 'SKAdNetworkIdentifier' => 'cstr6suwn9.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '4fzdc2evr5.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '2fnua5tdw4.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'ydx93a7ass.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '5a6flpkh64.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'p78axxw29g.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'v72qych5uu.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'c6k4g5qg8m.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 's39g8k73mm.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '3qy4746246.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '3sh42y64q3.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'f38h382jlk.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'hs6bdukanm.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'prcb7njmu6.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'wzmmz9fp6w.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'yclnxrl5pm.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '4468km3ulz.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 't38b2kh725.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '7ug5zh24hu.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '9rd848q2bz.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'n6fk4nfna4.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'kbd757ywx3.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '9t245vhmpl.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '2u9pt9hc89.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '8s468mfl3y.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'av6w8kgt66.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'klf5c3l5u5.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'ppxm28t8ap.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '424m5254lk.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'uw77j35x4d.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'e5fvkxwrpn.skadnetwork' },
          { 'SKAdNetworkIdentifier' => 'zq492l623r.skadnetwork' },
          { 'SKAdNetworkIdentifier' => '3qcr597p9d.skadnetwork' },
          ]
        }
        app_spec.pod_target_xcconfig = {
          'SWIFT_OBJC_BRIDGING_HEADER' => '$(PODS_TARGET_SRCROOT)/Sources/ApesterKit/App/Classes/ApesterKit-HostApp-Bridging-Header.h'
        }
        
        # Internal dependencies
        app_spec.dependency 'ApesterKit/Content'

        # External dependencies
        app_spec.dependency 'XCGLogger'      , '~> 7.0.1'
        app_spec.dependency 'EzImageLoader', '~> 3.5.1'
    end
    s.test_spec 'zUnitTests'      do |unit_tests|
        unit_tests.test_type         = :unit
        unit_tests.platforms         = { :ios => ios_deployment_target }
        unit_tests.scheme            = {
            :code_coverage           => true ,
            :launch_arguments        => [ ]
        }
        unit_tests.source_files      = [ 'Sources/ApesterKit/UnitTests/Classes/*.{h,m,swift}' ]
        unit_tests.preserve_paths    = [ 'Sources/ApesterKit/UnitTests/Classes/*.{h,m,swift}' ]

        unit_tests.requires_app_host = true
        unit_tests.app_host_name     = 'ApesterKit/zHostApp'
        unit_tests.dependency          'ApesterKit/zHostApp'

        # Dependencies
        unit_tests.dependency 'Google-Mobile-Ads-SDK', '~> 11.0'
        unit_tests.dependency 'OpenWrapSDK'          , '~>  2.7.0'
    end
    s.test_spec 'zUITests'        do |ui_tests|

        ui_tests.test_type         = :ui
        ui_tests.platforms         = { :ios => ios_deployment_target }
        ui_tests.scheme            = {
            :code_coverage           => true ,
            :launch_arguments        => [ ]
        }
        ui_tests.source_files      = [ 'Sources/ApesterKit/UITests/Classes/*.{h,m,swift}' ]
        ui_tests.preserve_paths    = [ 'Sources/ApesterKit/UITests/Classes/*.{h,m,swift}' ]

        ui_tests.requires_app_host = true
        ui_tests.app_host_name     = 'ApesterKit/zHostApp'
        ui_tests.dependency          'ApesterKit/zHostApp'
    end
end
