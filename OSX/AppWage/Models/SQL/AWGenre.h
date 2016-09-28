//
//  Genre.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AWGenreChart : NSObject

@property (nonatomic, retain) NSNumber * chartId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * baseUrl;

@end

@interface AWGenre : NSObject

+ (void) initializeChartsFromFileSystem;

// Genres
+ (NSArray*) allGenres;
+ (AWGenre*) genreByGenreId: (NSNumber*) genreId;

// Charts
+ (NSArray*) allCharts;
+ (AWGenreChart*) chartByChartId: (NSNumber*) chartId;

@property (nonatomic, retain) NSNumber * genreId;
@property (nonatomic, retain) NSNumber * genreType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentGenreId;
@property (nonatomic, retain) NSSet *applications;
@property (nonatomic, retain) NSSet *charts;

@end
