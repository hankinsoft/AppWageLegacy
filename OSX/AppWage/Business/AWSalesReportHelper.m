//
//  SalesReportHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-26.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSalesReportHelper.h"

@implementation AWSalesReportHelper

+ (NSString*) clauseForReportType: (DashboardChartDisplay) salesReportType
{
    switch(salesReportType)
    {
        case DashboardChartDisplayUpgrades:
            return @"productTypeIdentifier IN ('7', '7F', '7T', 'F7')";
        case DashboardChartDisplayTotalSales:
            return @"units > 0 AND productTypeIdentifier IN ('1', '1F', '1T', 'F1')";
        case DashboardChartDisplayTotalPaidSales:
            return @"profitPerUnit > 0 AND productTypeIdentifier IN ('1', '1F', '1T', 'F1') AND promoCode != 'GR' AND promoCode != 'CR-RW'";
        case DashboardChartDisplayTotalFreeSales:
            return @"productTypeIdentifier IN ('1', '1F', '1T', 'F1') AND profitPerUnit = 0 AND promoCode != 'GR'";
        case DashboardChartDisplayTotalInAppPurchases:
            return @"units > 0 AND productTypeIdentifier IN ('IA1', 'IA9', 'IAY', 'FI1')";
        case DashboardChartDisplayTotalRevenue:
            return @"profitPerUnit != 0";
        case DashboardChartDisplayRefunds:
            return @"units < 0";
        case DashboardChartDisplayGiftRedemption:
            return @"units > 0 AND promoCode = 'GR'";
        case DashboardChartDisplayGiftPurchases:
            return @"units > 0 AND promoCode = 'GP'";
        case DashboardChartDisplayPromoCodes:
            return @"units > 0 AND promoCode = 'CR-RW'";
        case DashboardChartDisplayMAXIMUM:
            return nil;
    } // End of chartDisplayMode switch
}
@end
