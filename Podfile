project 'OTAcceleratorCore.xcodeproj'

platform :ios, '12.0'

def opentok_pod 
  pod 'OpenTok', '2.24.0'
end

def shared_pods 
  opentok_pod
  pod 'OTKAnalytics', '~> 2.1.2'
end

target 'OTAcceleratorCore' do 
  shared_pods
  pod 'SVProgressHUD', '~> 2.2.5'
end

target 'OTAcceleratorCoreTests' do
  opentok_pod
end

target 'OTTextChatSample' do
  shared_pods
end

target 'OTTextChatTests' do
  opentok_pod
end

target 'OTAnnotationSample' do
  shared_pods
end

target 'OTAnnotationTests' do
  opentok_pod
  pod 'Kiwi'
end
