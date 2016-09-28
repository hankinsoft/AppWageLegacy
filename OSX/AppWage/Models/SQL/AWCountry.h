//
//  Country.h
//  AppWage
//
//  Created by Kyle Hankinson on 2015-01-15.
//  Copyright (c) 2015 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWCountry : NSObject

+ (void) initializeCountriesFromFileSystem;

+ (NSArray*) allCountries;
+ (AWCountry*) lookupByCode: (NSString*) countryCode;
+ (AWCountry*) lookupByCountryId: (NSNumber*) countryId;

@property(nonatomic,retain) NSNumber * countryId;
@property(nonatomic,retain) NSString * countryCode;
@property(nonatomic,retain) NSString * name;

@property(nonatomic,assign) BOOL     shouldCollectRanks;

@end
