//
//  Product.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AWApplication;

@interface AWProduct : NSObject

+ (void) initializeAllProducts;
+ (NSArray*) allProducts;
+ (NSArray*) productsByApplicationId: (NSNumber*) applicationId;
+ (AWProduct*) productByAppleIdentifier: (NSNumber*) appleIdentifier;
+ (void) addProduct: (AWProduct*) product;

@property (nonatomic, retain) NSNumber * appleIdentifier;
@property (nonatomic, retain) NSNumber * productType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * applicationId;

@end
