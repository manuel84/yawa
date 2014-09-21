module WeatherViewLayout
  # layout tags
  LOADING_INDICATOR = 1
  LOCATION_NAME = 2
  FORECAST_TEMP = 3
  FORECAST_IMAGE = 4
  FORECAST_DATE = 5
  SCROLL_VIEW = 6
  PAGE_CONTROL = 7

  # imprtant constants
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  WEEKDAY_COLORS = %w(#AB6323 #32A364 #3263EF #AB63AB #A26353 #1A3362 #326323)
  MAX_TEMP = 45
  MIN_TEMP = 0
  OFFSET_TEMP = 10

  def init_loading_indicator
    @indicator = view.viewWithTag LOADING_INDICATOR
    @indicator.hidesWhenStopped = true
    @indicator.startAnimating
  end

  def init_location_name_view
    @location_name_view = view.viewWithTag LOCATION_NAME
    init_style @location_name_view
    @text_views << @location_name_view
    @location_name_view
  end

  def set_location_name
    @location_name_view.text = @data['name']
  end

  def init_style(view)
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 6
    view.fade_out
  end

  def init_scroll_view
    @scrollView = view.viewWithTag SCROLL_VIEW
    @scrollView.frame = CGRectMake(0, 0, App.window.frame.size.width, App.window.frame.size.height)
    @scrollView.contentSize = CGSizeMake(@scrollView.frame.size.width * @number_of_pages, App.window.frame.size.height-68)
    @scrollView.delegate = self

    @scrollView
  end

  def init_page_control
    @pageControl = @scrollView.viewWithTag PAGE_CONTROL
    @pageControl.frame = CGRectMake(0, @scrollView.frame.size.height - 130, App.window.frame.size.width, 80)
    @pageControl.numberOfPages = @number_of_pages
    @pageControl.currentPage = 0
    self.view.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action: 'toggle_views'))
    @pageControl.addTarget(self, action: 'clickPageControl:', forControlEvents: UIControlEventAllEvents)
    @page_control
  end

  def set_forecast_text(page)
    temperature = @data['weather_forecasts'][page]['temp']['amount'].to_i
    @forecast_temp_view.text = temperature.to_s + ' °C'
  end

  def set_forecast_temp_view_color(page)
    temperature = @data['weather_forecasts'][page]['temp']['amount'].to_i
    threshold = 100
    hex_val = (([MIN_TEMP, [(temperature+OFFSET_TEMP), MAX_TEMP].min].max)*255/MAX_TEMP).to_s(16)
    green = hex_val.hex < threshold ? hex_val : (255 - hex_val.hex).to_s(16)
    other = hex_val.hex < threshold ? ([100, [80, green.hex].min].max).to_s(16) : ([0, [80, green.hex].min].max).to_s(16)
    green = '0'+green if green.length <= 1 # normalize '3' => '03'
    other = '0'+other if other.length <= 1 # normalize '3' => '03'
    red = hex_val.hex < threshold ? other : 'ff'
    blue = hex_val.hex < threshold ? 'ff' : other #(255 - hex_val.hex).to_s(16)
    @forecast_temp_view.backgroundColor = "##{red}#{green}#{blue}".uicolor(0.8)
  end

  def init_forecast_temp_view
    @forecast_temp_view = view.viewWithTag FORECAST_TEMP
    init_style @forecast_temp_view

    @text_views << @forecast_temp_view

    @forecast_temp_view
  end

  def init_forecast_image_view
    @forecast_image_view = view.viewWithTag FORECAST_IMAGE
    init_style @forecast_image_view
    @text_views << @forecast_image_view
    @forecast_image_view
  end

  def set_forecast_image(page)
    #placeholder = UIImage.imageNamed "placeholder-avatar"
    #image_view.url = {url: "http://i.imgur.com/r4uwx.jpg", placeholder: placeholder}
    @forecast_image_view.url = @data['weather_forecasts'][page]['img_url']
  end

  def init_date_view
    @date_view = view.viewWithTag FORECAST_DATE
    init_style @date_view
    @text_views << @date_view
    @date_view
  end

  def set_date_view_text(page)
    @date_view.text = (Time.now + page.days).strftime '%a, %d.%m'
    @date_view.backgroundColor = WEEKDAY_COLORS[(Time.now + page.days).strftime('%u').to_i-1].uicolor(0.8)
  end

end
#
# #
# # style :image_view1,
# #       frame: [[0, 00], [320, 180]]
# #
# # style :image_view2,
# #       frame: [[0, 180], [320, 180]]
# #
# # style :image_view3,
# #       frame: [[0, 360], [320, 180]]
# #
# # style :image_view4,
# #       frame: [[0, 540], [320, 180]]
# #
# # @background_color = '#000000'.uicolor(0.38)
# #
# # style :text_view,
# #       textAlignment: UITextAlignmentCenter,
# #       font: UIFont.fontWithName('Arvo', size: 30),
# #       textColor: UIColor.lightGrayColor,
# #       backgroundColor: @background_color
# #
# # style :title_view, extends: :text_view,
# #       top: 100, left: 30,
# #       width: 260, height: 50
# #
# # style :forecast_temp_view, extends: :text_view,
# #       top: 200, left: 60,
# #       width: 200, height: 80,
# #       textColor: UIColor.darkGrayColor,
# #       font: UIFont.fontWithName('Arvo', size: 80)
# #
# # style :forecast_title_view,#, extends: :text_view,
# #       top: 200, left: 60,
# #       width: 200, height: 200
# #
# # style :forecast_date_view, extends: :text_view,
# #       top: 380, left: 60,
# #       width: 200, height: 50
