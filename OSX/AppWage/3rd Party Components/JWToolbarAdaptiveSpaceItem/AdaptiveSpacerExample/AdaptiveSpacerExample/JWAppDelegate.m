//
//  JWAppDelegate.m
//  AdaptiveSpacerExample
//
//  Created by John Wells on 7/14/13.
//  Copyright (c) 2013 John Wells. All rights reserved.
//

#import "JWAppDelegate.h"

@implementation JWAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [self.adaptiveSpaceItem updateWidth];
}

@end
