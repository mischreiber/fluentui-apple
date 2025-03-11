# Constants
common_root = 'Sources/FluentUI_common'

core_dir = 'Core'

Pod::Spec.new do |s|
  s.name             = 'MicrosoftFluentUICommon'
  s.version          = '0.32.0'
  s.summary          = 'Fluent UI is a set of reusable UI controls and tools'
  s.homepage         = "https://www.microsoft.com/design/fluent/#/"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Microsoft" => "fluentuinativeowners@microsoft.com"}
  s.source           = { :git => "https://github.com/mischreiber/fluentui-apple.git", :tag => "commonpodspec" }
  s.swift_version    = "5.9"
  s.module_name      = 'FluentUI_common'

  s.ios.deployment_target = "16.0"
  s.osx.deployment_target = "12"


# Common
  s.subspec 'Core_common' do |core_common|
    core_common.source_files = ["#{common_root}/#{core_dir}/**/*.{swift,h}"]
  end
end
