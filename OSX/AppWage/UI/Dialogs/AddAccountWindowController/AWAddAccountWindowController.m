//
//  AddAccountWindowController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWAddAccountWindowController.h"
#import "AWAccountHelper.h"
#import "AWAccount.h"
#import "AWApplicationListTreeViewController.h"

@interface AWAddAccountWindowController ()

@end

@implementation AWAddAccountWindowController

@synthesize accountIdTextField, vendorNameTextField;

- (id)init
{
    self = [super initWithWindowNibName: @"AWAddAccountWindowController"];
    if (self)
    {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction) onCancel: (id) sender
{
    [self endSheetWithReturnCode: NSModalResponseCancel];
}

- (IBAction) onAccept: (id) sender
{
    if(0 == vendorNameTextField.stringValue.length)
    {
        [[NSAlert alertWithMessageText: @"Vendor name must be entered."
                         defaultButton: @"OK"
                       alternateButton: nil
                           otherButton: nil
             informativeTextWithFormat: @"In order to add an account, the vendor name must be entered."]
         beginSheetModalForWindow: self.window
                    modalDelegate: nil
                   didEndSelector: nil
                      contextInfo: NULL];
        return;
    }

    // Add our vendor
    NSNumber * vendorId = [NSNumber numberWithInteger: [accountIdTextField.stringValue integerValue]];

    AccountDetails * accountDetails  = [[AccountDetails alloc] init];
    accountDetails.accountUserName   = nil;
    accountDetails.removed           = NO;
    accountDetails.vendorId          = vendorId;
    accountDetails.vendorName        = vendorNameTextField.stringValue;
    accountDetails.accountInternalId = [[NSProcessInfo processInfo] globallyUniqueString];

    [[AWAccountHelper sharedInstance] addAccountDetails: accountDetails];

    AWAccount * account = [[AWAccount alloc] init];
    account.internalAccountId = accountDetails.accountInternalId;
    account.accountType       = @(AccountType_iTunes);

    // Add our account
    [AWAccount addAccount: account];

    // Add our account details
    [[AWAccountHelper sharedInstance] addAccountDetails: accountDetails];

    // Make sure the account is expanded
    [AWApplicationListTreeViewController expandAccount: accountDetails.vendorName];

    [self endSheetWithReturnCode: NSModalResponseOK];
}

@end
