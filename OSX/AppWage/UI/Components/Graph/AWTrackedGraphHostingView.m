//
//  TrackedGraphHostingView.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/7/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWTrackedGraphHostingView.h"

@implementation AWTrackedGraphHostingView

@synthesize mouseDelegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSInteger trackingOptions =
            NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseMoved;

        // Setup a new tracking area when the view is added to the window.
        NSTrackingArea * trackingArea = [[NSTrackingArea alloc] initWithRect: [self bounds]
                                                    options: trackingOptions
                                                      owner: self
                                                   userInfo: nil];

        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void) mouseMoved: (NSEvent *) theEvent
{
    [super mouseMoved: theEvent];

    NSPoint mouseLocation = [self convertPoint: [theEvent locationInWindow] fromView:nil];
    [self.mouseDelegate trackedGraphHostingView: self mouseMovedTo: mouseLocation];
}

@end
