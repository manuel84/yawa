class WeatherViewController < UIViewController
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  WEEKDAY_COLORS = %w(#AB6323 #32A364 #3263EF #AB63AB #A26353 #1A3362 #326323)
  attr_accessor :data, :day, :image_views, :text_views, :animate
  stylesheet :weather_view

  def initWithDay(day=0, animate=true)
    initWithNibName nil, bundle: nil
    @day = day
    @animate = animate
    self
  end

  def show_info
    NSLog 'show info'
    self.navigationController.pushViewController(InfoViewController.alloc.init, animated: true)
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
    self.view.when_swiped do
      if @day < 7
        self.navigationController.pushViewController(self.class.alloc.initWithDay(@day+1, false), animated: true)
      end
    end.direction = UISwipeGestureRecognizerDirectionLeft

    self.view.when_swiped do
      if @day >= 1
        self.navigationController.popViewControllerAnimated animated: true
      end
      # do if swiped from left to right
    end.direction = UISwipeGestureRecognizerDirectionRight
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
        @text_views[:forecast_temp].text = @data['weather_forecasts'][@day]['temp']['amount'].to_i.to_s + ' °C'
        @text_views[:forecast_title].text = @data['weather_forecasts'][@day]['title']

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
      @text_views[:forecast_date_view].backgroundColor = WEEKDAY_COLORS[(Time.now + @day.days).strftime('%u').to_i-1].uicolor
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