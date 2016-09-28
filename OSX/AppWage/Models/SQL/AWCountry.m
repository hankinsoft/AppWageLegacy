//
//  Country.m
//  AppWage
//
//  Created by Kyle Hankinson on 2015-01-15.
//  Copyright (c) 2015 Hankinsoft. All rights reserved.
//

#import "AWCountry.h"

@implementation AWCountry
{
}

NSArray         * _allCountries;
NSDictionary    * _countryLookupByCode;
NSDictionary    * _countryLookupByCountryId;

+ (void) initializeCountriesFromFileSystem
{
    // Country json found at: https://rss.itunes.apple.com/data/lang/en-US/common.json?_=1390300310021
    NSString * countriesPath = [NSString stringWithFormat:@"%@/Countries.js", [[NSBundle mainBundle] resourcePath]];

    NSLog(@"Country path: %@", countriesPath);

    NSData * countriesData = [NSData dataWithContentsOfFile: countriesPath];

    NSError __autoreleasing * error = nil;
    NSArray * countriesJsonArray = [NSJSONSerialization JSONObjectWithData: countriesData
                                                                   options: kNilOptions
                                                                     error: &error];

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * database, BOOL * rollback)
     {
         [countriesJsonArray enumerateObjectsUsingBlock: ^(NSDictionary * countryJson, NSUInteger index, BOOL * stop)
          {
              NSString * countryName  = countryJson[@"Name"];
              NSString * countryCode  = countryJson[@"Code"];
              NSNumber * countryId    = countryJson[@"CountryId"];

              [database executeUpdate: @"INSERT OR IGNORE INTO country (countryId, countryCode, name) VALUES(?,?,?)",
               countryId, countryCode, countryName];
          }];
     }];

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appwageDatabase, BOOL * rollback)
     {
         NSMutableArray * countriesTemp = [NSMutableArray array];
         NSMutableDictionary * countryLookupTemp = [NSMutableDictionary dictionary];
         NSMutableDictionary * countryLookupByCountryIdTemp = [NSMutableDictionary dictionary];

         FMResultSet * results = [appwageDatabase executeQuery: @"SELECT * FROM country"];
         while([results next])
         {
             NSString * countryCode  = [results stringForColumn: @"countryCode"];
             NSNumber * countryId    = [NSNumber numberWithInteger: [results intForColumn: @"countryId"]];

             AWCountry * country          = [[AWCountry alloc] init];
             country.countryId          = countryId;
             country.name               = [results stringForColumn: @"name"];
             country.countryCode        = countryCode;
             country.shouldCollectRanks = [results boolForColumn: @"shouldCollectRanks"];
             
             [countriesTemp addObject: country];

             [countryLookupTemp setObject: country
                                   forKey: countryCode.lowercaseString];
             
             [countryLookupByCountryIdTemp setObject: country
                                              forKey: countryId];
         } // End of results loop

         NSSortDescriptor * countrySortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                                                  ascending: YES];

         _allCountries             = [countriesTemp sortedArrayUsingDescriptors: @[countrySortDescriptor]];
         _countryLookupByCode      = countryLookupTemp.copy;
         _countryLookupByCountryId = countryLookupByCountryIdTemp.copy;
     }];
} // End of initializeCountriesFromFile

+ (NSArray*) allCountries
{
    return _allCountries;
} // End of allCountries

+ (AWCountry*) lookupByCode: (NSString*) countryCode
{
    return _countryLookupByCode[countryCode.lowercaseString];
}

+ (AWCountry*) lookupByCountryId: (NSNumber*) countryId
{
    return _countryLookupByCountryId[countryId];
}

@end
