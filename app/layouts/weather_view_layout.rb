class WeatherViewLayout < MotionKit::Layout
  view :scroll_view

  def layout
    @scroll_view = add(UIScrollView, :scroll_view) do
      @image_view1 = add(UIImageView, :image_view1)
      @image_view2 = add(UIImageView, :image_view2)
    end
  end

  def init_location_name_view
    view = UILabel.alloc.init :title_view
    @location_name_view = self.view.addSubview
    @location_name_view.text = @data['name']
    init_style @location_name_view
    @text_views << @location_name_view
    @location_name_view
  end

  def init_forecast_temp_view(page)
    @forecast_temp_view = self.view.subview UILabel, :forecast_temp_view
    init_style @forecast_temp_view

    set_forecast_text page
    set_forecast_temp_view_color page

    @text_views << @forecast_temp_view

    @forecast_temp_view
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

  def init_forecast_image_view(page)
    @forecast_image_view = self.view.subview UIImageView, :forecast_title_view
    init_style @forecast_image_view

    set_forecast_image page
    @text_views << @forecast_image_view
    @forecast_image_view
  end

  def set_forecast_image(page)
    BW::HTTP.get(@data['weather_forecasts'][page]['img_url']) do |response|
      if response.ok?
        image = UIImage.alloc.initWithData(response.body)
        @forecast_image_view.image = image
      else
        puts 'BAD RESPONSE'
      end
    end
  end

  def init_date_view(page)
    @date_view = self.view.subview UILabel, :forecast_date_view
    init_style @date_view
    set_date_view_text page
    @text_views << @date_view
    @date_view
  end

  def set_date_view_text(page)
    @date_view.text = (Time.now + page.days).strftime '%a, %d.%m'
    @date_view.backgroundColor = WEEKDAY_COLORS[(Time.now + page.days).strftime('%u').to_i-1].uicolor(0.8)
  end

  def init_style(view)
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 6
    view.fade_out
    @scrollView.bringSubviewToFront view
  end
end

#
# style :image_view1,
#       frame: [[0, 00], [320, 180]]
#
# style :image_view2,
#       frame: [[0, 180], [320, 180]]
#
# style :image_view3,
#       frame: [[0, 360], [320, 180]]
#
# style :image_view4,
#       frame: [[0, 540], [320, 180]]
#
# @background_color = '#000000'.uicolor(0.38)
#
# style :text_view,
#       textAlignment: UITextAlignmentCenter,
#       font: UIFont.fontWithName('Arvo', size: 30),
#       textColor: UIColor.lightGrayColor,
#       backgroundColor: @background_color
#
# style :title_view, extends: :text_view,
#       top: 100, left: 30,
#       width: 260, height: 50
#
# style :forecast_temp_view, extends: :text_view,
#       top: 200, left: 60,
#       width: 200, height: 80,
#       textColor: UIColor.darkGrayColor,
#       font: UIFont.fontWithName('Arvo', size: 80)
#
# style :forecast_title_view,#, extends: :text_view,
#       top: 200, left: 60,
#       width: 200, height: 200
#
# style :forecast_date_view, extends: :text_view,
#       top: 380, left: 60,
#       width: 200, height: 50
