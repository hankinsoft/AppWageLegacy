//
//  HSOutlineView.m
//  OutlineView
//
//  Created by Kyle Hankinson on 2014-06-24.
//  Copyright (c) 2014 com.hankinsoft. All rights reserved.
//

#import "HSOutlineView.h"

@implementation HSOutlineView

@synthesize isDark, hsOutlineViewDelegate;

static NSColor * HSOutlineViewBackgroundColor;

+ (void) initialize
{
    HSOutlineViewBackgroundColor = [NSColor colorWithSRGBRed: 82.0 / 255.0
                                                       green: 82.0 / 255.0
                                                        blue: 82.0 / 255.0
                                                       alpha: 1];
}

- (id) init
{
    self = [super init];
    return self;
} // End of init

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame: frameRect];
    return self;
} // End of initWithFrame

- (void) awakeFromNib
{
    [super awakeFromNib];
    // Default
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
} // End of awakeFromNib

- (void) setIsDark: (BOOL)_isDark
{
    NSScrollView * scrollView = [self enclosingScrollView];

    if(_isDark)
    {
        [scrollView setDrawsBackground: NO];
        self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        self.backgroundColor         = [NSColor clearColor];
    }
    else
    {
        [scrollView setDrawsBackground: YES];
        self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
    }

    isDark = _isDark;
} // End of setIsDark

- (NSColor*) outlineViewColor
{
    if(isDark)
    {
        return HSOutlineViewBackgroundColor;
    } // End of isDark
    else
    {
        // Default to our own background color
        return self.backgroundColor;
    } // End of default
} // End of outlineViewColor

- (NSColor*) mainTextColor
{
    if(isDark)
    {
        return [NSColor colorWithSRGBRed: 0.9
                                   green: 0.9
                                    blue: 0.9
                                   alpha: 1.0];
    }
    else
    {
        return [NSColor textColor];
    } // End of is dark
} // End of mainTextColor

- (NSColor*) detailTextColor: (BOOL) isSelected
{
    if(isDark)
    {
        return [NSColor colorWithSRGBRed: 180.0 / 255.0
                                   green: 178.0 / 255.0
                                    blue: 178.0 / 255.0
                                   alpha: 1.0];
    } // End of color is dark

    if(isSelected)
    {
        return [NSColor colorWithCalibratedRed: 0.80
                                         green: 0.80
                                          blue: 0.80
                                         alpha: 1.0];
    } // End of isSelected

    return [NSColor darkGrayColor].copy;
} // End of detailTextColor

- (void) drawBackgroundInClipRect: (NSRect) clipRect
{
    [super drawBackgroundInClipRect: clipRect];

    if(isDark)
    {
        [HSOutlineViewBackgroundColor setFill];
        NSRectFill(clipRect);
    } // End of isDark
} // End of drawBackgroundInClipRect:

- (void) deselectAll: (id)sender
{
    [super deselectAll: sender];
} // End of deselectAll

- (void) selectRowIndexes:(NSIndexSet *)indexes
     byExtendingSelection:(BOOL)extend
{
    if([self.hsOutlineViewDelegate respondsToSelector: @selector(outlineViewSelectionWillChange:)])
    {
        [self.hsOutlineViewDelegate outlineViewSelectionWillChange: self];
    } // End of view responds to selection will change

    [super selectRowIndexes: indexes
       byExtendingSelection: extend];
} // End of selectRowIndexes:byExtendingSelection:

#pragma -
#pragma Keyboard

- (void) keyDown:(NSEvent *) theEvent
{
    NSUInteger flags = [theEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    BOOL commandDown = (flags & NSCommandKeyMask) > 0;

    if(commandDown && theEvent.keyCode == 125)
    {
        [self.hsOutlineViewDelegate outlineViewCmdDown: self];
        return;
    } // End of cmd + down
    else if(commandDown && theEvent.keyCode == 124)
    {
        [self.hsOutlineViewDelegate outlineViewCmdRight: self];
        return;
    } // End of cmd + right

    [super keyDown: theEvent];
} // End of keyDown

@end
