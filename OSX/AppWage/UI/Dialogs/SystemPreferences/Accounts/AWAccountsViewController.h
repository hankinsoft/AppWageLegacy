//
//  AccountsViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AccountsViewControllerDelegate <NSObject>

- (void) beganLoadingVendorId;
- (void) accountsViewControllerHasError: (NSError*) error;
- (void) endLoadingVendorId;

@end

@interface AWAccountsViewController : NSViewController

- (IBAction) onAddRemoveAccountSegmenetedControl: (id) sender;
- (void) addAccount;

- (IBAction) onLoadVendorId: (id) sender;
- (IBAction) onAppleIdChanged: (id) sender;
- (IBAction) onAccessTokenChanged: (id) sender;
- (IBAction) onVendorIdChanged: (id) sender;
- (IBAction) onVendorNameChanged: (id) sender;

- (bool) isValid;
- (NSArray*) changedAccounts;

@property(nonatomic,weak) id<AccountsViewControllerDelegate> delegate;

@end
