//
//  ApplicationPreferencesWindowController.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/7/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface ApplicationPreferencesWindowController : HSWindowController
{
    
}

- (IBAction) onCancel: (id) sender;
- (IBAction) onAccept: (id) sender;
- (IBAction) onClearData: (id) sender;
- (IBAction) onCheckboxStateChanged: (id) sender;

@property(nonatomic,retain) NSArray * applicationIds;

@end
