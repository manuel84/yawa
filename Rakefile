$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

require 'YAML'
require 'bubble-wrap'
require 'bubble-wrap/location'
require 'sugarcube-all'


APP_CONFIG = YAML.load_file('config/config.yml').freeze

Motion::Project::App.setup do |app|
  app.detect_dependencies = false
  # Use `rake config' to see complete project settings.
  app.name = 'YAWA'
  app.identifier = 'web.dudda.yawa'
  app.version = '0.1.1'
  app.short_version = '0.1.1'
  app.icons = %w(app_icon_iphone@2x.png)
  app.deployment_target = '7.0'
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]
  app.frameworks += %w(AVFoundation AudioToolbox QuartzCore CoreLocation CoreBluetooth CoreData CoreTelephony MessageUI StoreKit EventKitUI AdSupport)

  app.development do
    app.codesign_certificate = APP_CONFIG['development']['codesign_certificate']
    app.provisioning_profile = APP_CONFIG['development']['provisioning_profile']
    app.entitlements['aps-environment'] = APP_CONFIG['development']['entitlements']['aps-environment']

    app.info_plist.merge! APP_CONFIG['development']['info_plist']
  end
  #app.files_dependencies 'app/app_delegate.rb' => 'app/styles/matchday_table_view.rb'
  app.fonts = ['Arvo-Regular.ttf']
  app.pods do
    pod 'Reachability'
  end
  app.vendor_project('vendor/GoogleMobileAdsSdk', :static)
  app.libs << '/usr/lib/libz.dylib'
  app.libs << '/usr/lib/libxml2.2.dylib'
end
