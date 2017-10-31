//
//  CurrencyHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/30/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCurrencyName           @"CurrencyName"
#define kCurrencyCode           @"CurrencyCode"

@interface AWCurrencyHelper : NSObject

+ (AWCurrencyHelper*) sharedInstance;

- (void) updateExchangeRates;
- (double) exchangeRateToCurrency: (NSString*) toCurrency;
- (double) exchangeRateFromCurrency: (NSString*) sourceCurrency
                         toCurrency: (NSString*) toCurrency;
- (NSString*) sqlQueryForExchangeRate: (NSString*) targetExchangeRate;

@property(nonatomic,retain) NSArray * allCurrencies;

@property(nonatomic,readonly) NSString * currentCurrencySymbol;

@end
