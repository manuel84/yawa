class WeatherViewController < UIViewController
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  attr_accessor :data
  stylesheet :weather_view

  layout :root do
    @image_view1 = subview UIImageView, :image_view1
    @image_view2 = subview UIImageView, :image_view2
    @title_view = subview UILabel, :title_view
    @forecast_temp_view = subview UILabel, :forecast_temp_view
    @forecast_title_view = subview UILabel, :forecast_title_view
    @forecast_temp_view.layer.cornerRadius = 60.0
    @forecast_title_view.layer.cornerRadius = 60.0

    mask_path = UIBezierPath.bezierPathWithRoundedRect(@title_view.bounds,
                                                       byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomRight,
                                                       cornerRadii: CGSizeMake(40.0, 100.0))
    mask_layer = CAShapeLayer.layer
    mask_layer.frame = @title_view.bounds
    mask_layer.path = mask_path.CGPath
    #@title_view.layer.mask = mask_layer

  end

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

    @indicator = UIActivityIndicatorView.large
    @indicator.center = view.center
    view.addSubview(@indicator)
    @indicator.hidesWhenStopped = true
    @indicator.startAnimating

    @data ||= []
    Location.all do |response|
      @data = response
      @indicator.stopAnimating
      if @data
        @title_view.text = @data.object['name']
        @forecast_temp_view.text = @data.object['weather_forecasts'][0]['temp']['amount'].to_i.to_s + "° C"
        @forecast_title_view.text = @data.object['weather_forecasts'][0]['title']

        photos = @data.object['photos']
        [@image_view1, @image_view2].each_with_index do |image_view, i|
          BW::HTTP.get(photos[i]['photo_url']) do |response|
            if response.ok?
              image_view.image = UIImage.alloc.initWithData(response.body)
            else
              puts "BAD RESPONSE"
            end
          end
        end
      end
    end
  end

end