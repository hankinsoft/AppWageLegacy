//
//  ApplicationListTreeViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AWApplicationListTreeViewControllerProtocol <NSObject>

- (void) selectedApplicationsChanged: (NSSet*) newSelection;

@end

@interface AWApplicationListTreeViewController : NSViewController

@property(nonatomic,weak) id<AWApplicationListTreeViewControllerProtocol> delegate;

+ (NSString*) applicationListRequiresUpdateNotificationName;
+ (void) expandAccount: (NSString*) accountName;

- (void) initialize;
- (void) reloadApplications;

- (IBAction) onAdd: (id) sender;
- (IBAction) onAddApplication: (id) sender;
- (IBAction) onAddDeveloper: (id) sender;
- (IBAction) onRemoveApplication: (id) sender;
- (IBAction) onApplicationProperties: (id) sender;
- (IBAction) onHideApplications: (id) sender;

- (IBAction) onCollectReviewForSelectedApplications: (id) sender;
- (IBAction) onCollectRanksForSelectedApplications: (id) sender;

- (IBAction) onTwitter: (id) sender;
- (IBAction) onFacebook: (id) sender;

@end
