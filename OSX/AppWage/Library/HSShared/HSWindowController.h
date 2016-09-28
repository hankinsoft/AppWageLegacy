//
//  HSWindowController.h
//  SQLite Toolbox
//
//  Created by Kyle Hankinson on 2012-06-15.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

@import Foundation;

@interface HSWindowController : NSWindowController 

- (void) beginSheetModalForWindow: (nonnull NSWindow *) parentWindow
                completionHandler: (void (^ __nullable)(NSModalResponse returnCode))handler;

// Convenience methods for subclasses to use
- (void) endSheetWithReturnCode: (NSModalResponse) result;

- (BOOL) windowHasClosed;

@end
