#
# Be sure to run `pod lib lint CAlert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
s.name             = 'ZWAlertController'
s.version          = '0.2.3'
s.summary          = 'This a short description of ZWAlertController.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
s.description      = <<-DESC
TODO: It is easy to use, support for custom pop tips.
DESC
s.homepage         = 'https://github.com/Initial-C/ZWAlertController/blob/master/README.md'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Initial-C-William Chang' => 'iwilliamchang@outlook.com' }
s.source           = { :git => 'https://github.com/Initial-C/ZWAlertController.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
s.ios.deployment_target = '8.0'
s.source_files = 'ZWAlertController/Classes/**/*'
s.requires_arc = true

# s.resources = 'ZWAlertController/Assets/*.{png,xib,nib,bundle,mov}'
s.resource_bundles = {
    'ZWAlertController' => ['ZWAlertController/Assets/*.{png,xib,nib,bundle,mov}']
}
s.public_header_files = 'ZWAlertController/Classes/*.h'
s.frameworks = 'UIKit', 'QuartzCore'
# s.dependency 'AFNetworking', '~> 2.3'
end
