//
//  AWSplitViewWithoutDivider.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-24.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSplitViewWithoutDivider.h"

@implementation AWSplitViewWithoutDivider

NSImage * customLightDividerImage;
NSImage * customDarkDividerImage;

+ (void) initialize
{
    customLightDividerImage = [NSImage imageNamed: @"SplitView-LightDivider"];
    customDarkDividerImage = [NSImage imageNamed: @"SplitView-DarkDivider"];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) drawDividerInRect: (NSRect) aRect
{
    if([self.identifier isEqualToString: @"Totals"])
    {
        NSRect newRect = NSMakeRect(aRect.origin.x,
                                    aRect.origin.y + 10,
                                    aRect.size.width,
                                    aRect.size.height - 20);

        [customLightDividerImage drawInRect: newRect
                                   fromRect:NSZeroRect
                                  operation:NSCompositeSourceOver
                                   fraction:1.0
                             respectFlipped:YES
                                      hints:nil];
    }
    else
    {
        NSRect newRect = NSMakeRect(aRect.origin.x,
                                    aRect.origin.y + 10,
                                    aRect.size.width,
                                    aRect.size.height - 20);

        [customDarkDividerImage drawInRect: newRect
                                  fromRect:NSZeroRect
                                 operation:NSCompositeSourceOver
                                  fraction:1.0
                            respectFlipped:YES
                                     hints:nil];
    }
} // End of drawDividerInRect:

- (CGFloat) dividerThickness
{
    if([self.identifier isEqualToString: @"Totals"])
    {
        return 1;
    }
    return 1;
} // End of dividerThickness

@end
