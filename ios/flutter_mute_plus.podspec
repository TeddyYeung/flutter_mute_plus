#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_mute_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_mute_plus'
  s.version          = '1.1.0'
  s.summary          = 'Check or toggle the device ringer mode.'
  s.description      = <<-DESC
Check or toggle the device ringer mode. Maintained fork of flutter_mute.
                       DESC
  s.homepage         = 'https://github.com/TeddyYeung/flutter_mute_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TeddyYeung' => 'https://github.com/TeddyYeung' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_mute_plus/Sources/flutter_mute_plus/**/*.swift'
  s.resources = 'flutter_mute_plus/Sources/flutter_mute_plus/Resources/*.aiff'
  s.resource_bundles = {'flutter_mute_plus_privacy' => ['flutter_mute_plus/Sources/flutter_mute_plus/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.frameworks = 'Foundation', 'AudioToolbox'
end
