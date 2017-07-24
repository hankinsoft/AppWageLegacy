//
//  InitialSetupWizard.m
//  AppWage
//
//  Created by Kyle Hankinson on 2015-01-23.
//  Copyright (c) 2015 Hankinsoft. All rights reserved.
//

#import "AWInitialSetupWizard.h"
#import <QuartzCore/CoreAnimation.h>
#import "NSString+EmailValidation.h"
#import "AWiTunesConnectHelper.h"

@interface AWInitialSetupWizard ()
{
    IBOutlet NSView             * contentView;

    IBOutlet NSButton           * previousButton;
    IBOutlet NSButton           * nextButton;

    
    
    
    IBOutlet NSView             * welcomeView;
    IBOutlet NSTextView         * welcomeTextView;

    
    
    

    IBOutlet NSView                 * iTunesAccountView;
    IBOutlet NSTextField            * iTunesAccountTextField;
    IBOutlet NSSecureTextField      * iTunesAccessTokenTextField;
    IBOutlet NSTextField            * iTunesAccountValidatingField;
    IBOutlet NSProgressIndicator    * iTunesAccountValidatingProgressIndicator;

    
    IBOutlet NSView                 * iTunesAccountDetailsView;




    IBOutlet NSView                 * emailConfigurationView;
    IBOutlet NSBox                  * emailConfigurationBox;

    
    
    
    IBOutlet NSView                 * lastView;
}

@property(nonatomic,retain) IBOutlet NSView * currentView;

@end

@implementation AWInitialSetupWizard
{
    CATransition *transition;

    // iTunes Account Details
    NSMutableDictionary * accountDetailsLookup;
    NSString            * accountVendorName;
    NSNumber            * accountVendorId;
}

@synthesize currentView;

- (id)init
{
    self = [super initWithWindowNibName: @"AWInitialSetupWizard"];
    if (self)
    {
        // Initialization code here.
    }
    return self;
}

- (void) loadWindow
{
    [super loadWindow];

    // Set our lastView
    lastView = emailConfigurationView;

    // Clear our border
    [emailConfigurationBox setBorderType: NSNoBorder];
    [emailConfigurationBox setHidden: YES];

    accountDetailsLookup = [NSMutableDictionary dictionary];

    [contentView setWantsLayer:YES];
    [contentView addSubview: [self currentView]];

    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];

    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [contentView setAnimations: ani];

    [self initializeWelcomeTextView];
} // End of loadWindow

- (void) initializeWelcomeTextView
{
    NSMutableString * welcomeText = [NSMutableString string];

    [welcomeText appendString: @"Welcome to AppWage\r\n"];

    [welcomeText appendString: @"This wizard will guide you through the process of configuring AppWage to download Sales Reports, Rankings and Reviews. You may cancel at any time and manually configure settings yourself."];

    [welcomeTextView setString: welcomeText];

    [welcomeTextView.textStorage addAttribute: NSFontAttributeName
                                        value: [NSFont boldSystemFontOfSize:12.0f]
                                        range: NSMakeRange(0, [@"Welcome to AppWage" length])];
}

- (void)setCurrentView: (NSView*) newView
{
    if (!currentView)
    {
        currentView = newView;
        return;
    } // End of we have no currentView

    // If we are at the last view, then we will change our button.
    if(newView == lastView)
    {
        [nextButton setTitle: @"Finish"];
    } // End of last view

    [NSAnimationContext beginGrouping];

    [[NSAnimationContext currentContext] setCompletionHandler: ^{
        [previousButton setEnabled: YES];
        [nextButton setEnabled: YES];

        // Make our newView the first responder
        [newView becomeFirstResponder];

        if(currentView == welcomeView)
        {
            [previousButton setEnabled: NO];
        }
        else if(currentView == iTunesAccountView)
        {
            // Focus the account text field
            [iTunesAccountTextField becomeFirstResponder];
        }
    }];

    [[contentView animator] replaceSubview: currentView
                                      with: newView];

    currentView = newView;

    [NSAnimationContext endGrouping];
}

- (IBAction) onCancel: (id) sender
{
    [self endSheetWithReturnCode: NSModalResponseCancel];
} // End of onCancel

- (IBAction) onNext: (id)sender
{
    [transition setSubtype: kCATransitionFromRight];

    // Default the next button
    [nextButton setTitle: @"Next"];

    NSView * nextView = nil;

    if(self.currentView == welcomeView)
    {
        nextView = iTunesAccountView;
    } // End of we are the welcomeView
    else if(self.currentView == iTunesAccountView)
    {
        if(![self validateITunesAccount])
        {
            return;
        } // End of no validateITunesAccount

        // Load our account details
        [self loadITunesAccountDetails];
    } // End of we are the iTunesAccount view
    else if(self.currentView == lastView)
    {
        // Save our details
        [self endSheetWithReturnCode: NSModalResponseOK];
    } // End of last view

    if(nil == nextView)
    {
        return;
    } // End of no nextView

    [self setCurrentView: nextView];
} // End of onNext

- (IBAction) onPrevious: (id)sender
{
    [transition setSubtype: kCATransitionFromLeft];

    // Default the next button
    [nextButton setTitle: @"Next"];

    NSView * previousView = nil;
    if(self.currentView == iTunesAccountView)
    {
        previousView = welcomeView;
    }
    else if(self.currentView == emailConfigurationView)
    {
        previousView = iTunesAccountView;
    }
    else if(self.currentView == iTunesAccountDetailsView)
    {
        previousView = iTunesAccountView;
    }

    if(nil == previousView)
    {
        return;
    } // End of no nextView

    [self setCurrentView: previousView];
} // End of onPrevious

- (IBAction) onToggleEmailEnabled: (id) sender
{
    NSButton * comboBox = (NSButton*) sender;

    // Hide email configuration if we have it disabled.
    [emailConfigurationBox setHidden: comboBox.state == NSOffState];
}

#pragma mark -
#pragma mark Misc

- (void) loadITunesAccountDetails
{
    NSString * lookup = [NSString stringWithFormat: @"%@-%@",
                         iTunesAccountTextField.stringValue,
                         iTunesAccessTokenTextField.stringValue];
    
    __block NSNumber * vendorId     = nil;
    __block NSError  * error        = nil;
    __block NSString * vendorName   = nil;
    __block BOOL     loginSuccess   = NO;

    // Get our entry
    NSDictionary * entry = accountDetailsLookup[lookup];

    if(nil == entry)
    {
        [iTunesAccountValidatingField setHidden: NO];
        [iTunesAccountValidatingProgressIndicator startAnimation: self];
        [iTunesAccountValidatingProgressIndicator setHidden: NO];
        
        [nextButton setEnabled: NO];
        [previousButton setEnabled: NO];
        
        [iTunesAccountTextField setEnabled: NO];
        [iTunesAccessTokenTextField setEnabled: NO];
    } // End of we did not have an entry

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(nil == entry)
        {
            AWiTunesConnectHelper * helper = [[AWiTunesConnectHelper alloc] init];

            vendorId = [helper vendorIdWithUser: iTunesAccountTextField.stringValue
                                    accessToken: iTunesAccessTokenTextField.stringValue
                                     vendorName: &vendorName
                                   loginSuccess: &loginSuccess
                                          error: &error];
        } // End of we do not have an entry
        else
        {
            vendorId   = entry[@"vendorId"];
            vendorName = entry[@"vendorName"];
        } // End of we do have an entry

        dispatch_async(dispatch_get_main_queue(), ^{
            NSView * nextView = nil;

            // If we have no error, then validate that our vendorId
            // and vendorName have been set properly. If they have not been set
            // then we will add an error, displaying it shortly.
            if(nil != error &&
                    (nil == vendorId || [@(-1) isEqualToNumber: vendorId] || 0 == vendorName.length))
            {
                error = [NSError errorWithDomain: AWErrorDomain
                                            code: 0
                                        userInfo: @{
                                                    NSLocalizedDescriptionKey: @"Failed to validate account details."
                                                    }];
            }
            else if(nil == error)
            {
                nextView = emailConfigurationView;

                accountVendorName = vendorName;
                accountVendorId   = vendorId;

                // Set our accountDetailsLookup
                accountDetailsLookup[lookup] = @{
                                                 @"vendorId": vendorId,
                                                 @"vendorName": vendorName
                                                 };
            } // End of we had no error

            // If we have an error then display it
            if(nil != error)
            {
                if(!loginSuccess)
                {
                    NSAlert * alert = [NSAlert alertWithError: error];
                    [alert beginSheetModalForWindow: self.window
                                      modalDelegate: nil
                                     didEndSelector: nil
                                        contextInfo: NULL];
                }
                else
                {
                    nextView = iTunesAccountDetailsView;
                }
            } // End of we had an error

            [iTunesAccountValidatingField setHidden: YES];
            [iTunesAccountValidatingProgressIndicator setHidden: YES];

            [nextButton setEnabled: YES];
            [previousButton setEnabled: YES];

            [iTunesAccountTextField setEnabled: YES];
            [iTunesAccessTokenTextField setEnabled: YES];

            if(nil != nextView)
            {
                // Set our next view
                [transition setSubtype: kCATransitionFromRight];
                [self setCurrentView: nextView];
            } // End of we did not have an error
        });
    });
}

#pragma mark -
#pragma mark Validation

- (BOOL) validateITunesAccount
{
    if(0 == iTunesAccountTextField.stringValue.length ||
       0 == iTunesAccessTokenTextField.stringValue.length)
    {
        NSError * error = [NSError errorWithDomain: AWErrorDomain
                                              code: 0
                                          userInfo: @{
                                                      NSLocalizedDescriptionKey: @"Invalid account or access token."
                                                      }];

        NSAlert * alert = [NSAlert alertWithError: error];
        [alert beginSheetModalForWindow: self.window
                          modalDelegate: nil
                         didEndSelector: nil
                            contextInfo: NULL];
        
        return NO;
    } // End of no credentials

    if(![iTunesAccountTextField.stringValue isValidEmail])
    {
        NSError * error = [NSError errorWithDomain: AWErrorDomain
                                              code: 0
                                          userInfo: @{
                                                      NSLocalizedDescriptionKey: @"Invalid account (account must be a valid email address)."
                                                      }];

        NSAlert * alert = [NSAlert alertWithError: error];
        [alert beginSheetModalForWindow: self.window
                          modalDelegate: nil
                         didEndSelector: nil
                            contextInfo: NULL];
        
        return NO;
    } // End of isValidEmail

    return YES;
} // End of validateITunesAccount

#pragma mark -
#pragma mark NSTextView command

- (BOOL)control: (NSControl*)control
       textView: (NSTextView*)textView
doCommandBySelector: (SEL)commandSelector
{
    if (commandSelector == @selector(insertTab:))
    {
        if(control == iTunesAccountTextField)
        {
            [iTunesAccessTokenTextField becomeFirstResponder];
            return YES;
        }
    } // End of insertTab
    else if(commandSelector == @selector(insertNewline:))
    {
        if(control == iTunesAccessTokenTextField)
        {
            [self onNext: self];
            return YES;
        }
    } // End of insertNewline

    return NO;
}

@end
