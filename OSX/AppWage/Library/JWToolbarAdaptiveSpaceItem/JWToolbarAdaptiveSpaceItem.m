//
//  JWToolbarAdaptiveSpaceItem.m
//
//  Created by John Wells on 7/14/13.
//  Copyright (c) 2013 John Wells. All rights reserved.
//

#import "JWToolbarAdaptiveSpaceItem.h"

@implementation JWToolbarAdaptiveSpaceItem

@synthesize maxWidth;

-(void)awakeFromNib
{
    JWClickThroughView *transparentView = [[JWClickThroughView alloc] init];
    
    self.view = transparentView;
}

-(NSString *)label
{
    return @"";
}

-(NSString *)paletteLabel
{
    return @"Adaptive Space Item";
}

-(NSSize)minSize
{
    [self updateWidth];
    return [super minSize];
}

-(NSSize)maxSize
{
    [self updateWidth];
    return [super maxSize];
}

- (void)updateWidth
{
    if(linkedView){
        NSSize newSize;

        if (linkedView.frame.size.width-16 > -8) {
            newSize = NSMakeSize(linkedView.frame.size.width-16, 0);
        } else {
            newSize = NSMakeSize(-8, 0);
        }
        
        if(newSize.width > maxWidth && 0 != maxWidth)
        {
            newSize.width = maxWidth;
        }

        [self setMinSize: newSize];
        [self setMaxSize: newSize];
    }
}



@end
