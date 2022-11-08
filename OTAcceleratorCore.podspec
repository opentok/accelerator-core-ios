Pod::Spec.new do |s|
  s.name             = "OTAcceleratorCore"

  s.version          = "4.0.0"
  s.summary          = "A painless way to integrate WebRTC audio/video(camera + screen sharing)/text to any iOS applications via OpenTok."

  s.description      = "The OpenTok Accelerator Core is a collection of reusable components built on top of the OpenTok iOS SDK using best practices. The core components help you to use OpenTok to add one to one or multiparty audio and video calls to your application with screen sharing. The text chat components help add text messaging to your application, and the annotation components will help with sharing screen annotations.
  For examples of the components in action clone the repository and try out the sample apps."

  s.homepage         = "https://github.com/opentok/accelerator-core-ios"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Vonage" => "devrel@vonage.com" }
  s.source           = { :git => "https://github.com/opentok/accelerator-core-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vonagedev'

  s.platform     = :ios, '11.0'
  
  s.requires_arc = true
  s.static_framework = true

  s.source_files = 'OTAcceleratorCore/**/*.{h,m}'
  s.public_header_files = 'OTAcceleratorCore/**/*.{h}'

  s.resource_bundles = {
    'OTAcceleratorCoreBundle' => [
      'OTAcceleratorCoreBundle/**/*.xib', 'OTAcceleratorCoreBundle/Assets.xcassets',
      'OTTextChatSampleBundle/**/*.xib', 'OTTextChatSampleBundle/Assets.xcassets',
      'OTAnnotationSampleBundle/**/*.xib', 'OTAnnotationSampleBundle/Assets.xcassets']
  }

   # See https://github.com/CocoaPods/CocoaPods/issues/10065
   s.pod_target_xcconfig = {
     'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
   }
   s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.dependency 'OTKAnalytics', '2.1.2'
  s.dependency 'OpenTok', '2.18.1'
  s.dependency 'SVProgressHUD', '2.2.5'
end
