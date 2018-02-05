//
//  AWApplicationKeyword.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWApplicationKeyword.h"

@implementation AWApplicationKeyword

+ (NSArray<NSString*>*) keywordsForApplicationId: (NSNumber*) applicationId
{
    NSMutableSet<NSString*>* outResults = [[NSMutableSet alloc] init];

    [[AWSQLiteHelper keywordsDatabaseQueue] inDatabase: ^(FMDatabase * database)
     {
         FMResultSet * results =
            [database executeQuery: @"SELECT keyword FROM applicationKeyword WHERE applicationId IN (?)"
              withArgumentsInArray: @[applicationId]];

         while([results next])
         {
             [outResults addObject: [results stringForColumn: @"keyword"]];
         } // End of results loop
     }];

    return outResults.allObjects;
} // End of keywordsForApplicationId:

+ (NSArray<AWApplicationKeyword*>*) entriesForApplicationId: (NSNumber*) applicationId
{
    NSMutableSet<AWApplicationKeyword*>* outResults = [[NSMutableSet alloc] init];

    [[AWSQLiteHelper keywordsDatabaseQueue] inDatabase: ^(FMDatabase * database)
     {
         FMResultSet * results =
            [database executeQuery: @"SELECT applicationKeywordId, keyword FROM applicationKeyword WHERE applicationId IN (?)"
              withArgumentsInArray: @[applicationId]];

         while([results next])
         {
             AWApplicationKeyword * keyword = [[AWApplicationKeyword alloc] init];
             keyword.applicationKeywordId = @([results intForColumn: @"applicationKeywordId"]);
             keyword.applicationId = applicationId;
             keyword.keyword = [results stringForColumn: @"keyword"];

             [outResults addObject: keyword];
         } // End of results loop
     }];

    return outResults.allObjects;
}

+ (void) setKeywords: (NSArray<NSString*>*) keywords
    forApplicationId: (NSNumber*) applicationId
{
    [[AWSQLiteHelper keywordsDatabaseQueue] inDatabase: ^(FMDatabase * database)
     {
         for(NSString * keyword in keywords)
         {
             [database executeUpdate: @"INSERT INTO applicationKeyword(applicationId, keyword) VALUES(?,?)"
               withArgumentsInArray: @[applicationId, keyword]];
         }
        
     }];
} // End of setKeywords:forApplicationId:

@end
