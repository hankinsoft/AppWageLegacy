//
//  DashboardSummaryTileViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-24.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWDashboardSummaryTileViewController : NSViewController

@property(nonatomic,assign) NSUInteger mode;
@property(nonatomic,copy)   NSSet      * selectedProductIdentifiers;

- (void) update: (BOOL) updateTotal upgradeSelectionRange: (BOOL) upgradeSelectionRange;

@end
