//
//  SalesReportHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-26.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

// Dashboard chart types. The order of these should NEVER be changed
// as the cache table uses the values as well.
typedef enum {
    DashboardChartDisplayUpgrades            = 0,
    DashboardChartDisplayTotalSales          = 1,
    DashboardChartDisplayTotalPaidSales      = 2,
    DashboardChartDisplayTotalFreeSales      = 3,
    DashboardChartDisplayTotalInAppPurchases = 4,
    DashboardChartDisplayTotalRevenue        = 5,

    DashboardChartDisplayRefunds             = 6,
    DashboardChartDisplayGiftRedemption      = 7,
    DashboardChartDisplayGiftPurchases       = 8,
    DashboardChartDisplayPromoCodes          = 9,

    DashboardChartDisplayMAXIMUM             = 10,
} DashboardChartDisplay;

@interface AWSalesReportHelper : NSObject

+ (NSString*) clauseForReportType: (DashboardChartDisplay) salesReportType;

@end
