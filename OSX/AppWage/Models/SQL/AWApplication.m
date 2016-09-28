//
//  Application.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWApplication.h"
#import "AWAccount.h"
#import "AWApplicationCollection.h"
#import "AWProduct.h"
#import "AWApplicationFinder.h"

@implementation AWApplication

NSMutableArray * _allApplications = nil;

+ (void) initialize
{
    _allApplications = [NSMutableArray array];
} // End of initialize

+ (void) initializeAllApplications
{
    @synchronized(self)
    {
        NSMutableArray * applicationsTemp = [[NSMutableArray alloc] init];
        
        [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database)
         {
             FMResultSet * results = [database executeQuery: @"SELECT *, IFNULL((SELECT GROUP_CONCAT(genreId) FROM applicationGenre WHERE applicationId = application.applicationId), '') AS genreIds FROM application"];

             while([results next])
             {
                 AWApplication * application   = [[AWApplication alloc] init];
                 application.applicationId   = [results objectForColumnName: @"applicationId"];
                 application.applicationType = [results objectForColumnName: @"applicationType"];
                 application.hiddenByUser    = [results objectForColumnName: @"hiddenByUser"];
                 application.name            = [results stringForColumn: @"name"];
                 application.publisher       = [results stringForColumn: @"publisher"];
                 application.shouldCollectRanks = [results objectForColumnName: @"shouldCollectRanks"];
                 application.shouldCollectReviews = [results objectForColumnName: @"shouldCollectReviews"];
                 application.internalAccountId = [results objectForColumnName: @"internalAccountId"];

                 NSString * genreIdString   = [results objectForColumnName: @"genreIds"];
                 NSArray * genreIdArray = [genreIdString componentsSeparatedByString: @","];
                 
                 NSMutableSet * genereIds = [NSMutableSet set];
                 [genreIdArray enumerateObjectsUsingBlock: ^(NSString * genreString, NSUInteger index, BOOL * stop)
                  {
                      [genereIds addObject: [NSNumber numberWithInteger: genreString.integerValue]];
                  }];

                 application.genreIds = genereIds.copy;

                 if([NSNull null] == (id)application.internalAccountId)
                 {
                     application.internalAccountId = nil;
                 }

                 [applicationsTemp addObject: application];
             } // End of results loop
         }];

        _allApplications = applicationsTemp;
    } // End of @synchronized
} // End of initializeAllApplications

+ (NSArray*) allApplications
{
    @synchronized(self)
    {
        return _allApplications;
    } // End of @synchronized
} // End of allApplications

+ (AWApplication*) applicationByApplicationId: (NSNumber*) applicationId
{
    @synchronized(self)
    {
        NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"applicationId = %@", applicationId];

        NSArray * filteredApplications = [_allApplications filteredArrayUsingPredicate: searchPredicate];
        return filteredApplications.firstObject;
    } // End of @synchronized
} // End of applicationByApplicationId

+ (NSArray*) applicationsByInternalAccountId: (NSString*) internalAccountId
{
    @synchronized(self)
    {
        NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"internalAccountId = %@", internalAccountId];

        NSArray * filteredApplications = [_allApplications filteredArrayUsingPredicate: searchPredicate];
        return filteredApplications;
    } // End of @synchronized
}

+ (void) addApplication: (AWApplication*) application
{
    @synchronized(self)
    {
        [_allApplications addObject: application];
    } // End of synchronized

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appwageDatabase, BOOL * rollback)
     {
         NSString * insertQuery = [NSString stringWithFormat: @"INSERT INTO application (applicationId, applicationType, name, publisher, internalAccountId) VALUES (?,?,?,?,?)"];

         NSArray * arguments = @[
             application.applicationId,
             application.applicationType,
             application.name,
             application.publisher,
             nil == application.internalAccountId ? [NSNull null] : application.internalAccountId
         ];

         [appwageDatabase executeUpdate: insertQuery
                   withArgumentsInArray: arguments];

         [application.genreIds enumerateObjectsUsingBlock: ^(NSNumber * genreId, BOOL * stop)
          {
             [appwageDatabase executeUpdate: @"INSERT OR IGNORE INTO applicationGenre (applicationId, genreId) VALUES(?, ?)"
                       withArgumentsInArray: @[application.applicationId, genreId]];
          }];
     }];
} // End of addApplication

+ (AWApplication*) createFromApplicationEntry: (AWApplicationFinderEntry*) entry
{
    AWApplication * application = [[AWApplication alloc] init];
    application.applicationId = entry.applicationId;
    application.publisher = entry.applicationDeveloper;
    application.name = entry.applicationName;
    application.applicationType = entry.applicationType;

    // By default we want to download reviews and rankings
    application.shouldCollectRanks   = [NSNumber numberWithBool: YES];
    application.shouldCollectReviews = [NSNumber numberWithBool: YES];
    
    // Set our genreIds
    application.genreIds = [NSSet setWithArray: entry.genreIds];
    
    return application;
} // End of createFromApplicationEntry

- (NSString*) description
{
    return [NSString stringWithFormat: @"Application %@ (%@).", self.name, self.applicationId];
}

@end
