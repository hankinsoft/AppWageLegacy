//
//  OutlineViewWithMenu.m
//  SQL Server Professional
//
//  Created by Kyle Hankinson on 6/13/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "HSOutlineViewWithMenu.h"

@implementation HSOutlineViewWithMenu

@synthesize menuDelegate;

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString *chars = [theEvent charactersIgnoringModifiers];
    
    if ([theEvent type] == NSKeyDown && [chars length] == 1)
    {
        int val = [chars characterAtIndex:0];

        // check for a delete
        if (val == 127 || val == 63272)
        {
            if ([[self delegate] respondsToSelector:@selector(tableViewDidRecieveDeleteKey:)])
            {
                [[self delegate] performSelector:@selector(tableViewDidRecieveDeleteKey:) withObject:self];
                return NO;
            }
        }
        // check for the enter / space to open it up
        else if (val == 13 /*return*/ || val == 32 /*space bar*/)
        {
            if ([[self delegate] respondsToSelector:@selector(tableDidRecieveEnterOrSpaceKey:)]) {
                [[self delegate] performSelector:@selector(tableDidRecieveEnterOrSpaceKey:) withObject:self];
                return YES;
            }
        }
    }
    
    return [super performKeyEquivalent:theEvent];
}

-(NSMenu*)menuForEvent:(NSEvent*)evt
{
    return [menuDelegate menuForEvent: evt];
}

@end
