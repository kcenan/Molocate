
# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!
xcodeproj 'Molocate.xcodeproj'
target 'Molocate' do

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'AWSS3', '2.4.9'
pod 'SDWebImage'

end

target 'MolocateTests' do

end

target 'MolocateUITests' do

end
post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end

