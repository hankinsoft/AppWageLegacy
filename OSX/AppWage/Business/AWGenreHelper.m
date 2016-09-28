//
//  GenreHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/2/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWGenreHelper.h"
#import "AWGenre.h"
#import "AWApplication.h"
#import "AWCountry.h"

@implementation AWGenreHelper

NSRegularExpression * urlGenreIdRegularExpression = nil;

+ (void) initialize
{
    
} // End of initialize

+ (NSArray*) updateGenresFromFile: (NSString*) targetFile
                        genreType: (NSNumber*) genreType
{
    NSData * genreData = [NSData dataWithContentsOfFile: targetFile];

    NSAssert(nil != genreData, @"Genre data cannot be null.");

    NSError __autoreleasing * error = nil;
    NSArray * genresArray = [NSJSONSerialization JSONObjectWithData: genreData
                                                            options: kNilOptions
                                                              error: &error];


    __block NSMutableArray * genres = [NSMutableArray array];

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appWageDatabase, BOOL * rollback)
     {
         [genresArray enumerateObjectsUsingBlock: ^(NSDictionary * genreEntry, NSUInteger index, BOOL * stop)
          {
              // Process the entry
              AWGenre * genre =
                [self processGenreEntry: genreEntry
                              genreType: genreType
                             inDatabase: appWageDatabase];

              [genres addObject: genre];
          }];
     }];

    return genres.copy;
} // End of updateGenresFromFile

+ (AWGenre*) processGenreEntry: (NSDictionary*) genreEntry
                     genreType: (NSNumber*) genreType
                    inDatabase: (FMDatabase*) database
{
//    NSLog(@"Want to process genre entry: %@", [genreEntry allKeys]);

    // Get our name
    NSString * genreName    = genreEntry[@"Name"];
    NSNumber * genreId      = genreEntry[@"GenreId"];
    NSArray  * chartEntries = genreEntry[@"Charts"];
    id parentGenreId        = genreEntry[@"ParentGenreId"];

    NSString * query = [NSString stringWithFormat: @"REPLACE INTO genre (genreId,genreType,parentGenreId,name) VALUES(?,?,?,?)"];

    [database executeUpdate: query withArgumentsInArray: @[
        genreId,
        genreName,
        genreType,
        parentGenreId]];

    AWGenre * genre       = [[AWGenre alloc] init];
    genre.genreId       = genreId;
    genre.name          = genreName;
    genre.parentGenreId = parentGenreId;

    // Enumerate our chart entries.
    NSMutableSet * genreCharts = [NSMutableSet set];

    [chartEntries enumerateObjectsUsingBlock: ^(NSDictionary * chartEntry, NSUInteger chartIndex, BOOL * stop)
     {
         NSNumber * genreChartId = chartEntry[@"ChartId"];
         NSString * chartName    = chartEntry[@"Name"];;
         NSString * chartQuery   = [NSString stringWithFormat: @"REPLACE INTO genreChart (genreChartId,genreId,baseURL,name) VALUES(?,?,?,?)"];

         [database executeUpdate: chartQuery
            withArgumentsInArray: @[
                genreChartId,
                genreId,
                chartEntry[@"BaseUrl"],
                chartName]];

         AWGenreChart * chart = [[AWGenreChart alloc] init];
         chart.chartId = genreChartId;
         chart.name    = chartName;
         chart.baseUrl = chartEntry[@"BaseUrl"];

         // Add our chart entry
         [genreCharts addObject: chart];
     }];

    // Set our charts
    genre.charts = genreCharts.copy;

    return genre;
} // End of processGenreEntry

+ (NSArray*) chartsForApplicationIds: (NSArray*) applicationIds
                           countries: (NSArray*) countries
{
    NSMutableArray * results = [NSMutableArray array];

    NSString * queryToExecute =
        [NSString stringWithFormat: @"SELECT DISTINCT genreChartId, genreChart.genreId, countryCode, countryId, baseURL FROM genreChart INNER JOIN applicationGenre ON genreChart.genreId = applicationGenre.genreId INNER JOIN application ON application.applicationId = applicationGenre.applicationId, country WHERE country.shouldCollectRanks = 1 AND application.applicationId IN (%@)", [applicationIds componentsJoinedByString: @","]];

    [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * appwageDatabase)
     {
         FMResultSet * resultSet = [appwageDatabase executeQuery: queryToExecute];

         while([resultSet next])
         {
             NSString * rankURL = [AWGenreHelper chartUrlForCountryCode: [resultSet objectForColumnName: @"countryCode"]
                                                          withBaseUrl: [resultSet objectForColumnName: @"baseURL"]];

             NSDictionary * entry =
             @{
                @"chartUrl": rankURL,
                @"countryCode": [resultSet objectForColumnName: @"countryCode"],
                @"countryId": [resultSet objectForColumnName: @"countryId"],
                @"chartId": [resultSet objectForColumnName: @"genreChartId"],
                @"genreId": [resultSet objectForColumnName: @"genreId"],
             };

             [results addObject: entry];
         } // End of results loop
     }];

    return [results copy];
} // End of chartUrlsForApplicationids

+ (NSString*) chartUrlForCountry: (AWCountry*) country
                     withBaseUrl: (NSString*) baseUrl
{
    return [self chartUrlForCountryCode: country.countryCode
                            withBaseUrl: baseUrl];
}

+ (NSString*) chartUrlForCountryCode: (NSString*) countryCode
                         withBaseUrl: (NSString*) baseUrl
{
    return [NSString stringWithFormat: @"%@&cc=%@&limit=1000", baseUrl, countryCode];
}

@end
