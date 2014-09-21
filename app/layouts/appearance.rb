# Teacup::Appearance.new do
#
#   # UINavigationBar.appearance.setBarTintColor(UIColor.blackColor)
#   style UINavigationBar,
#         barTintColor: "#ff3527".uicolor,
#         titleTextAttributes: {
#             #UITextAttributeTextShadowColor => UIColor.colorWithWhite(0.0, alpha:0.4),
#             UITextAttributeTextColor => UIColor.whiteColor
#         }
#
#   # UINavigationBar.appearanceWhenContainedIn(UINavigationBar, nil).setColor(UIColor.blackColor)
#   style UIBarButtonItem, when_contained_in: UINavigationBar,
#         tintColor: UIColor.whiteColor
#
#   # UINavigationBar.appearanceWhenContainedIn(UIToolbar, UIPopoverController, nil).setColor(UIColor.blackColor)
#   style UIBarButtonItem, when_contained_in: [UIToolbar, UIPopoverController],
#         tintColor: UIColor.whiteColor
#
# end