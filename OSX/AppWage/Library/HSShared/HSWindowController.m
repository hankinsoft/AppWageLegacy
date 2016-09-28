//
//  HSWindowController.m
//  SQLite Toolbox
//
//  Created by Kyle Hankinson on 2012-06-15.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import "HSWindowController.h"

extern const NSModalResponse HSModalResponseSaveAndConnect;
extern const NSModalResponse HSModalResponseSaveWithoutConnecting;

@implementation HSWindowController
{
    BOOL windowHadClosed;
}

- (void) beginSheetModalForWindow: (nonnull NSWindow *) parentWindow
                completionHandler: (void (^ __nullable)(NSModalResponse returnCode))handler
{
    [parentWindow beginSheet: self.window
           completionHandler: handler];
}

- (void) endSheetWithReturnCode: (NSModalResponse) result
{
    windowHadClosed = YES;

    NSString * returnCodeDescription = [NSString stringWithFormat: @"%ld", result];
    if(NSOKButton == result)
    {
        returnCodeDescription = @"OK";
    } // End of ok button
    else if(NSCancelButton == result)
    {
        returnCodeDescription = @"Cancel";
    } // End of cancel button

    NSLog(@"%@ endSheetWithReturnCode: %@",
          NSStringFromClass(self.class),
          returnCodeDescription);

    // End any editing
    [self.window makeFirstResponder: nil];
    [self.window.sheetParent endSheet: self.window
                           returnCode: result];
} // End of endSheetWithReturnCode

- (BOOL) windowHasClosed
{
    return windowHadClosed;
} // End of windowHasClosed

@end

