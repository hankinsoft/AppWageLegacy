//
//  Account.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWAccount.h"
#import "AWApplication.h"


@implementation AWAccount

@synthesize internalAccountId, accountType;

NSMutableArray         * _allAccounts;

+ (void) initialize
{
    _allAccounts = @[].mutableCopy;
} // End of initialize

+ (void) initializeAllAccounts
{
    @synchronized(self)
    {
        NSMutableArray * accountsTemp = [[NSMutableArray alloc] init];

        [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database)
         {
             FMResultSet * results = [database executeQuery: @"SELECT * FROM account"];
             while([results next])
             {
                 AWAccount * account = [[AWAccount alloc] init];
                 account.internalAccountId = [results stringForColumn: @"internalAccountId"];
                 account.accountType       = [results objectForColumnName: @"accountType"];
                 
                 if([NSNull null] == (id)account.internalAccountId)
                 {
                     account.internalAccountId = nil;
                 }

                 [accountsTemp addObject: account];
             } // End of results loop
         }];

        _allAccounts = accountsTemp;
    } // End of @synchronized
}

+ (NSArray*) allAccounts
{
    @synchronized(self)
    {
        return _allAccounts;
    } // End of @synchronized
} // End of allAccounts

+ (AWAccount*) accountByInternalAccountId: (NSString*) internalAccountId
{
    @synchronized(self)
    {
        if(0 == _allAccounts.count)
        {
            return nil;
        } // End of no accounts

        NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"internalAccountId LIKE[cd] %@", internalAccountId];

        NSArray * filteredAccounts = [_allAccounts filteredArrayUsingPredicate: searchPredicate];
        return filteredAccounts.firstObject;
    } // End of @synchronized
} // End of accountByInternalAccountId

+ (void) addAccount: (AWAccount*) account
{
    @synchronized(self)
    {
        [_allAccounts addObject: account];
    } // End of synchronized

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction:
     ^(FMDatabase * appwageDatabase, BOOL * rollback)
     {
         NSString * insertQuery = [NSString stringWithFormat: @"INSERT INTO account (internalAccountId, accountType) VALUES (?,?)"];

         NSArray * arguments = @[
             account.internalAccountId,
             account.accountType
         ]; // End of arguments

         [appwageDatabase executeUpdate: insertQuery
                   withArgumentsInArray: arguments];
     }];
} // End of addAccount

@end
