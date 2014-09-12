class Location
  API_URL = NSBundle.mainBundle.objectForInfoDictionaryKey('host')

  def self.all(&callback)
    BW::Location.get_once do |location|
      if location.is_a?(Hash) && location[:error]
        NSLog "can't geoloc"
      else
        @latitude = location.latitude.round(2)
        @longitude = (location.longitude * (1)).round(2)
        url = "api/locations?lat=#{@latitude}&long=#{@longitude}"
        result = Cache.read Time.now.strftime('%y%m%d')+url
        if result
          NSLog 'use cache'
          callback.call(result)
        else
          AFMotion::SessionClient.shared.get(url) do |result|
            Cache.write Time.now.strftime('%y%m%d')+url, result.object
            if result.success?
              callback.call(result.object)
            else
              callback.call(false, result.error)
            end
          end
        end
      end
    end
  end
end