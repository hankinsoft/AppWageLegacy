//
//  PreferencesWindowController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/20/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface AWPreferencesWindowController : HSWindowController

- (IBAction) onAccounts: (id) sender;
- (IBAction) onEmail: (id) sender;
- (IBAction) onNotifications: (id) sender;
- (IBAction) onRankings: (id) sender;
- (IBAction) onNetwork: (id) sender;

- (IBAction) onCancel: (id) sender;
- (IBAction) onAccept: (id) sender;
- (IBAction) onTestEmail: (id) sender;

- (IBAction) onEnableAnimations: (id) sender;

- (IBAction) onTestPort: (id) sender;

@property(nonatomic, assign) BOOL addingDeveloper;

@end
