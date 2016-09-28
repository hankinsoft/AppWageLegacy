//
//  ApplicationSelectionWindowController.h
//  AppWage
//
//  Created by Kyle Hankinson on 12/5/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface ApplicationSelectionWindowController: HSWindowController

- (IBAction) doSearch: (id) sender;

- (IBAction) onToggleAllApps: (id) sender;
- (IBAction) onCancel: (id) sender;
- (IBAction) onAccept: (id) sender;

- (NSArray*) getSelectedApplications;

@end
