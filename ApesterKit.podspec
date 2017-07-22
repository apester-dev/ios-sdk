Pod::Spec.new do |s|
 s.name = 'ApesterKit'
 s.version = '1.1.6'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'ApesterKit provides a light-weight framework that loads Apester Unit in a webView'
 s.homepage = 'https://github.com/Qmerce/ios-sdk.git'
 s.social_media_url = 'https://twitter.com/hasansawaed'
 s.authors = { "Hasan Sa" => "hasan@apester.com" }
 s.source = { :git => "https://github.com/Qmerce/ios-sdk.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "8.0"}
 s.requires_arc = true
 s.source_files = "ApesterKit", "Sources/*.{h,m,swift}"

end
