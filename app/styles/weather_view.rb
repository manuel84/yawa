Teacup::Stylesheet.new :weather_view do

  style :image_view1,
        frame: [['0%', '0%'], ['100%', '50%']]

  style :image_view2,
        frame: [['0%', '50%'], ['100%', '50%']]

  style :title_view,
        top: 50, left: 10,
        width: 300, height: 100,
        textAlignment: UITextAlignmentCenter,
        font: UIFont.fontWithName('Arvo', size: 30),
        textColor: "#aabbcc".uicolor

  style :forecast_temp_view,
          top: '50%', left: 60,
          width: 200, height: 100,
          textAlignment: UITextAlignmentCenter,
          font: UIFont.fontWithName('Arvo', size: 80),
          textColor: "#aabbcc".uicolor

  style :forecast_title_view,
        top: '35%', left: 60,
        width: 200, height: 100,
        textAlignment: UITextAlignmentCenter,
        font: UIFont.fontWithName('Arvo', size: 30),
        textColor: "#aabbcc".uicolor

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
