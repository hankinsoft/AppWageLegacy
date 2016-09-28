//
//  ApplicationTableCellView.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/25/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationTableCellView.h"

@implementation AWApplicationTableCellView

@synthesize appNameTextView, appDetailsTextView, unreadReviewsTextView;

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // Returning nil circumvents the standard row highlighting.
    return nil;
}

- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect
{
    NSLog(@"test");
}

@end
