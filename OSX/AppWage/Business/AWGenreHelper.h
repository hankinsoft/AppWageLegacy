//
//  GenreHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/2/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AWCountry;

@interface AWGenreHelper : NSObject

+ (NSArray*) updateGenresFromFile: (NSString*) targetFile
                        genreType: (NSNumber*) genreType;

+ (NSArray*) chartsForApplicationIds: (NSArray*) applicationIds
                           countries: (NSArray*) countries;

+ (NSString*) chartUrlForCountry: (AWCountry*) country withBaseUrl: (NSString*) baseUrl;
+ (NSString*) chartUrlForCountryCode: (NSString*) countryCode
                         withBaseUrl: (NSString*) baseUrl;

@end
