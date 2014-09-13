Teacup::Stylesheet.new :weather_view do
  style :image_view1,
        frame: [[0, 00], [320, 180]]

  style :image_view2,
        frame: [[0, 180], [320, 180]]

  style :image_view3,
        frame: [[0, 360], [320, 180]]

  style :image_view4,
        frame: [[0, 540], [320, 180]]

  @background_color = '#000000'.uicolor(0.38)

  style :text_view,
        textAlignment: UITextAlignmentCenter,
        font: UIFont.fontWithName('Arvo', size: 30),
        textColor: UIColor.lightGrayColor,
        backgroundColor: @background_color

  style :title_view, extends: :text_view,
        top: 80, left: 30,
        width: 260, height: 50

  style :forecast_temp_view, extends: :text_view,
        top: 205, left: 60,
        width: 200, height: 80,
        textColor: UIColor.darkGrayColor,
        font: UIFont.fontWithName('Arvo', size: 80)

  style :forecast_title_view,#, extends: :text_view,
        top: 210, left: 10,
        width: 300, height: 300

  style :forecast_date_view, extends: :text_view,
        top: 430, left: 60,
        width: 200, height: 50


  style :result,
        font: UIFont.fontWithName('Arvo', size: 50),
        textAlignment: UITextAlignmentCenter,
        textColor: "#595959".uicolor,
        frame: [[100, 7], [120, 70]]

  style :team1,
        frame: [[10, 57], [100, 30]],
        font: UIFont.fontWithName('HelveticaNeue-Medium', size: 12),
        textAlignment: UITextAlignmentCenter

  style :team2,
        frame: [[200, 57], [100, 30]],
        font: UIFont.fontWithName('HelveticaNeue-Medium', size: 12),
        textAlignment: UITextAlignmentCenter


end
