class WeatherViewController < UIViewController
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag)
  WEEKDAY_COLORS = %w(#AB6323 #32A364 #3263EF #AB63AB #A26353 #1A3362 #326323)
  MAX_TEMP = 45
  MIN_TEMP = 0
  OFFSET_TEMP = 10
  attr_accessor :data, :day, :image_views, :text_views, :animate, :number_of_pages
  stylesheet :weather_view

  def initWithDay(day=0, animate=true)
    initWithNibName nil, bundle: nil
    @day = day
    @animate = animate
    self
  end

  def viewDidLoad
    super
    NSLog "didLoad"

    init_navigation_bar

    @number_of_pages = 7

    init_scroll_view

    @text_views ||= []

    @data ||= []
    Location.all do |response|
      @data = response
      if @data
        landscape_images = @data['photos'].select { |image| image['width'].to_i > image['height'].to_i }
        portrait_images = @data['photos'].select { |image| image['width'].to_i <= image['height'].to_i }
        #background image
        @number_of_pages.times do |i|
          if i % 2 == 0 #even
            BW::HTTP.get(landscape_images[i % landscape_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i, 0)
              else
                puts 'BAD RESPONSE'
              end
              @animate ? animate_views : show_views
            end
            BW::HTTP.get(landscape_images[i+1 % landscape_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i, 1)
              else
                puts 'BAD RESPONSE'
              end
              @animate ? animate_views : show_views
            end
          else # odd
            BW::HTTP.get(portrait_images[i % portrait_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i)
              else
                puts 'BAD RESPONSE'
              end
              @animate ? animate_views : show_views
            end
          end
        end


      end


    end

    @pageControl = UIPageControl.alloc.init
    @pageControl.frame = CGRectMake(0, 0, App.window.frame.size.width, 0)
    @pageControl.numberOfPages = @number_of_pages
    @pageControl.currentPage = 0

    self.view.addSubview @pageControl
    self.view.addGestureRecognizer(UITapGestureRecognizer.alloc.initWithTarget(self, action: 'toggle_views'))
    @pageControl.addTarget(self, action: "clickPageControl:", forControlEvents: UIControlEventAllEvents)
  end

  def toggle_views
    @text_views.first.alpha <= 0.0 ? animate_views(1.0) : hide_views(1.0)
  end

  def scrollViewDidScroll(scrollView)
    @pageControl.currentPage = @scrollView.contentOffset.x / @scrollView.frame.size.width
  end


  def clickPageControl(sender)
    frame = @scrollView.frame
    frame.origin.x = frame.size.width * @pageControl.currentPage

    @scrollView.scrollRectToVisible(frame, animated: true)
  end

  def init_navigation_bar
    self.title = 'Yet Another Weather App'
    right_info_image = UIBarButtonItem.alloc.initWithImage(
        'navbar_info_iphone@2x.png'.uiimage.scale_to([20, 20]),
        style: UIBarButtonItemStyleBordered,
        target: self,
        action: "show_info")

    self.navigationItem.rightBarButtonItem = right_info_image
    self.navigationItem.setHidesBackButton true
  end

  def init_scroll_view
    @scrollView = UIScrollView.alloc.init
    @scrollView.frame = CGRectMake(0, 0, App.window.size.width, App.window.size.height)

    @scrollView.pagingEnabled = true
    @scrollView.backgroundColor = UIColor.blackColor

    @scrollView.contentSize = CGSizeMake(@scrollView.frame.size.width * @number_of_pages, App.window.size.height)

    @scrollView.showsHorizontalScrollIndicator = false
    @scrollView.showsVerticalScrollIndicator = false

    @scrollView.delegate = self
    self.view.addSubview @scrollView
    @scrollView
  end

  def add_image(data, page, top_offset_nr=nil, height=App.window.size.height/2)
    width = @scrollView.frame.size.width
    single = false
    if top_offset_nr.nil? # do fullscreen
      top_offset_nr = 0
      height = App.window.size.height
      single = true
    end
    image = UIImage.alloc.initWithData(data)
    view = UIView.alloc.initWithFrame(CGRectMake(width * page, top_offset_nr*height, width, height))
    image.scale_to_fill([width, height], position: :center)
    view.backgroundColor = UIColor.alloc.initWithPatternImage(image)
    @scrollView.addSubview(view)

    if single || top_offset_nr == 0
      title_view = view.subview UILabel, :title_view
      title_view.text = @data['name']
      init_style title_view
      @text_views << title_view

      @text_views << forecast_temp_view(view)
      if single
        @text_views << forecast_title_view(view, page)
        @text_views << forecast_date_view(view, page)
      end
    elsif !single && top_offset_nr == 1
      @text_views << forecast_title_view(view, page, true)
      @text_views << forecast_date_view(view, page, true)
    end
    view
  end

  def forecast_temp_view(view)
    forecast_temp_view = view.subview UILabel, :forecast_temp_view
    init_style forecast_temp_view

    temperature = @data['weather_forecasts'][@day]['temp']['amount'].to_i
    forecast_temp_view.text = temperature.to_s + ' °C'

    threshold = 100
    hex_val = (([MIN_TEMP, [(temperature+OFFSET_TEMP), MAX_TEMP].min].max)*255/MAX_TEMP).to_s(16)
    green = hex_val.hex < threshold ? hex_val : (255 - hex_val.hex).to_s(16)
    other = hex_val.hex < threshold ? ([100, [80, green.hex].min].max).to_s(16) : ([0, [80, green.hex].min].max).to_s(16)
    green = '0'+green if green.length <= 1 # normalize '3' => '03'
    other = '0'+other if other.length <= 1 # normalize '3' => '03'
    red = hex_val.hex < threshold ? other : 'ff'
    blue = hex_val.hex < threshold ? 'ff' : other #(255 - hex_val.hex).to_s(16)
    forecast_temp_view.backgroundColor = "##{red}#{green}#{blue}".uicolor(0.8)
    forecast_temp_view
  end

  def forecast_title_view(view, page, top=false)
    forecast_title_view = view.subview UIImageView, :forecast_title_view
    init_style forecast_title_view

    BW::HTTP.get(@data['weather_forecasts'][page]['img_url']) do |response|
      if response.ok?
        image = UIImage.alloc.initWithData(response.body)
        forecast_title_view.image = image
      else
        puts 'BAD RESPONSE'
      end
    end
    if top
      forecast_title_view.position = [forecast_title_view.position[0], 80]
      #NSLog forecast_title_view.position
    end
    forecast_title_view
  end

  def forecast_date_view(view, page, top=false)
    forecast_date_view = view.subview UILabel, :forecast_date_view
    init_style forecast_date_view
    forecast_date_view.text = (Time.now + page.days).strftime '%a, %d.%m'
    forecast_date_view.backgroundColor = WEEKDAY_COLORS[(Time.now + page.days).strftime('%u').to_i-1].uicolor(0.8)
    if top
      forecast_date_view.position = [forecast_date_view.position[0], 180]
    end
    forecast_date_view
  end

  def init_style(view)
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 6
    view.fade_out
  end

  def animate_views(sec=3.0)
    #@image_views.values.each { |text_view| text_view.fade_in(duration: 3.0) }
    @text_views.each { |text_view| text_view.fade_in(duration: sec) }

  end

  def show_views
    #@image_views.values.each { |text_view| text_view.fade_in(duration: 0.0) }
    @text_views.each { |text_view| text_view.fade_in(duration: 0.0) }
  end

  def show_info
    #@info_controller = InfoViewController.alloc.init
    #info_controller.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("title", style: UIBarButtonItemStyleBordered, target: nil, action: nil)
    #info_controller.navigationItem.leftBarButtonItem.title = "xyz"
    self.navigationController.pushViewController(InfoViewController.alloc.init, animated: true)
    #NSLog info_controller.navigationItem.backBarButtonItem # why nil???
  end

  def hide_views(sec=3.0)
    @text_views.each { |text_view| text_view.fade_out(duration: sec) }
  end

end