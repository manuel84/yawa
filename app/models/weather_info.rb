class WeatherInfo
  API_URL = NSBundle.mainBundle.objectForInfoDictionaryKey('host')
  attr_accessor :callback

  def self.get(&callback)
    @location_manager ||= CLLocationManager.alloc.init.tap do |lm|
      lm.purpose = "please activate GPS"
      lm.desiredAccuracy = KCLLocationAccuracyThreeKilometers
      lm.delegate = self
      lm.startUpdatingLocation
    end

    @callback = callback
  end

  def locationManager(location_manager, didUpdateToLocation: to_location, fromLocation: from_location)
    NSLog "update loc"
    coordinate = @location_manager.location.coordinate
    @latitude = coordinate.latitude.round(2)
    @longitude = coordinate.longitude.round(2)
    url = "#{API_URL}/api/locations?lat=#{@latitude}&long=#{@longitude}"
    api_result = Cache.read Time.now.strftime('%y%m%d')+url.to_s
    if api_result
      NSLog 'use cache'
      @callback.call(api_result)
    else
      NSLog url
      AFMotion::JSON.get(url) do |result|
        if result.success?
          @callback.call result.object
        elsif result.failure?
        end
      end
    end
    #else
    #  NSLog "ERROR: #{result[:error]}"
    #end
    #end
  end
end