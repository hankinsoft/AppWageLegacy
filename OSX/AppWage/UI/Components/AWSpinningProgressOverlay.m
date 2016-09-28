//
//  AWSpinningProgressOverlay.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/30/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSpinningProgressOverlay.h"

@implementation AWSpinningProgressOverlay

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
    [[NSColor colorWithCalibratedWhite: 0.250 alpha: 0.500] set];
    [NSBezierPath fillRect: dirtyRect];
}

@end
