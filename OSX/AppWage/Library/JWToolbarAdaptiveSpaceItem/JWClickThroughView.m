//
//  JWClickThroughView.m
//
//  Created by John Wells on 7/14/13.
//  Copyright (c) 2013 John Wells. All rights reserved.
//

#import "JWClickThroughView.h"

@implementation JWClickThroughView

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
    // Drawing code here.
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return NO;
}

@end
