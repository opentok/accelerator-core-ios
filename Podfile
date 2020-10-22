project 'OTAcceleratorCore.xcodeproj'

platform :ios, '11.0'

def core_pods
  pod 'OpenTok', '2.18.0'
end

def dep_pods
  pod 'OTAcceleratorCore', '2.0.1'
end 

target 'OTAcceleratorCore' do 
  core_pods
  pod 'OTKAnalytics', '~> 2.1.2'
  pod 'SVProgressHUD', '~> 2.2.5'
end

target 'OTAcceleratorCoreTests' do
  core_pods
end

target 'OTTextChatSample' do
  dep_pods
end

target 'OTTextChatTests' do
  core_pods
end

target 'OTAnnotationSample' do
  dep_pods
end

target 'OTAnnotationTests' do
  dep_pods
  pod 'Kiwi'
end