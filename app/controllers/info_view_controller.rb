class InfoViewController < UIViewController

  def loadView
    self.view = UIWebView.alloc.init
  end

  def layoutDidLoad
    super
    self.title = 'Info'
    path = NSBundle.mainBundle.pathForResource('imprint', ofType: 'html')
    url = NSURL.fileURLWithPath(path)
    self.view.loadRequest NSURLRequest.requestWithURL(url)
    self.view.scrollView.scrollEnabled = true
    barBtnItem = UIBarButtonItem.alloc.initWithTitle("iBack", style:UIBarButtonItemStyleBordered, target:self, action: 'none')

    self.navigationItem.backBarButtonItem = barBtnItem
  end

end