//
//  AccountsViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWAccountsViewController.h"
#import "AWiTunesConnectHelper.h"
#import "AWAccountHelper.h"
#import "AWAccount.h"

@interface AWAccountsViewController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    NSArray                         * accountsArray;

    IBOutlet NSTableView            * accountsTableView;
    IBOutlet NSSegmentedControl     * addRemoveAccountSegmenetedControl;

    IBOutlet NSProgressIndicator    * loadVendorIdProgressIndicator;
    IBOutlet NSButton               * loadVendorIdButton;

    IBOutlet NSTextField            * accountIDTextField;
    IBOutlet NSTextField            * accountVendorIdTextField;
    IBOutlet NSTextField            * accountVendorNameTextField;
    IBOutlet NSSecureTextField      * accountAccessTokenTextField;
}
@end

@implementation AWAccountsViewController

@synthesize delegate;

- (id)init
{
    self = [super initWithNibName: @"AWAccountsViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
} // End of init

- (void) loadView
{
    [super loadView];

    NSMutableArray * accounts = [NSMutableArray array];

    NSArray * allAccounts = [AWAccount allAccounts];
    [allAccounts enumerateObjectsUsingBlock:
     ^(AWAccount * account, NSUInteger accountIndex, BOOL * stop)
     {
         AccountDetails * accountDetails =
            [[AWAccountHelper sharedInstance] accountDetailsForInternalAccountId: account.internalAccountId];

         if(nil != accountDetails)
         {
             // Add our accountDetails
             [accounts addObject: accountDetails];
         } // End of no account details
         else
         {
             AccountDetails * accountDetails = [[AccountDetails alloc] init];
             accountDetails.accountInternalId = account.internalAccountId;
             accountDetails.removed  = NO;
             accountDetails.modified = NO;
             accountDetails.vendorId = nil;
             accountDetails.vendorName = @"Unknown account";
             accountDetails.accountUserName = nil;
             accountDetails.accountAccessToken = nil;

             [accounts addObject: accountDetails];
         }
     }];

    accountsArray = [NSArray arrayWithArray: accounts];
    [self updateUI];
}

- (bool) isValid
{
    __block BOOL valid = YES;

    [accountsArray enumerateObjectsUsingBlock:
     ^(AccountDetails * accountEntry, NSUInteger index, BOOL * stop)
     {
         if(
            0 == accountEntry.vendorName.length ||
            nil == accountEntry.vendorId
            )
         {
             if(!accountEntry.removed)
             {
                 valid = NO;
                 *stop = YES;
             } // End of we are not removing this account
         }
     }];

    return valid;
} // End of isValid

- (NSArray*) changedAccounts
{
    __block NSMutableArray * changedAccounts = [NSMutableArray array];
    
    [accountsArray enumerateObjectsUsingBlock: ^(AccountDetails * accountEntry, NSUInteger index, BOOL * stop)
     {
         if(accountEntry.modified)
         {
             [changedAccounts addObject: accountEntry];
         }
     }];

    return changedAccounts.copy;
} // End of changedAccounts

#pragma mark -
#pragma mark Actions

- (IBAction) onAddRemoveAccountSegmenetedControl: (id) sender
{
    if(0 == addRemoveAccountSegmenetedControl.selectedSegment)
    {
        [self addAccount];
        return;
    }

    if(-1 == accountsTableView.selectedRow)
    {
        return;
    }

    // Remove our entry from the array.
    NSMutableArray * updateArray = [NSMutableArray arrayWithArray: accountsArray];
    AccountDetails * entry = updateArray[accountsTableView.selectedRow];

    BOOL deselect = NO;

    // If the account is newly created, then we can go ahead and remove it.
    if(nil == entry.accountInternalId)
    {
        [updateArray removeObjectsAtIndexes: accountsTableView.selectedRowIndexes];
        accountsArray = [NSArray arrayWithArray: updateArray];
        deselect = YES;
    }
    else
    {
        // Set the entry to be deleted
        entry.modified = YES;
        entry.removed  = YES;
    } // End of its an old account.

    [accountsTableView reloadData];
    
    if(deselect)
    {
        [accountsTableView deselectAll: nil];
    } // End of deselect

    // Update our UI
    [self updateUI];

    // And make sure our progress is not animated.
    [loadVendorIdProgressIndicator stopAnimation: nil];

    NSLog(@"Remove");
}

- (void) addAccount
{
    NSLog(@"Add account");

    NSMutableArray * newAccounts    = [NSMutableArray arrayWithArray: accountsArray];
    AccountDetails * newAccount     = [[AccountDetails alloc] init];
    newAccount.removed              = NO;
    newAccount.modified             = YES;
    newAccount.vendorName           = nil;
    newAccount.vendorId             = nil;
    newAccount.accountInternalId    = nil;
    newAccount.accountUserName      = nil;
    newAccount.accountAccessToken   = nil;

    [newAccounts addObject: newAccount];
    
    // Update our array
    accountsArray = [NSArray arrayWithArray: newAccounts];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [accountsTableView reloadData];
        [accountsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: accountsArray.count - 1]
                       byExtendingSelection: NO];

        // Update our UI
        [self updateUI];
        
        // And make sure our progress is not animated.
        [loadVendorIdProgressIndicator stopAnimation: self];
        
        // Focus the display text field.
        [accountIDTextField becomeFirstResponder];
    });
}

- (IBAction) onLoadVendorId: (id) sender
{
    NSString * accountIdText = accountIDTextField.stringValue;
    NSString * accessTokenText  = accountAccessTokenTextField.stringValue;

    [accountsTableView setEnabled: NO];
    [loadVendorIdButton setEnabled: NO];
    [addRemoveAccountSegmenetedControl setEnabled: NO];
    
    [accountIDTextField setEnabled: NO];
    [accountAccessTokenTextField setEnabled: NO];
    
    [loadVendorIdProgressIndicator startAnimation: self];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.delegate beganLoadingVendorId];

        NSError * error = nil;
        AWiTunesConnectHelper * connectHelper = [[AWiTunesConnectHelper alloc] init];

        NSString * vendorName = nil;
        BOOL     loginSuccess = NO;

        NSNumber * vendorId =
            [connectHelper vendorIdWithUser: accountIdText
                                accessToken: accessTokenText
                                 vendorName: &vendorName
                               loginSuccess: &loginSuccess
                                      error: &error];

        if(nil != error)
        {
            [self.delegate accountsViewControllerHasError: error];
        } // End of we had an error

        if(nil == vendorId || [@(-1) isEqualToNumber: vendorId])
        {
            NSLog(@"Failed to get vendor id: %@.", error.localizedDescription);
            vendorId = nil;
        } // End of could not get vendor id
        else
        {
            NSLog(@"Got vendor id: %@", vendorId);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [loadVendorIdButton setEnabled: YES];
            [addRemoveAccountSegmenetedControl setEnabled: YES];
            [accountsTableView setEnabled: YES];

            [accountIDTextField setEnabled: YES];
            [accountAccessTokenTextField setEnabled: YES];

            [accountVendorIdTextField setStringValue: nil == vendorId ? @"" : [vendorId stringValue]];

            if(nil != vendorName && 0 != vendorName.length)
            {
                [accountVendorNameTextField setStringValue: vendorName];
            } // End of we have a vendorName

            [loadVendorIdProgressIndicator stopAnimation: self];

            [self onVendorIdChanged: self];
            [self onVendorNameChanged: self];
            [self.delegate endLoadingVendorId];
        });
    });
} // End of onLoadVendorId

- (void)controlTextDidChange:(NSNotification *)notification
{
    if(-1 == accountsTableView.selectedRow) return;

    if(notification.object == accountIDTextField)
    {
        [self onAppleIdChanged: notification.object];
    }
    else if(notification.object == accountAccessTokenTextField)
    {
        [self onAccessTokenChanged: notification.object];
    }
    else if(notification.object == accountVendorIdTextField)
    {
        [self onVendorIdChanged: notification.object];
    }
    else if(notification.object == accountVendorNameTextField)
    {
        [self onVendorNameChanged: notification.object];
    }
}

- (IBAction) onAppleIdChanged: (id) sender
{
    if(-1 == accountsTableView.selectedRow) return;

    AccountDetails * entry = accountsArray[accountsTableView.selectedRow];

    entry.accountUserName = accountIDTextField.stringValue;
    entry.modified        = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

- (IBAction) onAccessTokenChanged: (id) sender
{
    if(-1 == accountsTableView.selectedRow)
    {
        return;
    }

    AccountDetails * entry = accountsArray[accountsTableView.selectedRow];

    entry.accountAccessToken = accountAccessTokenTextField.stringValue;
    entry.modified        = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

- (IBAction) onVendorIdChanged: (id) sender
{
    if(-1 == accountsTableView.selectedRow) return;

    AccountDetails * entry = accountsArray[accountsTableView.selectedRow];

    NSNumber * vendorId =
        [NSNumber numberWithInteger: accountVendorIdTextField.stringValue.integerValue];

    entry.vendorId        = 0 == vendorId.integerValue ? nil : vendorId;
    entry.modified        = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

- (IBAction) onVendorNameChanged: (id) sender
{
    if(-1 == accountsTableView.selectedRow) return;

    AccountDetails * entry = accountsArray[accountsTableView.selectedRow];

    entry.vendorName = accountVendorNameTextField.stringValue;
    entry.modified   = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

- (void) updateUI
{
    BOOL canModify = -1 != accountsTableView.selectedRow;

    // Check if we are removing it. If we are, then we will disable the UI.
    if(canModify)
    {
        AccountDetails * entry = accountsArray[accountsTableView.selectedRow];
        if(entry.removed)
        {
            canModify = NO;
        }
    }

    // Enable/Disable UI
    [addRemoveAccountSegmenetedControl setEnabled: canModify
                                       forSegment: 1];

    [accountIDTextField setEnabled: canModify];
    [accountAccessTokenTextField setEnabled: canModify];
    [loadVendorIdButton setEnabled: canModify];

    if(
       [@"" isEqualToString: accountIDTextField.stringValue] ||
       [@"" isEqualToString: accountAccessTokenTextField.stringValue])
    {
        [loadVendorIdButton setEnabled: NO];
    } // End of any of the account info is invalid.

    if(-1 == accountsTableView.selectedRow)
    {
        [accountIDTextField setStringValue: @""];
        [accountAccessTokenTextField setStringValue: @""];
        [accountVendorIdTextField setStringValue: @""];
        [accountVendorNameTextField setStringValue: @""];
    }
    else
    {
        AccountDetails * entry = accountsArray[accountsTableView.selectedRow];

        [accountIDTextField setStringValue: 0 == entry.accountUserName.length ? @"" : entry.accountUserName];
        [accountAccessTokenTextField setStringValue: 0 == entry.accountAccessToken.length ? @"" : entry.accountAccessToken];
        [accountVendorIdTextField setStringValue: nil == entry.vendorId ? @"" : entry.vendorId.stringValue];
        [accountVendorNameTextField setStringValue: 0 == entry.vendorName.length ? @"" : entry.vendorName];
    } // End of else
} // End of updateUI

#pragma mark -
#pragma mark NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return accountsArray.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    AccountDetails * entry = accountsArray[row];

    if(NSOrderedSame == [@"AccountType" caseInsensitiveCompare: tableColumn.identifier])
    {
        return [NSImage imageNamed: @"AccountType-iTunesConnect"];
    }
    else if(NSOrderedSame == [@"AccountDisplayName" caseInsensitiveCompare: tableColumn.identifier])
    {
        NSString * displayString;

        if(entry.removed)
        {
            displayString = [NSString stringWithFormat: @"REMOVING %@",
                             entry.vendorName];
        }
        else
        {
            displayString = [NSString stringWithFormat: @"%@%@",
                                        entry.modified ? @"* " : @"",
                                        (nil == entry.vendorName || 0 == [entry.vendorName length ]) ? @"New Account" : entry.vendorName];
        }

        return displayString;
    } // End of accountDisplayName
    else
    {
        NSLog(@"Unknown value");
    }

    return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"Account selection changed (%ld).", accountsTableView.selectedRow);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
}

#pragma mark -
#pragma mark NSTextFieldDelegate

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)fieldEditor
doCommandBySelector:(SEL)commandSelector
{
    if(control != accountAccessTokenTextField)
    {
        return NO;
    } // End of we are not the access token textfield

    if (commandSelector == @selector(insertNewline:))
    {
        [self onLoadVendorId: nil];
        return NO;
    }

    return NO;
}

@end
