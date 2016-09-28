//
//  JWAppDelegate.h
//  AdaptiveSpacerExample
//
//  Created by John Wells on 7/14/13.
//  Copyright (c) 2013 John Wells. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JWToolbarAdaptiveSpaceItem.h"

@interface JWAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet JWToolbarAdaptiveSpaceItem *adaptiveSpaceItem;

@end
