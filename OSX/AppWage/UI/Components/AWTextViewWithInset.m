//
//  AWTextViewWithInset.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-06.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWTextViewWithInset.h"

@implementation AWTextViewWithInset

- (void) awakeFromNib
{
    [super awakeFromNib];

    [super setTextContainerInset:NSMakeSize(5.0f, 15.0f)];
} // End of awakeFromNib

- (NSPoint) textContainerOrigin
{
    NSPoint origin = [super textContainerOrigin];
    NSPoint newOrigin = NSMakePoint(origin.x + 5.0f, origin.y);
    return newOrigin;
} // End of textContainerOrigin

@end
