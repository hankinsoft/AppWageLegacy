LVDebounce
==========

An Objective-C library for debouncing NSTimers

## Installation

Put this in your Podfile and smoke it:

```ruby
pod 'LVDebounce'
```

## Usage

It's a pretty simple API, designed to mirror the NSTimer API as much as possible.

Here's a trite example:


```Objective-C
#import "LVDebounce.h"

- (void)helloWorld {
    NSLog(@"Hello, World!"); // Will only run once
}

- (void)applicationDidFinishLaunching {
  for (int i = 0; i < 10; i++) {
      [LVDebounce fireAfter:1.0 target:self selector:@selector(helloWorld) userInfo:nil];
  }
}
```

That's all there is to it.
