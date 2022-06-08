Pod::Spec.new do |s|
 s.name = 'ApesterKit'
 s.version = '3.3.4'
 s.swift_version = '5.0'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'ApesterKit provides a light-weight framework that loads Apester Unit in a webView'
 s.homepage = 'https://github.com/Qmerce/ios-sdk.git'
 s.authors = { "Hasan Sa" => "hasansa007@gmail.com" }
 s.source = { :git => "https://github.com/apester-dev/ios-sdk.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "11.0" }
 s.requires_arc = true
 s.source_files = "ApesterKit", "Sources/*.{h,m,swift}", "Sources/*/*.{h,m,swift}", "Sources/*/*/*.{h,m,swift}", "Sources/*/*/*/*.{h,m,swift}"
 s.static_framework = true
 s.dependency 'Google-Mobile-Ads-SDK', '~> 8.7'
 s.dependency 'OpenWrapSDK', '~> 2.3.1'
 s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/Sodium/libsodium',
   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
 }
 s.user_target_xcconfig = {
   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
 }
# s.resource_bundles = {
#   'ApesterKit' => ['Sources/ApesterKit.bundle/*']
#  }

end
