//
//  ReportCollectionOperation.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/28/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWReportCollectionOperation.h"
#import "AWAccountHelper.h"
#import "AWiTunesConnectHelper.h"
#import <CHCSVParser/CHCSVParser.h>

#import "NSString+Extend.h"

#define WEEKS_TO_DOWNLOAD       26
#define DAYS_TO_DOWNLOAD        30
#define MONTHS_TO_DOWNLOAD      12
#define YEARS_TO_DOWNLOAD       10

@implementation ReportCollectionOperation
{
    NSMutableSet * uniqueReportDates;
}

@synthesize accountDetails, delegate, importFromURLDetailsArray;

static NSMutableSet * existingProduct;
static NSMutableSet * existingApplicationIds;
static NSString * localReportPath;
static NSCharacterSet * trimCharacterSet;

+ (void) initialize
{
    // Our existing product
    existingProduct        = [NSMutableSet set];
    existingApplicationIds = [NSMutableSet set];

    trimCharacterSet = [NSCharacterSet characterSetWithCharactersInString: @"\"$%"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    localReportPath = [path stringByAppendingString: [NSString stringWithFormat: @"/%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]]];
    localReportPath = [localReportPath stringByAppendingPathComponent:@"/iTunesReports"];

    // Create our directory
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = false;

    NSError __autoreleasing * error = nil;

    if(![fileManager fileExistsAtPath: localReportPath isDirectory: &isDirectory])
    {
        NSLog(@"Want to create path: %@", localReportPath);
        
        [fileManager createDirectoryAtPath: localReportPath
               withIntermediateDirectories: YES
                                attributes: nil
                                     error: &error];
        if(nil != error)
        {
            NSLog(@"Error creating directory (%@): %@", localReportPath, error.localizedDescription);
        }
    } // End of the file does not already exist.
    
    NSLog(@"Local report path is: %@", localReportPath);
} // End of initialize

- (NSSet*) uniqueDates
{
    return uniqueReportDates.copy;
}

- (void) main
{
    @autoreleasepool
    {
        uniqueReportDates = [NSMutableSet set];

        [self.delegate reportCollectionOperationStarted: self];

        if(nil == importFromURLDetailsArray)
        {
            // Download our reports
            [self downloadReports];
        }
        else
        {
            [self importFromUrls: importFromURLDetailsArray];
        }

        [self.delegate reportCollectionOperationFinished: self];
    } // End of autoreleasepool
} // End of main

- (void) importFromUrls: (NSArray*) detailsArray
{
    NSString * progressString = @"Processing reports";

    [detailsArray enumerateObjectsUsingBlock: ^(NSDictionary * entry, NSUInteger index, BOOL * stop)
     {
         NSStringEncoding encoding = NSUTF8StringEncoding;

         [self.delegate reportProgressChanged: progressString
                                     progress: (double)index / detailsArray.count * 100.0];

         // Get our sourceUrlPath
         NSString * sourceUrlPath = entry[@"path"];
         NSError  * error = nil;

         NSString * reportCSV     =
            [NSString stringWithContentsOfFile: sourceUrlPath
                                  usedEncoding: &encoding
                                         error: &error];

         if(nil != error)
         {
             return;
         } // End of we had an error

         NSNumber * salesReportType = entry[@"reportType"];

         [self processReportCSV: reportCSV
                salesReportType: salesReportType
                     reportName: sourceUrlPath.lastPathComponent
                       vendorId: entry[@"vendorId"]
              internalAccountId: nil];
     }];
} // End of importFromUrls

- (void)downloadDailyReports: (double)total
                   gregorian: (NSCalendar *)gregorian
                  startIndex: (NSTimeInterval)startIndex
                    progress: (double*) currentProgress
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    [dateFormatter setDateFormat: @"yyyyMMdd"];

    // Download the last 30 days (iTunes connect stores 30 daily reports).
    for(NSUInteger index = 0;
        index < DAYS_TO_DOWNLOAD && ![self isCancelled];
        ++index)
    {
        NSString * progressString =
        //            [NSString stringWithFormat: @"Downloading daily reports for %@", dateString];
            [NSString stringWithFormat: @"Downloading daily reports"];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];

        NSDate * targetDate = [NSDate dateWithTimeIntervalSince1970: startIndex - (timeIntervalDay * (index+ 1))];

        // Get our current date. (Day month year).
        NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:
                                             NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                            fromDate: targetDate];
        
        NSDate * importDate     = [gregorian dateFromComponents: dateComponents];
        NSString * dateString   = [dateFormatter stringFromDate: importDate];

        [self downloadDailyReportForDate: importDate
                              dateString: dateString];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];
    }
}

- (void)downloadWeeklyReports: (double)total
                    gregorian: (NSCalendar *)gregorian
                   startIndex: (NSTimeInterval)startIndex
                     progress: (double*) currentProgress
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    [dateFormatter setDateFormat: @"yyyyMMdd"];

    NSDate * targetDate = [NSDate date];
    while(true)
    {
        NSInteger dayOfWeek =
            [[gregorian components: NSCalendarUnitWeekday
                          fromDate: targetDate] weekday];

        if(1 == dayOfWeek)
        {
            break;
        }

        // Set our date subtraction
        NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
        [subtractComponents setDay: -1];

        // get a new date
        targetDate =
            [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                          toDate: targetDate
                                                         options: 0];
    } // End of while loop

    // Download the last x weeks days
    for(NSUInteger index = 0;
        index < WEEKS_TO_DOWNLOAD && ![self isCancelled];
        ++index)
    {
        // Set our date subtraction
        NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
        [subtractComponents setWeekOfYear: -index];

        // get a new date by adding components
        NSDate * importDate =
            [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                          toDate: targetDate
                                                         options: 0];

        NSString * dateString   = [dateFormatter stringFromDate: importDate];

        NSString * progressString =
//            [NSString stringWithFormat: @"Downloading weekly reports for %@", dateString];
            [NSString stringWithFormat: @"Downloading weekly reports"];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];

        [self downloadWeeklyReportForDate: importDate
                               dateString: dateString];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];
    }
} // End of downloadWeeklyReports

- (void)downloadMonthlyReports: (double)total
                     gregorian: (NSCalendar *)gregorian
                    startIndex: (NSTimeInterval)startIndex
                      progress: (double*) currentProgress
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    [dateFormatter setDateFormat: @"yyyyMM"];

    NSDate * targetDate = [NSDate date];

    // Download the last 12 days (iTunes connect stores monthly reports).
    for(NSUInteger index = 0;
        index < MONTHS_TO_DOWNLOAD && ![self isCancelled];
        ++index)
    {
        // Set our date subtraction
        NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
        [subtractComponents setMonth: -index];

        // get a new date by adding components
        NSDate * importDate =
            [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                          toDate: targetDate
                                                         options: 0];

        NSString * dateString   = [dateFormatter stringFromDate: importDate];

        NSString * progressString =
//            [NSString stringWithFormat: @"Downloading monthly reports for %@", dateString];
            [NSString stringWithFormat: @"Downloading monthly reports"];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];

        [self downloadMonthlyReportForDateString: dateString];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];
    }
}

- (void)downloadYearlyReports: (double)total
                    gregorian: (NSCalendar *)gregorian
                   startIndex: (NSTimeInterval)startIndex
                     progress: (double*) currentProgress
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    [dateFormatter setDateFormat: @"yyyy"];

    // Download the last 10 years. Start at one, because the current year is not available.
    for(NSUInteger index = 1;
        index < YEARS_TO_DOWNLOAD && ![self isCancelled];
        ++index)
    {
        // Set our date subtraction
        NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
        [subtractComponents setMonth: 0];
        [subtractComponents setYear: -index];

        // get a new date by adding components
        NSDate * importDate = [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                                            toDate: [NSDate date]
                                                                           options: 0];

        NSString * dateString   = [dateFormatter stringFromDate: importDate];
        
        NSString * progressString =
//            [NSString stringWithFormat: @"Downloading yearly reports for %@", dateString];
            [NSString stringWithFormat: @"Downloading yearly reports"];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];

        [self downloadYearlyReportForDateString: dateString];

        *currentProgress = (*currentProgress) + 1;
        [self.delegate reportProgressChanged: progressString
                                    progress: (*currentProgress) / total * 100.0];
    }
}

- (void) downloadReports
{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

    NSTimeInterval startIndex = [[NSDate date] timeIntervalSince1970];

    double totalProgress = 0;

    // Days
    totalProgress += (DAYS_TO_DOWNLOAD * 2);

    // Weeks
    totalProgress += (WEEKS_TO_DOWNLOAD * 2);

    // 12 months
    totalProgress += (MONTHS_TO_DOWNLOAD * 2);

    // 10 years
    totalProgress += (YEARS_TO_DOWNLOAD * 2);

    double currentProgress = 0;

    // Download our yearly reports
    [self downloadYearlyReports: totalProgress
                      gregorian: gregorian
                     startIndex: startIndex
                       progress: &currentProgress];

    // Download our monthly reports
    [self downloadMonthlyReports: totalProgress
                       gregorian: gregorian
                      startIndex: startIndex
                       progress: &currentProgress];

    // Download our daily reports
    [self downloadWeeklyReports: totalProgress
                      gregorian: gregorian
                     startIndex: startIndex
                       progress: &currentProgress];

    // Download our daily reports
    [self downloadDailyReports: totalProgress
                     gregorian: gregorian
                    startIndex: startIndex
                       progress: &currentProgress];
} // End of downloadReports

- (BOOL) iTunesConnectDownloadReport: (NSString *) dateString
                          reportType: (NSString*) reportType
                               error: (NSError *__autoreleasing*) error
                    reportFilename_p: (NSString **) reportFilename_p
                         reportCSV_p: (NSString **) reportCSV_p
{
    NSLog(@"Want to download sales reports for %@ (account %@)",
          dateString,
          accountDetails.accountInternalId);

    NSNumber * vendorId = accountDetails.vendorId;

    NSString * internalReportName =
        [NSString stringWithFormat: @"S_%c_%@_%@.txt",
            [[reportType uppercaseString] characterAtIndex: 0],
            vendorId,
            dateString];

    NSString * rootDirectory = [NSString stringWithFormat: @"%@/%@",
                                localReportPath, vendorId];
    NSString * localFile     = [rootDirectory stringByAppendingPathComponent: internalReportName];

    if([[NSFileManager defaultManager] fileExistsAtPath: localFile
                                            isDirectory: NULL])
    {
        NSStringEncoding stringEncoding;
        NSError * error = nil;

        *reportCSV_p = [NSString stringWithContentsOfFile: localFile
                                             usedEncoding: &stringEncoding
                                                    error: &error];
        
        if(nil == error)
        {
            *reportFilename_p = localFile;
            return YES;
        }
    } // End of file exists

    NSString * commandString =
        [NSString stringWithFormat: @"%ld,Sales,Summary,%@,%@",vendorId.integerValue,reportType,dateString];

    NSDictionary * headers = nil;
    NSData * reportData =
        [AWiTunesConnectHelper postRequest: @"Sales"
                                    userId: accountDetails.accountUserName
                               accessToken: accountDetails.accountAccessToken
                                   command: @"Sales.getReport"
                                 arguments: commandString
                                   headers: &headers
                                     error: error];

    if(nil != *error)
    {
        NSString * logMessage =
            [NSString stringWithFormat: @"%s: Error downloading (%@/%@) report: %@.",
                __FUNCTION__,
                dateString,
                accountDetails.accountInternalId,
                (*error).localizedDescription];

        NSLog(@"%@", logMessage);
        [self.delegate logError: logMessage];
        
        return NO;
    }

    // Get our filename header
    *reportFilename_p = headers[@"filename"];
    if(nil == *reportFilename_p || 0 == (*reportFilename_p).length)
    {
        NSString * resultString =
            [[NSString alloc] initWithData: reportData
                                  encoding: NSUTF8StringEncoding];

        NSString * logMessage =
            [NSString stringWithFormat: @"Error downloading report. Error:\r\n%@", resultString];

        NSLog(@"%@", logMessage);
        [self.delegate logError: logMessage];

        return NO;
    } // End of we have headers

    // Get our details
    *reportCSV_p = [[NSString alloc] initWithData: reportData
                                         encoding: NSUTF8StringEncoding];
    
    // Could be gzipped
    if(nil == *reportCSV_p || 0 == (*reportCSV_p).length)
    {
        reportData = [reportData gunzippedData];
        *reportCSV_p  = [[NSString alloc] initWithData: reportData
                                              encoding: NSUTF8StringEncoding];
    }

    if(nil == *reportCSV_p || 0 == (*reportCSV_p).length)
    {
        NSString * logMessage = @"Error downloading report: Unable to decode data.";
        NSLog(@"%@", logMessage);
        [self.delegate logError: logMessage];
        
        return NO;
    }

    BOOL isDirectory = NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath: rootDirectory
                                             isDirectory: &isDirectory] || !isDirectory)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath: rootDirectory
                                  withIntermediateDirectories: YES
                                                   attributes: nil
                                                        error: &(*error)];
    } // End of directory does not exist

    // Delete the file if it exists.
    if([[NSFileManager defaultManager] fileExistsAtPath: localFile])
    {
        [[NSFileManager defaultManager] removeItemAtPath: localFile
                                                   error: &(*error)];
    } // End of file exists already

    // Write to file.
    [(*reportCSV_p) writeToFile: localFile
                     atomically: YES
                       encoding: NSUTF8StringEncoding
                          error: &(*error)];

    // Log it.
    if(nil != *error)
    {
        NSString * logMessage = [NSString stringWithFormat: @"Error downloading report: Unable to perserve to file: %@",
                                 (*error).localizedDescription];

        NSLog(@"%@", logMessage);
        [self.delegate logError: logMessage];

        return NO;
    }

    NSLog(@"Report Written to: %@", localFile);

    return YES;
}

- (void) downloadDailyReportForDate: (NSDate*) importDate
                         dateString: (NSString *) dateString
{
    if(![self.delegate reportCollectionOperation: self
                      shouldCollectReportForDate: importDate
                               internalAccountId: accountDetails.accountInternalId])
    {
        NSString * errorMessage =
            [NSString stringWithFormat: @"Daily sales report already exists for %@ (account %@).",
                dateString, accountDetails.accountInternalId];

        NSLog(@"%@", errorMessage);
        [self.delegate logError: errorMessage];

        return;
    } // End of we already have this downloaded.

    NSError  *error;
    NSString *reportFilename;
    NSString *reportCSV;

    if(![self iTunesConnectDownloadReport: dateString
                               reportType: @"Daily"
                                    error: &error
                         reportFilename_p: &reportFilename
                              reportCSV_p: &reportCSV])
    {
        NSLog(@"Failed to download daily report");
        [self.delegate logError: @"Failed to download daily report"];
        return;
    } // End of failed to process

    // Process the report CSV
    [self processReportCSV: reportCSV
           salesReportType: [NSNumber numberWithInteger: SalesReportDaily]
                reportName: reportFilename
                  vendorId: accountDetails.vendorId
         internalAccountId: accountDetails.accountInternalId];
} // End of downloadDailyReportForDate

- (void) downloadWeeklyReportForDate: (NSDate*) importDate
                          dateString: (NSString *) dateString
{
    if(![self.delegate reportCollectionOperation: self
                      shouldCollectReportForDate: importDate
                               internalAccountId: accountDetails.accountInternalId])
    {
        NSString * errorMessage =
            [NSString stringWithFormat: @"Weekly sales report already exists for %@ (account %@).",
                dateString, accountDetails.accountInternalId];

        NSLog(@"%@", errorMessage);
        [self.delegate logError: errorMessage];

        return;
    } // End of we already have this downloaded.
    
    NSError  *error;
    NSString *reportFilename;
    NSString *reportCSV;

    if(![self iTunesConnectDownloadReport: dateString
                               reportType: @"Weekly"
                                    error: &error
                         reportFilename_p: &reportFilename
                              reportCSV_p: &reportCSV])
    {
        NSLog(@"Failed to download weekly report");
        [self.delegate logError: @"Failed to download weekly report"];
        return;
    } // End of failed to process

    // Process the report CSV
    [self processReportCSV: reportCSV
           salesReportType: [NSNumber numberWithInteger: SalesReportWeekly]
                reportName: reportFilename
                  vendorId: accountDetails.vendorId
         internalAccountId: accountDetails.accountInternalId];
} // End of downloadWeeklyReportForDate

- (void) downloadMonthlyReportForDateString: (NSString *) dateString
{
    NSError  *error;
    NSString *reportFilename;
    NSString *reportCSV;

    if(![self iTunesConnectDownloadReport: dateString
                               reportType: @"Monthly"
                                    error: &error
                         reportFilename_p: &reportFilename
                              reportCSV_p: &reportCSV])
    {
        NSLog(@"Failed to download monthly report");
        [self.delegate logError: @"Failed to download monthly report"];
        return;
    }

    [self processReportCSV: reportCSV
           salesReportType: [NSNumber numberWithInteger: SalesReportMonthly]
                reportName: reportFilename
                  vendorId: accountDetails.vendorId
         internalAccountId: accountDetails.accountInternalId];
} // End of downloadMonthlyReportForDate

- (void) downloadYearlyReportForDateString: (NSString *) dateString
{
    NSError  *error;
    NSString *reportFilename;
    NSString *reportCSV;

    if(![self iTunesConnectDownloadReport: dateString
                               reportType: @"Yearly"
                                    error: &error
                         reportFilename_p: &reportFilename
                              reportCSV_p: &reportCSV])
    {
        NSLog(@"Failed to download yearly report");
        [self.delegate logError: @"Failed to download yearly report"];
        return;
    }

    [self processReportCSV: reportCSV
           salesReportType: [NSNumber numberWithInteger: SalesReportYearly]
                reportName: reportFilename
                  vendorId: accountDetails.vendorId
         internalAccountId: accountDetails.accountInternalId];
} // End of downloadMonthlyReportForDate

- (void) processReportCSV: (NSString*) reportCSV
          salesReportType: (NSNumber*) salesReportType
               reportName: (NSString*) reportName
                 vendorId: (NSNumber*) vendorId
        internalAccountId: (NSString*) newInternalAccountId
{
    __block NSString * internalAccountId = newInternalAccountId.copy;

    NSDateFormatter * importDateFormatter = [[NSDateFormatter alloc] init];
    [importDateFormatter setDateFormat: @"MM/dd/yyyy"];
    [importDateFormatter setTimeZone: [NSTimeZone timeZoneWithName:@"UTC"]];

    __block BOOL failed = NO;

    NSMutableArray * lines = [NSMutableArray arrayWithArray: [[reportCSV stringByReplacingOccurrencesOfString: @"\r" withString: @""] componentsSeparatedByString: @"\n"]];

    // Get our header.
    NSArray * header = [lines[0] componentsSeparatedByString: @"\t"];

    // Remove that line
    [lines removeObjectAtIndex: 0];

    NSInteger appleIdentifierIndex   = [header indexOfObject: @"Apple Identifier"];
    NSAssert(NSNotFound != appleIdentifierIndex, @"Apple Identifier column was not found.");

    NSInteger parentIdentifierIndex  = [header indexOfObject: @"Parent Identifier"];
    NSAssert(NSNotFound != parentIdentifierIndex, @"parentIdentifierIndex column was not found.");

    NSInteger productTypeIndex       = [header indexOfObject: @"Product Type Identifier"];
    NSAssert(NSNotFound != productTypeIndex, @"productTypeIndex column was not found.");

    NSInteger titleIndex             = [header indexOfObject: @"Title"];
    NSAssert(NSNotFound != titleIndex, @"titleIndex column was not found.");

    NSInteger unitsIndex             = [header indexOfObject: @"Units"];
    NSAssert(NSNotFound != unitsIndex, @"unitsIndex column was not found.");

    NSInteger developerProceedsIndex = [header indexOfObject: @"Developer Proceeds"];
    NSAssert(NSNotFound != developerProceedsIndex, @"developerProceedsIndex column was not found.");

    NSInteger promoCodeIndex         = [header indexOfObject: @"Promo Code"];
    NSAssert(NSNotFound != promoCodeIndex, @"promoCodeIndex column was not found.");

    NSInteger beginDateIndex         = [header indexOfObject: @"Begin Date"];
    NSAssert(NSNotFound != beginDateIndex, @"beginDate column was not found.");

    NSInteger endDateIndex           = [header indexOfObject: @"End Date"];
    NSAssert(NSNotFound != endDateIndex, @"endDate column was not found.");

    NSInteger developerIndex           = [header indexOfObject: @"Developer"];
    NSAssert(NSNotFound != developerIndex, @"developer column was not found.");

    NSInteger countryCodeIndex = [header indexOfObject: @"Country Code"];
    NSAssert(NSNotFound != countryCodeIndex, @"countryCodeIndex column was not found.");

    NSInteger currencyIndex = [header indexOfObject: @"Currency of Proceeds"];
    NSAssert(NSNotFound != currencyIndex, @"currencyIndex column was not found.");
    
    NSInteger productSKUIndex = [header indexOfObject: @"SKU"];
    NSAssert(NSNotFound != productSKUIndex, @"productSKUIndex column was not found.");

    __block NSMutableDictionary * parentIdentifiers = [NSMutableDictionary dictionary];
    [lines enumerateObjectsUsingBlock: ^(NSString * line, NSUInteger lineNumber, BOOL * stop)
     {
         // Last line could be blank.
         if(0 == [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
         {
             return;
         }

         // Get our line entries
         NSArray * lineEntries = [line componentsSeparatedByString: @"\t"];

         NSNumber * appleIdentifier = [NSNumber numberWithInteger: [lineEntries[appleIdentifierIndex] integerValue]];

         NSString * productSKU = [lineEntries[productSKUIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         NSString * parentIdentifier = [lineEntries[parentIdentifierIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         if(parentIdentifier.length != 0)
         {
             return;
         } // End of no parentIdentifier

         NSString * countryCode = [[lineEntries[countryCodeIndex] lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         NSString * productTitle = [lineEntries[titleIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         if(nil == parentIdentifiers[appleIdentifier])
         {
             parentIdentifiers[productSKU] = appleIdentifier;
         }

         // If we have no internalAccountId, then we need to look it up or add it.
         if(nil == internalAccountId)
         {
             NSString * developerName = [lineEntries[developerIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

             internalAccountId =
                [self.delegate reportCollectionNeedsInternalAccountIdForVendorId: vendorId
                                                                      vendorName: developerName];
         } // End of no internalAccountId

         @synchronized(existingApplicationIds)
         {
             if([existingApplicationIds containsObject: appleIdentifier])
             {
                 return;
             }

             [existingApplicationIds addObject: appleIdentifier];

             if(![self.delegate reportCollectionOperationCreateApplicationIfNotExists: appleIdentifier
                                                                         productTitle: productTitle
                                                                          countryCode: countryCode
                                                                            accountId: internalAccountId])
             {
                 NSLog(@"Failed to create application. App id: %@, countrycode: %@",
                       appleIdentifier, countryCode);
             }
         } // End of synchronized
     }];

    NSLog(@"Processing products");

    // Deal with products
    [lines enumerateObjectsUsingBlock: ^(NSString * line, NSUInteger lineNumber, BOOL * stop)
     {
         // Last line could be blank.
         if(0 == [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length) return;
         
         // Get our line entries
         NSArray * lineEntries = [line componentsSeparatedByString: @"\t"];

         NSNumber * appleIdentifier = [NSNumber numberWithInteger: [lineEntries[appleIdentifierIndex] integerValue]];
         NSString * parentIdentifier = [lineEntries[parentIdentifierIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
         NSString * productTitle = lineEntries[titleIndex];

         NSDictionary * productDetails = @{
                                           @"appleIdentifier": appleIdentifier,
                                           @"productTitle":productTitle,
                                           @"productType":ProductTypeInAppPurchase
                                           };

         NSNumber * parentApplicationId;
         if(0 != parentIdentifier.length)
         {
             parentApplicationId = [NSNumber numberWithInteger: [parentIdentifiers[parentIdentifier] integerValue]];
         } // End of no parent identifier
         else
         {
             parentApplicationId = appleIdentifier;
         }

         // If the product already exists, then we will just continue
         @synchronized(existingProduct)
         {
             if([existingProduct containsObject: appleIdentifier])
             {
                 return;
             }

             if(![self.delegate createProductIfRequiredWithDetails: productDetails
                                                 applicationId: parentApplicationId])
             {
                 * stop = YES;
                 failed = YES;
                 return;
             }

             [existingProduct addObject: appleIdentifier];
         } // End of synchronzied
     }];

    if(failed)
    {
        return;
    }

    NSMutableArray * reports = [NSMutableArray array];

    NSLog(@"Processing salesReport: %@", reportName);
    [lines enumerateObjectsUsingBlock: ^(NSString * line, NSUInteger lineNumber, BOOL * stop)
     {
         // Last line could be blank.
         if(0 == [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length) return;

         // Get our line entries
         NSArray * lineEntries = [line componentsSeparatedByString: @"\t"];
         NSString * beginDateString  = lineEntries[beginDateIndex];
         NSString * endDateString    = lineEntries[endDateIndex];

         NSString * currency    = lineEntries[currencyIndex];
         NSString * countryCode = [lineEntries[countryCodeIndex] lowercaseString];
         NSNumber * appleIdentifier = [NSNumber numberWithInteger: [lineEntries[appleIdentifierIndex] integerValue]];

         NSInteger units  = [lineEntries[unitsIndex] integerValue];
         double    profit = [lineEntries[developerProceedsIndex] doubleValue];
         NSString * productTypeIdentifier = lineEntries[productTypeIndex];

         NSString * promoCode = [lineEntries[promoCodeIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         NSDate * beginDate = [importDateFormatter dateFromString: beginDateString];
         NSDate * endDate   = [importDateFormatter dateFromString: endDateString];

         [reports addObject: @{
                               @"internalAccountId": internalAccountId,
                               @"salesReportType": salesReportType,
                               @"countryCode":countryCode,
                               @"units":[NSNumber numberWithInteger: units],
                               @"productTypeIdentifier":productTypeIdentifier,
                               @"appleIdentifier":appleIdentifier,
                               @"profitPerUnit":[NSNumber numberWithDouble: profit],
                               @"currency":currency,
                               @"promoCode":promoCode,
                               @"beginDate":beginDate,
                               @"endDate":endDate
                               }];

         [uniqueReportDates addObject: [NSNumber numberWithDouble: beginDate.timeIntervalSince1970]];
         [uniqueReportDates addObject: [NSNumber numberWithDouble: endDate.timeIntervalSince1970]];
     }];

    // Our reports
    [self.delegate reportCollectionOperation: self
                             receivedReports: [reports copy]];
} // End of processReportCSV

@end
