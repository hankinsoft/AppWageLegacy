//
//  ProgressWindowController.m
//  SQLite Professional
//
//  Created by Kyle Hankinson on 2013-03-29.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "HSProgressWindowController.h"

@interface HSProgressWindowController ()
{
    IBOutlet NSProgressIndicator                        * progressIndicator;
    IBOutlet NSTextField                                * label;
}
@end

@implementation HSProgressWindowController

@synthesize labelString;

- (id)init
{
    if (!(self = [super initWithWindowNibName: @"HSProgressWindowController"]))
    {
        return nil; // Bail!
    }

    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Start the progressIndicator
    [progressIndicator startAnimation: self];
    label.stringValue = labelString;
}

- (void) setLabelString: (NSString *) newLabelString
{
    [self setLabelString: newLabelString
           resetProgress: YES];
} // End of setLabelString

- (void) setLabelString: (NSString *) newLabelString
          resetProgress: (BOOL) resetProgress
{
    labelString = newLabelString;
    label.stringValue = newLabelString;

    if(resetProgress)
    {
        [progressIndicator setIndeterminate: YES];
    }
}

- (void) setProgress: (double) progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressIndicator setIndeterminate: NO];
        [progressIndicator setMaxValue: 100];
        [progressIndicator setDoubleValue: progress];
    });
} // End of setProgress

@end
