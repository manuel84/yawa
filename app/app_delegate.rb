class AppDelegate

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    Teacup::Appearance.apply
    api_host = NSBundle.mainBundle.objectForInfoDictionaryKey('host')
    AFMotion::SessionClient.build_shared(api_host) do
      session_configuration :default
      header "Accept", "application/json"

      request_serializer :json
    end

    url_cache = NSURLCache.alloc.initWithMemoryCapacity(4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
    NSURLCache.setSharedURLCache(url_cache)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    application.setStatusBarStyle(UIStatusBarStyleDefault)
    #UIStatusBarStyleBlackTranslucent)

    start_ui_controller


    true
  end


  def start_ui_controller
    if internet_connected?
      if ipad?
        @main_controller = WeatherViewIpadController.alloc.initWithAnimation
      else
        @main_controller = WeatherViewIphoneController.alloc.initWithAnimation
      end
      @window.rootViewController = UINavigationController.alloc.initWithRootViewController(@main_controller)
    else
      BW::UIAlertView.new(
          {
              title: 'Keine Internetverbindung',
              message: 'YAWA setzt eine Internetverbindung voraus. Stelle bitte sicher, dass eine Verbidnung zum Internet besteht.',
              buttons: ['YAWA schließen', 'wiederholen'],
              cancel_button_index: 0,
          }) do |alert|
        if alert.clicked_button.cancel?
          exit(0)
        else
          start_ui_controller
        end
      end.show
    end
  end

end

class Kernel

  def internet_connected?
    Reachability.reachabilityForInternetConnection.isReachable
  end

  def ipad?
    UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
  end

end
