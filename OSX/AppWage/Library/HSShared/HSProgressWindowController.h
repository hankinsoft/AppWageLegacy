//
//  ProgressWindowController.h
//  SQLite Professional
//
//  Created by Kyle Hankinson on 2013-03-29.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface HSProgressWindowController : HSWindowController
{
}

@property(nonatomic,copy) NSString         * labelString;

- (void) setLabelString: (NSString *) newLabelString
          resetProgress: (BOOL) resetProgress;

- (void) setProgress: (double) progress;

@end
