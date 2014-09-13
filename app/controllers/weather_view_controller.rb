class WeatherViewController < UIViewController
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  WEEKDAY_COLORS = %w(#AB6323 #32A364 #3263EF #AB63AB #A26353 #1A3362 #326323)
  MAX_TEMP = 45
  MIN_TEMP = 0
  OFFSET_TEMP = 10
  attr_accessor :data, :day, :image_views, :text_views, :animate
  stylesheet :weather_view

  def initWithDay(day=0, animate=true)
    initWithNibName nil, bundle: nil
    @day = day
    @animate = animate
    self
  end

  def show_info
    #@info_controller = InfoViewController.alloc.init
    #info_controller.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("title", style: UIBarButtonItemStyleBordered, target: nil, action: nil)
    #info_controller.navigationItem.leftBarButtonItem.title = "xyz"
    self.navigationController.pushViewController(InfoViewController.alloc.init, animated: true)
    #NSLog info_controller.navigationItem.backBarButtonItem # why nil???
  end

  def layoutDidLoad
    super


    self.title = 'Yet Another Weather App'
    right_info_image = UIBarButtonItem.alloc.initWithImage(
        'navbar_info_iphone@2x.png'.uiimage.scale_to([20, 20]),
        style: UIBarButtonItemStyleBordered,
        target: self,
        action: "show_info")

    self.navigationItem.rightBarButtonItem = right_info_image
    self.navigationItem.setHidesBackButton true
    self.view = UIScrollView.new

    handler = lambda do |rec|
      case rec.direction
        when UISwipeGestureRecognizerDirectionLeft
          if @day < 7
            self.navigationController.pushViewController(self.class.alloc.initWithDay(@day+1, false), animated: true)
          end
        when UISwipeGestureRecognizerDirectionRight
          if @day >= 1
            self.navigationController.popViewControllerAnimated animated: false
          end
        # do if swiped from left to right
      end
    end

    self.view.when_swiped(&handler).direction = UISwipeGestureRecognizerDirectionLeft
    self.view.when_swiped(&handler).direction = UISwipeGestureRecognizerDirectionRight
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
      @text_views[:forecast_title] = subview UIImageView, :forecast_title_view
      @text_views[:forecast_date_view] = subview UILabel, :forecast_date_view

      @text_views.values.each do |text_view|
        text_view.layer.masksToBounds = true
        text_view.layer.cornerRadius = 6
        text_view.fade_out
      end

    end
    @text_views[:forecast_date_view].text = (Time.now + @day.days).strftime '%a, %d.%m'

    if @animate
      @indicator = UIActivityIndicatorView.large
      @indicator.frame = [[150, 200], [20, 20]]
      view.addSubview(@indicator)
      @indicator.hidesWhenStopped = true
      @indicator.startAnimating
    end

    @data ||= []
    Location.all do |response|
      @data = response
      @indicator.stopAnimating if @animate
      if @data
        @text_views[:title].text = @data['name']
        temperature = @data['weather_forecasts'][@day]['temp']['amount'].to_i
        @text_views[:forecast_temp].text = temperature.to_s + ' °C'
        threshold = 100
        hex_val = (([MIN_TEMP, [(temperature+OFFSET_TEMP), MAX_TEMP].min].max)*255/MAX_TEMP).to_s(16)
        green = hex_val.hex < threshold ? hex_val : (255 - hex_val.hex).to_s(16)
        other = hex_val.hex < threshold ? ([100, [80, green.hex].min].max).to_s(16) : ([0, [80, green.hex].min].max).to_s(16)
        green = '0'+green if green.length <= 1 # normalize '3' => '03'
        other = '0'+other if other.length <= 1 # normalize '3' => '03'
        red = hex_val.hex < threshold ? other : 'ff'
        blue = hex_val.hex < threshold ? 'ff' : other #(255 - hex_val.hex).to_s(16)
        @text_views[:forecast_temp].backgroundColor = "##{red}#{green}#{blue}".uicolor(0.8)
        #@text_views[:forecast_title].text = @data['weather_forecasts'][@day]['title']
        NSLog @data['weather_forecasts'][@day]['img_url']
        BW::HTTP.get(@data['weather_forecasts'][@day]['img_url']) do |response|
          if response.ok?
            im = UIImage.alloc.initWithData(response.body)
            @text_views[:forecast_title].image = im #.scale_to([image_view.height, 120])
          else
            puts 'BAD RESPONSE'
          end
        end

        photos = @data['photos']
        @image_views.values.each_with_index do |image_view, i|
          BW::HTTP.get(photos[i]['photo_url']) do |response|
            if response.ok?
              im = UIImage.alloc.initWithData(response.body)
              image_view.image = im #.scale_to([image_view.height, 120])
            else
              puts 'BAD RESPONSE'
            end
          end
        end
      end
      @animate ? animate_views : show_views
      @text_views[:forecast_date_view].backgroundColor = WEEKDAY_COLORS[(Time.now + @day.days).strftime('%u').to_i-1].uicolor(0.8)
    end
  end

  def animate_views
    @image_views.values.each { |text_view| text_view.fade_in(duration: 3.0) }
    @text_views.values.each { |text_view| text_view.fade_in(duration: 3.0) }

  end

  def show_views
    @image_views.values.each { |text_view| text_view.fade_in(duration: 0.0) }
    @text_views.values.each { |text_view| text_view.fade_in(duration: 0.0) }
  end

end