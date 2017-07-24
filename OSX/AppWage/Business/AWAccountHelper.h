//
//  AccountHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountDetails : NSObject<NSSecureCoding>
{
    
}

+ (BOOL)supportsSecureCoding;

- (id) initWithDictionary: (NSDictionary*) dictionary;

@property(nonatomic,copy)   NSString    * accountInternalId;

@property(nonatomic,copy)   NSNumber    * vendorId;
@property(nonatomic,copy)   NSString    * vendorName;

@property(nonatomic,copy)   NSString    * accountUserName;
@property(nonatomic,copy)   NSString    * accountAccessToken;

@property(nonatomic,assign) BOOL        modified;
@property(nonatomic,assign) BOOL        removed;

@end

@interface AWAccountHelper : NSObject

+ (AWAccountHelper*) sharedInstance;

// Misc
- (NSArray<AccountDetails*>*) allAccounts;
- (NSUInteger) accountsCount;

// Add/Remove/Update
- (void) addAccountDetails: (AccountDetails*) accountDetails;
- (void) updateAccount: (AccountDetails*) accountDetails;
- (void) removeAccountDetails: (AccountDetails*) accountDetails;

// Lookups
- (AccountDetails*) accountDetailsForInternalAccountId: (NSString*) accountId;
- (AccountDetails*) accountDetailsForVendorAccountName: (NSString*) accountName;
- (AccountDetails*) accountDetailsForVendorId: (NSNumber*) vendorId;

- (void) removeAll;

@end
