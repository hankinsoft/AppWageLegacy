##JWToolbarAdaptiveSpaceItem
![image](http://cl.ly/image/1R0K2w1G1X1C/screenshot.png)
###Description
`JWToolbarAdaptiveSpaceItem` is an `NSToolbarItem` subclass that acts as an adaptive spacer for OS X applications with a toolbar and source list or other pane-like structure. Once set up, it will automatically adjust its width to match the width of an attached `NSView` (most likely the left pane of an `NSSplitView`) as can be seen in applications like Apple Mail.

###Usage
1. Add `JWToolbarAdaptiveSpaceItem` and `JWClickThroughView`'s .h and .m files to your Xcode project
2. Add a blank `NSToolbarItem` to your window's toolbar
3. With the blank toolbar item selected, select the Identity inspector and change the item's class to `JWToolbarAdaptiveSpaceItem`
4. Connect the `linkedView` outlet of the spacer item to the appropriate `NSSplitView` pane or view
5. If you haven't already, assign a delegate to your `NSSplitView`
6. In the .h file of your split view delegate, create an outlet for your spacer item
7. Add `#import "JWToolbarAdaptiveSpaceItem.h"` to the top of your split view delegate's .h file
8. In your split view delegate's `splitViewDidResizeSubviews` method, send an `updateWidth` message to your spacer item.