//
//  BackgroundView.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/25/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

@synthesize image;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    dirtyRect = [self bounds];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);

    [image drawInRect: dirtyRect
             fromRect: NSZeroRect
            operation: NSCompositeSourceOver
             fraction: 1]; // Passing NSZeroRect causes the entire image to draw.
}

@end
