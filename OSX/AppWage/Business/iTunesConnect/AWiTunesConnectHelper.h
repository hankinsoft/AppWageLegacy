//
//  AWiTunesConnectHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWApplicationFinderEntry;

typedef enum {
    SalesReportDaily            = 0,
    SalesReportWeekly           = 1,
    SalesReportMonthly          = 2,
    SalesReportYearly           = 3,
    SalesReportMAX              = 4
} SalesReportType;

@interface AWiTunesConnectHelper : NSObject

+ (NSData*) postRequest: (NSString*) requestType
                 userId: (NSString*) userId
            accessToken: (NSString*) accessToken
                command: (NSString*) command
              arguments: (NSString*) arguments
                headers: (NSDictionary**) headers
                  error: (NSError**) error;

- (NSNumber*) vendorIdWithUser: (NSString*) user
                   accessToken: (NSString*) accessToken
                    vendorName: (NSString**) vendorName
                  loginSuccess: (BOOL*) loginSuccess
                         error: (NSError**) outError;

- (NSArray*) applicationsForVendorName: (NSString*) vendorName
                                 error: (NSError**) error;

- (AWApplicationFinderEntry*) detailsForApplicationId: (NSNumber*) applicationId
                                          countryCode: (NSString*) countryCode
                                                error: (NSError**) error;

@end
