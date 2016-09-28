//
//  InitialSetupWizard.h
//  AppWage
//
//  Created by Kyle Hankinson on 2015-01-23.
//  Copyright (c) 2015 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface AWInitialSetupWizard : HSWindowController

- (IBAction) onCancel: (id) sender;
- (IBAction) onNext: (id)sender;
- (IBAction) onPrevious: (id)sender;
- (IBAction) onToggleEmailEnabled: (id) sender;

@end
