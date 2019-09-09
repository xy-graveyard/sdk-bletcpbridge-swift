#
# Be sure to run `pod lib lint sdk-objectmodel-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'sdk-bletcpbridge-swift'
  s.version          = '3.0.2'
  s.summary          = 'A short description of sdk-bletcpbridge-swift'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/XYOracleNetwork/sdk-bletcpbridge-swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'LGPL3', :file => 'LICENSE' }
  s.author           = { 'Carter Harrison' => 'carter@xyo.network' }
  s.source           = { :git => 'https://github.com/XYOracleNetwork/sdk-bletcpbridge-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'sdk-bridge-swift/**/*.{swift}'

  s.dependency 'PromisesSwift', '~> 1.2.4'

  s.dependency 'sdk-core-swift', '~> 3.0.1'
  s.dependency 'sdk-objectmodel-swift',  '~> 3.0'
  s.dependency 'XyBleSdk',  '~> 3.0.1'
  s.dependency 'sdk-xyobleinterface-swift',  '~> 3.0.3'


end
