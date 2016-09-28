//
//  SqliteHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-23.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSQLiteHelper.h"
#import "NSFileManager+Support.h"

@implementation AWSQLiteHelper

static FMDatabaseQueue * _appWageDatabaseQueue;
static FMDatabaseQueue * _salesDatabaseQueue;
static FMDatabaseQueue * _rankingDatabaseQueue;
static FMDatabaseQueue * _reviewDatabaseQueue;

+ (void) initializeSQLite
{
    NSString * rootPath = [self rootDatabasePath];

    // Create our root database path if it does not exist.
    if(![[NSFileManager defaultManager] fileExistsAtPath: rootPath
                                             isDirectory: NULL])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath: rootPath
                                  withIntermediateDirectories: YES
                                                   attributes: NULL
                                                        error: NULL];
    } // End of create root database folder if it does not exist.

    NSString * appWageDatabasePath = [rootPath stringByAppendingPathComponent: @"appwage.sqlite3"];
    NSString * rankingDatabasePath = [rootPath stringByAppendingPathComponent: @"ranking.sqlite3"];
    NSString * reviewsDatabasePath = [rootPath stringByAppendingPathComponent: @"reviews.sqlite3"];
    NSString * salesDatabasePath   = [rootPath stringByAppendingPathComponent: @"sales.sqlite3"];

    _appWageDatabaseQueue = [self initializeDatabaseWithPath: appWageDatabasePath
                                                resourceName: @"AppWageDatabase"];

    _rankingDatabaseQueue = [self initializeDatabaseWithPath: rankingDatabasePath
                                                resourceName: @"RankingDatabase"];

    _reviewDatabaseQueue  = [self initializeDatabaseWithPath: reviewsDatabasePath
                                                resourceName: @"ReviewDatabase"];

    _salesDatabaseQueue  = [self initializeDatabaseWithPath: salesDatabasePath
                                                resourceName: @"SalesDatabase"];
} // End of initialize

+ (FMDatabaseQueue*) initializeDatabaseWithPath: (NSString*) databasePath
                                   resourceName: (NSString*) resourceName
{
    MachTimer * machTimer = [MachTimer startTimer];

    // Check if our database exists
    // BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath: databasePath];

    FMDatabaseQueue * databaseQueue = [FMDatabaseQueue databaseQueueWithPath: databasePath];

    [databaseQueue inDatabase: ^(FMDatabase * database) {
        NSString * ratingsCreationScriptPath =
            [[NSBundle mainBundle] pathForResource: resourceName
                                            ofType: @"sql"];

        NSError * error = nil;
        NSString * ratingsCreationScript =
            [NSString stringWithContentsOfFile: ratingsCreationScriptPath
                                  usedEncoding: NULL
                                         error: &error];

        if(nil == error)
        {
            BOOL result =
                [database executeStatements: ratingsCreationScript];

            if(result)
            {
                [database executeStatements: @"PRAGMA journal_mode = WAL"];
            }
            else
            {
                NSLog(@"Failed to run creation script.");
            } // End of failed to run creation script

            NSLog(@"Creation script result: %hhd", result);
        } // End of we had an error
        else
        {
            NSLog(@"Failed to initialize database with resource name %@.",
                  resourceName);
        }
    }];

    NSLog(@"Database queue %@ initialization took %0.2f seconds.", resourceName, machTimer.elapsedSeconds);

    return databaseQueue;
}

+ (NSString*) rootDatabasePath
{
    NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
    path = [path stringByAppendingPathComponent: @"database"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;

    if(![fileManager fileExistsAtPath: path
                          isDirectory: &isDirectory])
    {
        [fileManager createDirectoryAtPath: path
               withIntermediateDirectories: YES
                                attributes: nil
                                     error: NULL];
    } // End of folder did not exist

    return path;
} // End of rootDatabasePath

+ (FMDatabaseQueue*) appWageDatabaseQueue
{
    return _appWageDatabaseQueue;
} // End of appWageDatabaseQueue

+ (FMDatabaseQueue*) salesDatabaseQueue
{
    return _salesDatabaseQueue;
} // End of salesDatabaseQueue

+ (FMDatabaseQueue*) rankingDatabaseQueue
{
    return _rankingDatabaseQueue;
} // End of rankingDatabaseQueue

+ (FMDatabaseQueue*) reviewDatabaseQueue
{
    return _reviewDatabaseQueue;
} // End of reviewDatabaseQueue

@end
