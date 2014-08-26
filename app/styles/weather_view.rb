Teacup::Stylesheet.new :weather_view do
  style :image_view1,
        frame: [[0, 00], [320, 180]]

  style :image_view2,
        frame: [[0, 180], [320, 180]]

  style :image_view3,
        frame: [[0, 360], [320, 180]]

  style :image_view4,
        frame: [[0, 540], [320, 180]]

  style :text_view,
        textAlignment: UITextAlignmentCenter,
        font: UIFont.fontWithName('Arvo', size: 30),
        textColor: UIColor.lightGrayColor,
        backgroundColor: '#000000'.uicolor,
        alpha: 0.8

  style :title_view, extends: :text_view,
        top: 60, left: 30,
        width: 260, height: 50

  style :forecast_temp_view, extends: :text_view,
        top: 235, left: 60,
        width: 200, height: 80,
        font: UIFont.fontWithName('Arvo', size: 80)

  style :forecast_title_view, extends: :text_view,
        top: 430, left: 80,
        width: 160, height: 50


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
