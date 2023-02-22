#
# Be sure to run `pod lib lint ApesterKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ApesterKit'
    s.version          = '3.3.10'
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
    
    ios_deployment_target   = '11.0'
    s.platform              = :ios
    s.ios.deployment_target = ios_deployment_target
    
    s.frameworks = 'Foundation','UIKit', 'WebKit', 'SafariServices' , 'OSLog', 'AdSupport'
    
    s.static_framework = true
    s.swift_version = '5.0'
    
    s.default_subspecs      = 'Content'
    s.scheme                = { :code_coverage => true }
    s.subspec   'Content' do |content|
        s.source_files = 'ApesterKit/Content/Classes/**/*'
        s.dependency 'Google-Mobile-Ads-SDK', '~> 10.0'
        s.dependency 'OpenWrapSDK'          , '~>  2.7.0'
    end
    s.app_spec 'HostApp' do |app_spec|
        app_spec.scheme              = {
            :code_coverage           => true ,
            :launch_arguments        => [ ]
        }
        app_spec.source_files        = 'ApesterKit/App/Classes/**/*.{h,m,swift}'
        app_spec.resources           = 'ApesterKit/App/Assets/**/*.{xib,storyboard,*.xcassets}'
        app_spec.preserve_paths      = [
        'App/Classes/**/*.{h,m,swift}',
        'App/Assets/**/*.{xib,storyboard}'
        ]
        app_spec.info_plist          = {
            'CFBundleIdentifier'                    => 'com.apesterkit.demo',
            'UIStatusBarStyle'                      => 'UIStatusBarStyleLightContent',
            'UIApplicationSceneManifest'            => {
                'UIApplicationSupportsMultipleScenes' => false,
                'UISceneConfigurations' => {
                    'UIWindowSceneSessionRoleApplication' => [
                    {
                        'UISceneConfigurationName' => 'Default Configuration',
                        'UISceneDelegateClassName' => '$(PRODUCT_MODULE_NAME).SceneDelegate',
                        'UISceneStoryboardFile'    => 'Main'
                    }
                    ]
                }
            },
            'UILaunchStoryboardName'                => 'LaunchScreen',
            'UIMainStoryboardFile'                  => 'Main',
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
            'GADApplicationIdentifier'              => 'ca-app-pub-7862987392320388~1726030239'
        }
        
        # Internal dependencies
        app_spec.dependency 'ApesterKit/Content'
    end
    s.test_spec 'UnitTests'   do |unit_tests|
        unit_tests.test_type         = :unit
        unit_tests.platforms         = { :ios => ios_deployment_target }
        unit_tests.scheme            = {
            :code_coverage           => true ,
            :launch_arguments        => [ ]
        }
        unit_tests.source_files      = [ 'ApesterKit/Tests/Classes/*.{h,m,swift}' ]
        unit_tests.preserve_paths    = [ 'ApesterKit/Tests/Classes/*.{h,m,swift}' ]
        
        unit_tests.requires_app_host = true
        unit_tests.app_host_name     = 'ApesterKit/HostApp'
        unit_tests.dependency          'ApesterKit/HostApp'
        
        # Dependencies
        unit_tests.dependency 'Google-Mobile-Ads-SDK', '~> 10.0'
        unit_tests.dependency 'OpenWrapSDK'          , '~>  2.7.0'
    end
end
