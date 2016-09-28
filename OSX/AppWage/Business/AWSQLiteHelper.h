//
//  SqliteHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-23.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface AWSQLiteHelper : NSObject

+ (void) initializeSQLite;

+ (NSString*) rootDatabasePath;

+ (FMDatabaseQueue*) appWageDatabaseQueue;
+ (FMDatabaseQueue*) salesDatabaseQueue;
+ (FMDatabaseQueue*) rankingDatabaseQueue;
+ (FMDatabaseQueue*) reviewDatabaseQueue;

@end
