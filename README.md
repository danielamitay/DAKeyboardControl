## DAKeyboardControl

DAKeyboardControl is a collection of UIView subclasses that allow the user to drag the UIKeyboard down from a view. DAKeyboardControl is unique because it allows the "drag down" functionality even from a UITableView. As a result, with DAKeyboardControl, you are able to mimic the chat bar functionality of the iMessage app.

Gets along well with other subclasses and categories. No dirty, breakable hacks.

View the included example project for a demonstration.

## Installation

To use DAKeyboardControl:

1 - Copy over the `DAKeyboardControl` folder to your project folder.
2 - Subclass.
Optional - Customize.

## Usage
Wherever you want to use DAKeyboardControl, import the appropriate header file and subclass as follows:

For UIView:
```
' #import "DAKeyboardControlView.h" '
```

For UITableView:
```
' #import "DAKeyboardControlTableView.h" '
```

For UIScrollView:
```
' #import "DAKeyboardControlScrollView.h" '
```

Subclass either via code or Interface Builder.

## Delegate Method
Each of the DAKeyboardControl classes supports the following optional delegate method:

```
- (void)keyboardFrameWillChange:(CGRect)newFrame
						   from:(CGRect)oldFrame
						   over:(CGFloat)seconds;
```

This gives you the opportunity to move views up or down as the keyboard appears/disappears/moves. View the "Offset TableView Example" implementation.
A delegate property is included in the UIView class to support.

## Notes

### Untested in App Store
All code is iOS 4.3+ safe and well documented, but has not been put into a production app (yet).

### Tiny Glitch
The first time that the keyboard appears, there is a little hiccup due to loading lag (of the UIKeyboard). Will see what can be done.

### Automatic Reference Counting (ARC) support
DAKeyboardControl was made with ARC enabled by default.

## Contact

- [Personal website](http://www.amitay.us)
- [GitHub](http://github.com/danielamitay)
- [Twitter](http://twitter.com/danielamitay)
- [LinkedIn](http://www.linkedin.com/in/danielamitay)
- [Hacker News](http://news.ycombinator.com/user?id=danielamitay)
- [Email](daniel@amitay.us)

If you use/enjoy DAKeyboardControl, let me know!

## License

### MIT License

Copyright (c) 2012 Daniel Amitay (http://www.amitay.us)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
