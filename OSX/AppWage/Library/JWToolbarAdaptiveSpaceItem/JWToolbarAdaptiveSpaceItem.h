//
//  JWToolbarAdaptiveSpaceItem.h
//
//  Created by John Wells on 7/14/13.
//  Copyright (c) 2013 John Wells. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JWClickThroughView.h"

@interface JWToolbarAdaptiveSpaceItem : NSToolbarItem
{
    IBOutlet NSView *linkedView;
}

- (void)updateWidth;
@property(nonatomic,assign) CGFloat maxWidth;

@end
