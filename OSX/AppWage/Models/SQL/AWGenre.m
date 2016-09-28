//
//  Genre.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWGenre.h"
#import "AWApplication.h"

@implementation AWGenreChart

@end

@implementation AWGenre

NSArray         * _allGeners;
NSDictionary    * _genreIdLookup;

NSArray         * _allCharts;
NSDictionary    * _chartLookupByChartId;

+ (void) initializeChartsFromFileSystem
{
    // Make sure our genres list is up to date
    NSString * iosFile =
        [NSString stringWithFormat:@"%@/Genre-iOS.js", [[NSBundle mainBundle] resourcePath]];

    NSString * osxFile =
        [NSString stringWithFormat:@"%@/Genre-OSX.js", [[NSBundle mainBundle] resourcePath]];

    NSMutableArray * allGenres = [NSMutableArray array];

    [allGenres addObjectsFromArray:
        [AWGenreHelper updateGenresFromFile: iosFile
                                  genreType: ApplicationTypeIOS]];

    [allGenres addObjectsFromArray:
        [AWGenreHelper updateGenresFromFile: osxFile
                                  genreType: ApplicationTypeOSX]];

    // Setup our allGenres lookup
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                                      ascending: YES];

    _allGeners = [allGenres sortedArrayUsingDescriptors: @[sortDescriptor]];

    NSMutableDictionary * genreIdLookupTemp = [NSMutableDictionary dictionary];
    NSMutableArray      * allChartsTemp     = [NSMutableArray array];
    NSMutableDictionary * genreChartIdLookupTemp = [NSMutableDictionary dictionary];
    [allGenres enumerateObjectsUsingBlock: ^(AWGenre* genre, NSUInteger index, BOOL * stop)
     {
         genreIdLookupTemp[genre.genreId] = genre;
         
         [genre.charts enumerateObjectsUsingBlock: ^(AWGenreChart* chart, BOOL * stop)
          {
              [allChartsTemp addObject: chart];
              genreChartIdLookupTemp[chart.chartId] = chart;
          }];
     }];

    // Set our lookup
    _genreIdLookup          = genreIdLookupTemp.copy;
    _allCharts              = allChartsTemp.copy;
    _chartLookupByChartId   = genreChartIdLookupTemp.copy;
} // End of initializeChartsFromFileSystem

+ (NSArray*) allGenres
{
    return _allGeners;
} // End of allGenres

+ (AWGenre*) genreByGenreId: (NSNumber*) genreId
{
    return _genreIdLookup[genreId];
} // End of genreByGenreId

+ (NSArray*) allCharts
{
    return _allCharts;
} // End of allCharts

+ (AWGenreChart*) chartByChartId: (NSNumber*) chartId
{
    return _chartLookupByChartId[chartId];
} // End of chartByChartId

@end
