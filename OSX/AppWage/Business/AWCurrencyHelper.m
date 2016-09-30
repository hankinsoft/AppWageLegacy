//
//  CurrencyHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/30/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWCurrencyHelper.h"
#import <AFNetworking/AFNetworking.h>

#define kExchangeRateUserDefault            @"ExchangeRates"

@interface AWCurrencyHelper()
{
    NSDictionary * currencyDictionary;
}
@end

@implementation AWCurrencyHelper

@synthesize allCurrencies;

+(AWCurrencyHelper*) sharedInstance
{
    static dispatch_once_t pred;
    static AWCurrencyHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWCurrencyHelper alloc] init];
    });

    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        NSString * currencyPath = [NSString stringWithFormat:@"%@/Currency.js", [[NSBundle mainBundle] resourcePath]];
        NSLog(@"Currency path: %@", currencyPath);

        NSData * currencyData = [NSData dataWithContentsOfFile: currencyPath];

        NSError __autoreleasing * error = nil;
        NSDictionary * currencyArray = [NSJSONSerialization JSONObjectWithData: currencyData
                                                                  options: kNilOptions
                                                                    error: &error];
        
        NSMutableArray * _allCurrencies = [NSMutableArray array];
        [currencyArray enumerateKeysAndObjectsUsingBlock: ^(NSString * key, NSString * value, BOOL * stop)
         {
             [_allCurrencies addObject:
              @{
                kCurrencyName: value,
                kCurrencyCode: key
                }];
         }];

        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey: kCurrencyName
                                                                   ascending: YES];

        // Set our currencies
        allCurrencies = [NSArray arrayWithArray: [_allCurrencies sortedArrayUsingDescriptors: @[descriptor]]];
    }

    return self;
}

- (void) updateExchangeRates
{
    NSURL * url = [NSURL URLWithString:@"https://appwage.com/exchangerates/ExchangeRates.json"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET: url.absoluteString
      parameters:nil
        progress:nil
         success:
     ^(NSURLSessionTask *task, id JSON)
    {
             // If we did not get what we wanted.
             if(nil == JSON || ![JSON isKindOfClass: [NSDictionary class]])
             {
                 return;
             }
             
             // Get our exchangeRates entries
             NSDictionary * exchangeRates = JSON[@"exchangeRanges"];
             if(nil == exchangeRates)
             {
                 NSLog(@"Failed to find exchangeRates.");
                 return;
             } // End of no exchangeRates

             // Update our user defaults
             [[NSUserDefaults standardUserDefaults] setObject: exchangeRates
                                                       forKey: kExchangeRateUserDefault];

             // Update our exchange rates
             NSLog(@"CurrencyHelper - Exchange rates have been updated.");
    }
    failure:
     ^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (double) exchangeRateToCurrency: (NSString*) toCurrency
{
    return [self exchangeRateFromCurrency: toCurrency
                               toCurrency: [[AWSystemSettings sharedInstance] currencyCode]];
}

- (double) exchangeRateFromCurrency: (NSString*) sourceCurrency
                         toCurrency: (NSString*) toCurrency
{
    // No need
    if([sourceCurrency isEqualToString: toCurrency]) return 1.0;

    // Get our exchange rates
    NSDictionary * exchangeRates = [[NSUserDefaults standardUserDefaults] objectForKey: kExchangeRateUserDefault];

//    NSLog(@"Want to convert from %@ to %@", sourceCurrency, toCurrency);

    NSNumber * exchangeRate = exchangeRates[sourceCurrency][toCurrency];
    return exchangeRate.doubleValue;
} // End of exchangeRateFromCurrency

- (NSString*) sqlQueryForExchangeRate: (NSString*) targetExchangeRate
{
    NSDictionary * exchangeRates = [[NSUserDefaults standardUserDefaults] objectForKey: kExchangeRateUserDefault];

    NSMutableString * currencyCase = [NSMutableString stringWithString: @"CASE\r\n"];

    [exchangeRates enumerateKeysAndObjectsUsingBlock: ^(NSString * currencyCode, NSDictionary * lookup, BOOL * stop)
     {
         if(NSOrderedSame == [currencyCode localizedCaseInsensitiveCompare: targetExchangeRate])
         {
             [currencyCase appendFormat: @"\tWHEN currency = '%@' THEN 1\r\n",
              currencyCode];
         }
         else
         {
             [currencyCase appendFormat: @"\tWHEN currency = '%@' THEN %@\r\n",
              currencyCode, lookup[targetExchangeRate]];
         }
     }];

    [currencyCase appendString: @"ELSE 0\r\n"];

    return currencyCase.copy;
}

@end
