#
# Be sure to run `pod lib lint ApesterKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'ApesterObjcBridging'
    s.version          = '3.3.16'
    s.summary          = 'ApesterKit Objective-C utilities'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    'ApesterKit Objective-C utilities'
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
    
    s.static_framework = true
    
    s.default_subspecs      = 'Content'
    s.subspec 'Content' do |content|
        content.source_files        = 'Sources/ApesterObjcBridging/**/*.{h,m}'
        # content.pod_target_xcconfig = {
        #   'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load'
        # }
        # content.project_header_files = 'Sources/ApesterObjcBridging/**/*.{h,m}'
    end
end
