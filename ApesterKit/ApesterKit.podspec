Pod::Spec.new do |s|

  s.name         = "ApesterKit"
  s.version      = "1.0.4"
  s.summary      = "ApesterKit provides a light-weight framework that loads Apester Unit in a webView"

  s.description  = "SDK enables video autoplay in the app
                    SDK passes IFA and do not track and passes it on as a macro
                    SDK passes bundle id (an app uniqe identifier) and pases it on as a marco"

  s.homepage     = "http://apester.com/about"

  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

  s.author       = { "Hasan Sa" => "hasansa007@gmail.com" }

  s.platform     = :ios, "10.0"

  s.source       = { git: "https://github.com/Qmerce/ios-sdk.git", tag: "v#{s.version}" }

  s.source_files = "ApesterKit", "ApesterKit/**/*.{h,m,swift}"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

end
