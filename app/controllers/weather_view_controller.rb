class WeatherViewController < UIViewController
  attr_accessor :data, :day, :image_views, :text_views, :animate, :number_of_pages, :location_name_view, :forecast_image_view, :forecast_temp_view, :date_view, :loading
  #stylesheet :weather_view
  include WeatherViewLayout


  def initWithAnimation(animate=true)
    initWithNibName nil, bundle: nil
    @animate = animate
    self
  end


  def loadView
    views = NSBundle.mainBundle.loadNibNamed "WeatherInfoView", owner: self, options: nil
    self.view = views[0]
  end

  def viewDidLoad
    super

    @loading = true
    @number_of_pages = 7
    @text_views ||= []
    @image_views ||= []
    @data ||= []

    init_navigation_bar

    init_scroll_view


    init_admob


    init_loading_indicator if @animate

    init_location_name_view
    init_forecast_temp_view
    init_forecast_image_view
    init_date_view


    WeatherInfo.get do |response|
      @data = response
      @indicator.stopAnimating if @animate
      @loading = false
      init_page_control
      if @data
        landscape_images = @data['photos'].select { |image| image['width'].to_i > image['height'].to_i }
        portrait_images = @data['photos'].select { |image| image['width'].to_i <= image['height'].to_i }


        page = 0
        set_location_name
        set_forecast_text page
        set_forecast_temp_view_color page
        set_forecast_image page
        set_date_view_text page


        #background image
        0.times do |i|
          if i % 2 == 0 #even
            BW::HTTP.get(landscape_images[i % landscape_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i, 0)
              else
                puts 'BAD RESPONSE'
              end
              @animate ? animate_views : show_views
              @location_name_view.fade_in(3.0)
            end
            BW::HTTP.get(landscape_images[i+1 % landscape_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i, 1)
              else
                puts 'BAD RESPONSE'
              end
              @animate ? animate_views : show_views
              @location_name_view.fade_in(3.0)
            end
          else # odd
            BW::HTTP.get(portrait_images[i % portrait_images.size]['photo_url']) do |response|
              if response.ok?
                add_image(response.body, i)
              else
                puts 'BAD RESPONSE'
              end
              @location_name_view.fade_in(3.0)
              @animate ? animate_views : show_views

            end
          end
        end
        @location_name_view.fade_in(3.0)
        @animate ? animate_views : show_views
      end


    end

  end

  def toggle_views
    @text_views.first.alpha <= 0.0 ? animate_views(1.0) : hide_views(1.0)
  end

  def scrollViewDidScroll(scrollView)
    unless @animation
      newCurrentPage = (@scrollView.contentOffset.x / @scrollView.frame.size.width).to_i
      if newCurrentPage != @pageControl.currentPage
        @pageControl.currentPage = newCurrentPage

        views_to_animate = @text_views.reject { |view| view == @location_name_view }
        UIView.animation_chain do
          views_to_animate.each { |text_view| text_view.layer.basic_animation('opacity', from: 1, to: 0.6, duration: 0.2) }
        end.and_then do
          views_to_animate.each { |text_view| text_view.layer.basic_animation('opacity', from: 0.8, to: 0, duration: 0.2) }
        end.and_then do
          set_date_view_text @pageControl.currentPage

          set_forecast_image @pageControl.currentPage

          set_forecast_text @pageControl.currentPage
          set_forecast_temp_view_color @pageControl.currentPage
        end.and_then do
          views_to_animate.each { |text_view| text_view.layer.basic_animation('opacity', from: 0.0, to: 1, duration: 0.4) }
        end.start


      end
    end

    @pageControl.currentPage
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
        action: 'show_info')

    self.navigationItem.rightBarButtonItem = right_info_image
    self.navigationItem.setHidesBackButton true
  end

  def add_image(data, page, top_offset_nr=nil, height=App.window.size.height/2-33)
    width = @scrollView.frame.size.width
    single = false
    if top_offset_nr.nil? # do fullscreen
      top_offset_nr = 0
      height = App.window.size.height # -68
      single = true
    end
    image = UIImage.alloc.initWithData(data)
    image.scale_to_fill([width, height], position: :center)
    view = UIImageView.alloc.initWithFrame(CGRectMake(width * page, [0, top_offset_nr*height].max, width, height))

    view.image = image
    @scrollView.addSubview(view)
    @scrollView.sendSubviewToBack view
    view.fade_out
    @image_views << view
    view
  end


  def animate_views(sec=3.0)
    @image_views.each { |image_view| image_view.fade_in(duration: sec) }
    @text_views.each { |text_view| text_view.fade_in(duration: sec) }

  end

  def show_views
    @image_views.each { |text_view| text_view.fade_in(duration: 0.0) }
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

  def init_admob
    @banner_view = GADBannerView.alloc.initWithAdSize(KGADAdSizeBanner)
    # Your Admob Publisher ID
    @banner_view.adUnitID = NSBundle.mainBundle.objectForInfoDictionaryKey('admob')
    @banner_view.rootViewController = self

    @banner_view.position = [160, 544]

    self.view.addSubview(@banner_view)
    request = GADRequest.request
    request.testDevices = [GAD_SIMULATOR_ID]
    @banner_view.loadRequest(request)
  end

end