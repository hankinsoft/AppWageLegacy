//
//  AccountHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWAccountHelper.h"
#import <FXKeychain/FXKeychain.h>

#define kAccountsEntry               @"AccountsEntry"

#define kAccountInternalId           @"AccountInternalId"
#define kAccountUserName             @"AccountUserName"
#define kAccountAccessToken          @"AccountAccessToken"
#define kAccountVendorId             @"VendorId"
#define kAccountVendorName           @"VendorName"

@implementation AccountDetails

@synthesize accountInternalId;
@synthesize vendorId, vendorName;

@synthesize accountUserName, accountAccessToken;

@synthesize modified, removed;

- (id)init
{
    if ((self = [super init]))
    {
    }

    return self;
}

- (id) initWithDictionary: (NSDictionary*) dictionary
{
    if (self = [super init])
    {
        self.accountInternalId = dictionary[kAccountInternalId];
        self.vendorName = dictionary[kAccountVendorName];
        self.vendorId = dictionary[kAccountVendorId];
        self.accountUserName = dictionary[kAccountUserName];
        self.accountAccessToken = dictionary[kAccountAccessToken];

        self.modified = NO;
        self.removed  = NO;
    }

    return self;
} // End of initWithDicitonary:

-(id) initWithCoder: (NSCoder*) coder
{
    if (self = [super init])
    {
        self.accountInternalId = [coder decodeObjectOfClass: [NSString class]
                                                     forKey: kAccountInternalId];

        self.vendorName         = [coder decodeObjectOfClass: [NSString class]
                                                     forKey: kAccountVendorName];

        self.vendorId         = [coder decodeObjectOfClass: [NSNumber class]
                                                      forKey: kAccountVendorId];

        self.accountUserName = [coder decodeObjectOfClass: [NSString class]
                                                     forKey: kAccountUserName];

        self.accountAccessToken = [coder decodeObjectOfClass: [NSString class]
                                            forKey: kAccountAccessToken];

        self.modified = NO;
        self.removed  = NO;
    }

    return self;
}

-(void) encodeWithCoder: (NSCoder*) coder
{
    if(self.accountInternalId)
    {
        [coder encodeObject: self.accountInternalId forKey: kAccountInternalId];
    }

    if(self.vendorName)
    {
        [coder encodeObject: self.vendorName        forKey: kAccountVendorName];
    }

    if(self.vendorId)
    {
        [coder encodeObject: self.vendorId          forKey: kAccountVendorId];
    }

    if(self.accountUserName)
    {
        [coder encodeObject: self.accountUserName   forKey: kAccountUserName];
    }

    if(self.accountAccessToken)
    {
        [coder encodeObject: self.accountAccessToken   forKey: kAccountAccessToken];
    }
}

- (id) FXKeychain_propertyListRepresentation
{
    NSMutableDictionary * copy = [NSMutableDictionary dictionary];

    if(self.accountInternalId)
    {
        [copy setObject: self.accountInternalId
                 forKey: kAccountInternalId];
    }
    
    if(self.vendorName)
    {
        [copy setObject: self.vendorName
                 forKey: kAccountVendorName];
    }
    
    if(self.vendorId)
    {
        [copy setObject: self.vendorId
                 forKey: kAccountVendorId];
    }
    
    if(self.accountUserName)
    {
        [copy setObject: self.accountUserName
                 forKey: kAccountUserName];
    }

    if(self.accountAccessToken)
    {
        [copy setObject: self.accountAccessToken
                 forKey: kAccountAccessToken];
    }

    return copy;
}

- (id)copyWithZone: (NSZone *)zone
{
    AccountDetails * result = [[AccountDetails alloc] init];

    result.vendorName = [self.vendorName copyWithZone: zone];
    result.vendorId = [self.vendorId copyWithZone: zone];
    result.accountInternalId = [self.accountInternalId copyWithZone: zone];
    result.accountUserName = [self.accountUserName copyWithZone: zone];
    result.accountAccessToken = [self.accountAccessToken copyWithZone: zone];
    result.modified = self.modified;
    result.removed = self.removed;

    return result;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end

@interface AWAccountHelper()
{
    NSObject * lockObject;
}
@end

@implementation AWAccountHelper

+(AWAccountHelper*) sharedInstance
{
    static dispatch_once_t pred;
    static AWAccountHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWAccountHelper alloc] init];

        accounts = [NSMutableArray array];

        // Loaded as
        NSArray * tempArray = [[FXKeychain defaultKeychain] objectForKey: kAccountsEntry];
        
        for(NSDictionary * accountDictionary in tempArray)
        {
            AccountDetails * accountDetails =
                [[AccountDetails alloc] initWithDictionary: accountDictionary];

            [accounts addObject: accountDetails];
        } // End of accountsDetails
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        lockObject = [[NSObject alloc] init];
    }

    return self;
}

static NSMutableArray * accounts = nil;

- (void) removeAll
{
    @synchronized(lockObject)
    {
        [[FXKeychain defaultKeychain] setObject: nil
                                         forKey: kAccountsEntry];

        // Remove all
        [accounts removeAllObjects];
    } // End of locked
}

- (NSArray*) allAccounts
{
    return accounts;
} // End of allAccounts

- (NSUInteger) accountsCount
{
    @synchronized(lockObject)
    {
        return [[self allAccounts] count];
    } // End of synchronized
} // End of accountsCount

- (void) updateAccount: (AccountDetails*) accountDetails
{
    @synchronized(lockObject)
    {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat: @"%K =[cd] %@",
                                         @"accountInternalId", accountDetails.accountInternalId];

        NSDictionary * existingAccount = [accounts filteredArrayUsingPredicate: filterPredicate][0];

        // Remove our account
        [accounts removeObject: existingAccount];

        accountDetails.modified = NO;

        // Add the new account
        [accounts addObject: accountDetails];

        // Save the keychain
        [[FXKeychain defaultKeychain] setObject: accounts
                                         forKey: kAccountsEntry];
    } // End of synchronized
}

- (void) addAccountDetails: (AccountDetails*) accountDetails
{
    @synchronized(lockObject)
    {
        accountDetails.modified = NO;
        accountDetails.removed  = NO;

        // Add our account
        [accounts addObject: accountDetails];

        // Save the keychain
        [[FXKeychain defaultKeychain] setObject: accounts
                                         forKey: kAccountsEntry];
    } // End of synchronized
} // End of addAccountDetails

- (void) removeAccountDetails: (AccountDetails*) accountDetails
{
    @synchronized(lockObject)
    {
        NSPredicate * filterPredicate =
            [NSPredicate predicateWithFormat: @"%K =[cd] %@",
                @"accountInternalId", accountDetails.accountInternalId];

        NSArray * results = [accounts filteredArrayUsingPredicate: filterPredicate];
        AccountDetails * existingAccount = [results firstObject];

        if(nil == existingAccount)
        {
            return;
        } // End of we do not have an account

        // Remove our account
        [accounts removeObject: existingAccount];

        // Save the keychain
        [[FXKeychain defaultKeychain] setObject: accounts
                                         forKey: kAccountsEntry];
    } // End of synchronized
} // End of removeAccountDetails

- (AccountDetails*) accountDetailsForInternalAccountId: (NSString*) accountId
{
    @synchronized(lockObject)
    {
        if(nil == accounts)
        {
            return nil;
        } // End of no accounts

        NSArray * filteredAccounts =
            [accounts filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"%K LIKE[cd] %@", @"accountInternalId", accountId]];

        if(0 == filteredAccounts.count)
        {
            return nil;
        }

        return filteredAccounts[0];
    } // End of synchronized
} // End of accountDetailsForAccountId

- (AccountDetails*) accountDetailsForVendorId: (NSNumber*) vendorId
{
    @synchronized(lockObject)
    {
        if(nil == accounts)
        {
            return nil;
        }

        NSPredicate * predicate =
            [NSPredicate predicateWithFormat: @"%K = %@", @"vendorId", vendorId];

        NSArray * filteredAccounts = [accounts filteredArrayUsingPredicate: predicate];

        if(0 == filteredAccounts.count)
        {
            return nil;
        } // End of no filteredAccounts

        return filteredAccounts[0];
    } // End of synchronized
}

- (AccountDetails*) accountDetailsForVendorAccountName: (NSString*) vendorName
{
    @synchronized(lockObject)
    {
        if(nil == accounts)
        {
            return nil;
        }

        NSPredicate * predicate =
            [NSPredicate predicateWithFormat: @"%K LIKE[cd] %@",
                @"vendorName", vendorName];

        NSArray * filteredAccounts = [accounts filteredArrayUsingPredicate: predicate];
        
        if(0 == filteredAccounts.count)
        {
            return nil;
        }

        return filteredAccounts[0];
    } // End of synchronized
} // End of accountDetailsForVendorAccountName:

@end
