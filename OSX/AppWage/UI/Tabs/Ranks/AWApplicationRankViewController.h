//
//  ApplicationRankViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/15/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWApplicationRankViewController : NSViewController

- (IBAction) onDownloadRanks: (id) sender;
- (IBAction) onDateRange: (id)sender;

- (void) setSelectedApplications: (NSSet*) selectedApplications;

@property(nonatomic,assign) BOOL isFocusedTab;

@end
