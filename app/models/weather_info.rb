class WeatherInfo
  API_URL = NSBundle.mainBundle.objectForInfoDictionaryKey('host')

  def self.get(&callback)
    NSLog "1"
    result = nil

    def result.coordinate
      c = nil

      def c.latitude
        50.3254
      end

      def c.longitude
        120.234
      end

      c
    end

    #BW::Location.get(purpose: 'We need to use your GPS because...') do |result|
    #if result.is_a?(CLLocation)
    @latitude = result.coordinate.latitude.round(2)
    @longitude = result.coordinate.longitude.round(2)
    url = "#{API_URL}/api/locations?lat=#{@latitude}&long=#{@longitude}"
    api_result = Cache.read Time.now.strftime('%y%m%d')+url.to_s
    if api_result
      NSLog 'use cache'
      callback.call(api_result)
    else
      NSLog url
      AFMotion::JSON.get(url) do |result|
        if result.success?
          callback.call result.object
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