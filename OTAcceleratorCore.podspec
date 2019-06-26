Pod::Spec.new do |s|
  s.name             = "OTAcceleratorCore"

  s.version          = "1.1.9"
  s.summary          = "A painless way to integrate WebRTC audio/video(screen sharing) to any iOS applications via OpenTok."

  s.description      = "The OpenTok Accelerator Core is required whenever you use any of the OpenTok accelerators. The OpenTok Accelerator Core is a common layer that permits all accelerators and samples to share the same OpenTok session. The accelerator packs and sample app access the OpenTok session through the Accelerator Core Pack layer, which allows them to share a single OpenTok session.

On the Android and iOS mobile platforms, when you try to set a listener (Android) or delegate (iOS), it is not normally possible to set multiple listeners or delegates for the same event. For example, on these mobile platforms you can only set one OpenTok signal listener. The Common Accelerator Session Pack, however, allows you to set up several listeners for the same event."

  s.homepage         = "https://github.com/opentok/accelerator-core-ios"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Lucas Huang" => "lucas@tokbox.com" }
  s.source           = { :git => "https://github.com/opentok/accelerator-core-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tokbox'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'OTAcceleratorCore/**/*.{h,m}'

  # s.resource_bundles = {
  # 	'OTAcceleratorCoreBundle' => ['OTAcceleratorCoreBundle/**/*']
  # }

  s.static_framework = true
  s.public_header_files = 'OTAcceleratorCore/**/*.{h}'
  s.dependency 'OTKAnalytics', '= 2.1.0'
  s.dependency 'OpenTok', '2.16.1'
  s.dependency 'SVProgressHUD', '= 2.2.1'
end
