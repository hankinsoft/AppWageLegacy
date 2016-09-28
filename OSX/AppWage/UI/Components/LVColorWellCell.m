//
//  LVColorWellCell.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/9/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "LVColorWellCell.h"

@implementation LVColorWellCell

-(void)drawWithFrame:(NSRect)cellFrame
              inView:(NSView *)controlView
{
    [NSGraphicsContext saveGraphicsState];

    cellFrame = NSInsetRect(cellFrame, 10.0, 2.0);

    NSColor * color = (NSColor *)[self objectValue];
    if ( [color respondsToSelector:@selector(setFill)] )
    {
        [color drawSwatchInRect:cellFrame];
    }

    [NSGraphicsContext restoreGraphicsState];
}

@end
