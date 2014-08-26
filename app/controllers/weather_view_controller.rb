class WeatherViewController < UIViewController
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  attr_accessor :data
  stylesheet :weather_view

  def show_info
    NSLog "show info"
    self.navigationController.pushViewController(InfoViewController.alloc.init, animated: true)
  end

  def layoutDidLoad
    super
    self.title = 'Yet Another Weather App'
    right_info_image = UIBarButtonItem.alloc.initWithImage(
        'navbar_info_iphone@2x.png'.uiimage.scale_to([21, 21]),
        style: UIBarButtonItemStyleBordered,
        target: self,
        action: "show_info")

    self.navigationItem.rightBarButtonItem = right_info_image
    self.view = UIScrollView.new
    @image_views = {}
    @text_views = {}
    layout(self.view, :root) do
      @image_views[0] = subview UIImageView, :image_view1
      @image_views[1] = subview UIImageView, :image_view2
      @image_views[2] = subview UIImageView, :image_view3
      @image_views[3] = subview UIImageView, :image_view4
      @image_views.values.each { |text_view| text_view.fade_out }

      @text_views[:title] = subview UILabel, :title_view
      @text_views[:forecast_temp] = subview UILabel, :forecast_temp_view
      @text_views[:forecast_title] = subview UILabel, :forecast_title_view

      @text_views.values.each do |text_view|
        text_view.layer.masksToBounds= true
        text_view.layer.cornerRadius = 6
        text_view.fade_out
      end

    end


    @indicator = UIActivityIndicatorView.large
    @indicator.frame = [[160, 200], [20, 20]]
    view.addSubview(@indicator)
    @indicator.hidesWhenStopped = true
    @indicator.startAnimating

    @data ||= []
    Location.all do |response|
      @data = response
      @indicator.stopAnimating
      if @data
        @text_views[:title].text = @data.object['name']
        @text_views[:forecast_temp].text = @data.object['weather_forecasts'][0]['temp']['amount'].to_i.to_s + ' °C'
        @text_views[:forecast_title].text = @data.object['weather_forecasts'][0]['title']

        photos = @data.object['photos']
        @image_views.values.each_with_index do |image_view, i|
          BW::HTTP.get(photos[i]['photo_url']) do |response|
            if response.ok?
              im = UIImage.alloc.initWithData(response.body)
              image_view.image = im #.scale_to([image_view.height, 120])
            else
              puts "BAD RESPONSE"
            end
          end
        end
        @image_views.values.each { |text_view| text_view.fade_in(duration: 3.0) }
        @text_views.values.each { |text_view| text_view.fade_in(duration: 3.0) }
      end
    end
  end

end