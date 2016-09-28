//
//  Account.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    AccountType_iTunes
} AccountType;

@interface AWAccount : NSObject

+ (void) initializeAllAccounts;
+ (NSArray<AWAccount*>*) allAccounts;
+ (AWAccount*) accountByInternalAccountId: (NSString*) internalAccountId;
+ (void) addAccount: (AWAccount*) account;

@property (nonatomic, retain) NSString * internalAccountId;
@property (nonatomic, retain) NSNumber * accountType;

@end
