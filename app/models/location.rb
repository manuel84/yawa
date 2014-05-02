class Location
  API_URL = NSBundle.mainBundle.objectForInfoDictionaryKey('host')

  def self.all(&callback)
    BW::Location.get_once do |location|
      if location.is_a?(Hash) && location[:error]
        NSLog "can't geoloc"
      else
        @latitude = location.latitude
        @longitude = location.longitude * (1)
        NSLog "api/locations?lat=#{@latitude}&long=#{@longitude}"
        AFMotion::SessionClient.shared.get("api/locations?lat=#{@latitude}&long=#{@longitude}") do |result|
          if result.success?
            callback.call(result)
          else
            callback.call(false, result.error)
          end
        end
      end
    end
  end
end