//
//  HSTableRowView.m
//  OutlineView
//
//  Created by Kyle Hankinson on 2014-06-24.
//  Copyright (c) 2014 company. All rights reserved.
//

#import "HSTableRowView.h"

@implementation HSTableRowView

@synthesize isDark;

static NSImage * HSTableRowViewSelectionImage = nil;
static NSImage * HSTableRowViewExpandedImage  = nil;
static NSImage * HSTableRowViewCollapsedImage = nil;

+ (void) initialize
{
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        NSBundle * currentBundle = [NSBundle mainBundle];

	    HSTableRowViewSelectionImage = [currentBundle imageForResource: @"HSOutlineViewSelectionDark"];
	    HSTableRowViewExpandedImage = [currentBundle imageForResource: @"HSOutlineViewTriangleRight"];
	    HSTableRowViewCollapsedImage = [currentBundle imageForResource: @"HSOutlineViewTriangleDown"];

	    NSAssert(nil != HSTableRowViewCollapsedImage, @"Collapsed image unavailable");
	    NSAssert(nil != HSTableRowViewExpandedImage, @"Expanded image unavailable");
	    NSAssert(nil != HSTableRowViewSelectionImage, @"Selection image unavailable");
    });
} // End of initailize

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    } // End of self

    return self;
}

- (void)drawRect: (NSRect)dirtyRect
{
    if(!self.isGroupRowStyle)
    {
        [super drawRect: dirtyRect];
    }
}

- (void)drawSelectionInRect: (NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
        if(self.groupRowStyle)
        {
        }
        else
        {
            if(isDark)
            {
                [HSTableRowViewSelectionImage drawInRect: self.bounds
                                                fromRect: NSZeroRect
                                               operation: NSCompositeSourceOver
                                                fraction: 1.0
                                          respectFlipped: YES
                                                   hints: nil];
            }
        }
    }
}

- (void) didAddSubview:(NSView *)subview
{
    [super didAddSubview: subview];

    // If we are not dark, then do nothing
    if(!isDark)
    {
        return;
    } // End of do nothing

    if ( [subview isKindOfClass:[NSButton class]] )
    {
        // This is (presumably) the button holding the
        // outline triangle button.
        // We set our own images here.
        [(NSButton *)subview setImage: HSTableRowViewExpandedImage];
        [(NSButton *)subview setAlternateImage: HSTableRowViewCollapsedImage];
    } // End of button
}

@end
