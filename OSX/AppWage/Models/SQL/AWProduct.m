//
//  Product.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWProduct.h"
#import "AWApplication.h"

@implementation AWProduct

NSMutableArray * _allProducts = nil;

+ (void) initialize
{
    _allProducts = [NSMutableArray array];
} // End of initialize

+ (void) initializeAllProducts
{
    @synchronized(self)
    {
        NSMutableArray * productsTemp = [[NSMutableArray alloc] init];
        
        [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database)
         {
             FMResultSet * results = [database executeQuery: @"SELECT * FROM product"];
             while([results next])
             {
                 AWProduct * product   = [[AWProduct alloc] init];

                 product.appleIdentifier = [results objectForColumnName: @"appleIdentifier"];
                 product.productType = [results objectForColumnName: @"productType"];
                 product.title = [results objectForColumnName: @"title"];
                 product.applicationId = [results objectForColumnName: @"applicationId"];
                 
                 [productsTemp addObject: product];
             } // End of results loop
         }];

        _allProducts = productsTemp;
    } // End of @synchronized
} // End of initializeAllProducts

+ (NSArray*) allProducts
{
    @synchronized(self)
    {
        return _allProducts;
    } // End of @synchronized
} // End of allProducts

+ (NSArray*) productsByApplicationId: (NSNumber*) applicationId
{
    @synchronized(self)
    {
        NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"applicationId = %@", applicationId];

        NSArray * filteredProducts = [_allProducts filteredArrayUsingPredicate: searchPredicate];
        return filteredProducts;
    } // End of @synchronized
} // End of productsByApplicationId

+ (AWProduct*) productByAppleIdentifier: (NSNumber*) appleIdentifier
{
    @synchronized(self)
    {
        NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"appleIdentifier = %@", appleIdentifier];

        NSArray * filteredProducts = [_allProducts filteredArrayUsingPredicate: searchPredicate];
        return filteredProducts.firstObject;
    } // End of @synchronized
} // End of productByAppleIdentifier

+ (void) addProduct: (AWProduct*) product
{
    NSAssert(nil != product.applicationId, @"Product application id cannot be nil.");

    @synchronized(self)
    {
        [_allProducts addObject: product];
    } // End of synchronized

    [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appwageDatabase, BOOL * rollback)
     {
         NSString * insertQuery = [NSString stringWithFormat: @"INSERT INTO product (appleIdentifier, productType, title, applicationId) VALUES (?,?,?,?)"];

         NSArray * arguments = @[
                                 product.appleIdentifier,
                                 product.productType,
                                 product.title,
                                 product.applicationId
                                 ];
         
         [appwageDatabase executeUpdate: insertQuery
                   withArgumentsInArray: arguments];
     }];

}

@end
