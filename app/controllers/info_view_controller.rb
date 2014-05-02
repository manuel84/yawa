class InfoViewController < UIViewController

  stylesheet :info_view

  def layoutDidLoad
    super
    self.title = 'Info'
    @text_view = UITextView.alloc.initWithFrame [[0, 0], [320, 586]], style: UITableViewStylePlain
    @text_view.text = "Du bist sehr sehr geil!"
    view.addSubview(@text_view)

    1.second.later do
      say_hello
    end

  end

  def say_hello
    @synthesizer = AVSpeechSynthesizer.new
    utterance = AVSpeechUtterance.speechUtteranceWithString("Du bist sehr sehr geil")
    voice = AVSpeechSynthesisVoice.voiceWithLanguage("de-DE")
    utterance.voice = voice
    utterance.rate = 0.15
    @synthesizer.speakUtterance(utterance)
    sleep(4)
    utterance = AVSpeechUtterance.speechUtteranceWithString("Supergeil")
    voice = AVSpeechSynthesisVoice.voiceWithLanguage("de-DE")
    utterance.voice = voice
    utterance.rate = 0.15

    @synthesizer.speakUtterance(utterance)
  end
end