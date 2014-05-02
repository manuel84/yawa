class AppDelegate

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    Teacup::Appearance.apply
    AFMotion::SessionClient.build_shared("https://yawa-api.herokuapp.com") do
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

    if ipad?
      @main_controller = WeatherViewIpadController.alloc.init
    else
      @main_controller = WeatherViewIphoneController.alloc.init
    end
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(@main_controller)
    true
  end

end

class Kernel

  def ipad?
    UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
  end

end
