//
//  AddAccountWindowController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSWindowController.h"

@interface AWAddAccountWindowController : HSWindowController
{
    
}

- (IBAction) onCancel: (id) sender;
- (IBAction) onAccept: (id) sender;

@property(nonatomic,retain) IBOutlet NSTextField * accountIdTextField;
@property(nonatomic,retain) IBOutlet NSTextField * vendorNameTextField;

@end
