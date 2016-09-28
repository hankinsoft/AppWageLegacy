//
//  EmailHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/24/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWEmailHelper.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWCurrencyHelper.h"
#import "AWCountry.h"

#import <FXKeychain.h>
#import <GDataXML-HTML/GDataXMLNode.h>

@interface AWEmailHelper()
{
    NSNumberFormatter * currencyFormatter;
    NSNumberFormatter * wholeNumberFormatter;
}
@end

@implementation AWEmailHelper

+(AWEmailHelper*)sharedInstance
{
    static dispatch_once_t pred;
    static AWEmailHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWEmailHelper alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        // Configure the currency formatter.
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];

        // And our whole number formatter
        wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
        wholeNumberFormatter.numberStyle = NSNumberFormatterBehavior10_4;
        wholeNumberFormatter.maximumFractionDigits  = 0;
    }
    
    return self;
}

- (void) sendDailyEmailAuto
{
    [self sendDailyEmailAuto: NO];
}

- (void) sendDailyEmailAuto: (BOOL) sendAlways
{
    if(!sendAlways)
    {
        if(![AWSystemSettings sharedInstance].emailsEnabled)
        {
            NSLog(@"sendDailyEmailAuto - Not sending email. Emails are not enabled.");
            return;
        }
        
        // Figure out if we have already sent an email today. If we have then don't go any futher.
        NSDate * previousEmailDate = [[NSUserDefaults standardUserDefaults] objectForKey: @"PreviousDailyEmail"];
        if(nil != previousEmailDate)
        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents * dateComponents1 = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                              fromDate: [NSDate date]];

            NSDateComponents * dateComponents2 = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                              fromDate: previousEmailDate];

            // Did we already send one today?
            if(dateComponents1.year ==dateComponents2.year &&
               dateComponents1.month ==dateComponents2.month &&
               dateComponents1.day ==dateComponents2.day)
            {
                NSLog(@"sendDailyEmailAuto - Not sending email. Already sent one today.");
                return;
            } // End of already sent email today
        } // End of we had a previous day.

        [[NSUserDefaults standardUserDefaults] setObject: [NSDate date]
                                                  forKey: @"PreviousDailyEmail"];
    } // End of not send always

    NSDictionary * emailSettings = [[FXKeychain defaultKeychain] objectForKey: @"EmailConfiguration"];
    
    if(nil == emailSettings)
    {
        NSLog(@"sendDailyEmailAuto - Not sending email. EmailConfiguration keychain entry is null.");
        return;
    }

    if(nil == emailSettings[@"username"] || 0 == [emailSettings[@"username"] length])
    {
        NSLog(@"sendDailyEmailAuto - Not sending email. username is null or empty.");
        return;
    }

    if(nil == emailSettings[@"password"] || 0 == [emailSettings[@"password"] length])
    {
        NSLog(@"sendDailyEmailAuto - Not sending email. password is null or empty.");
        return;
    }

    if(nil == emailSettings[@"smtp"] || 0 == [emailSettings[@"smtp"] length])
    {
        NSLog(@"sendDailyEmailAuto - Not sending email. smtp is null or empty.");
        return;
    }

    NSString * emailTo = emailSettings[@"sentTo"];
    if(0 == emailTo.length)
    {
        emailTo = emailSettings[@"username"];
    }

    NSLog(@"Sending daily email.");

    NSError * error = nil;

    // Send email with our values
    [self sendDailyEmail: emailSettings[@"username"]
                password: emailSettings[@"password"]
                smtpHost: emailSettings[@"smtp"]
                smtpPort: emailSettings[@"smtpPort"]
                     tls: [emailSettings[@"smtpTLS"] boolValue]
                 emailTo: [emailTo componentsSeparatedByString: @";"]
              dailyEmail: !sendAlways
                   error: &error];

    // Check for errors. Log if we have one.
    if(nil != error)
    {
        NSLog(@"Failed to send daily email. Error: %@.", error.localizedDescription);
    }
    else
    {
        NSLog(@"Daily email sent successfully.");
    }
}

- (BOOL) sendDailyEmail: (NSString*) smtpFrom
               password: (NSString*) password
               smtpHost: (NSString*) smtpHost
               smtpPort: (NSNumber*) smtpPort
                    tls: (BOOL) tlsEnabled
                emailTo: (NSArray*) emailTo
             dailyEmail: (BOOL) dailyEmail
                  error:(NSError *__autoreleasing *)outError
{
    if(nil == CHILKAT_EMAIL_KEY || 0 == CHILKAT_EMAIL_KEY.length)
    {
        NSError * noLicenseError =
            [NSError errorWithDomain: AWErrorDomain
                                code: 0
                            userInfo: @{NSLocalizedDescriptionKey: @"You must define CHILKAT_EMAIL_KEY to enable emails."}];

        // Set our error
        *outError = noLicenseError;

        return false;
    } // End of no license specified

    // Get yesterdayDate
    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                        fromDate: [NSDate date]];

    NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * yesterday        = [gregorian dateFromComponents: dateComponents];

    // Set our date subtraction
    NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
    [subtractComponents setDay: -1];

    // get a new date by adding components
    yesterday =
    [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                  toDate: yesterday
                                                 options: 0];

    CkoEmail * ckoEmail  = [[CkoEmail alloc] init];
    ckoEmail.FromAddress = smtpFrom;
    ckoEmail.FromName    = @"AppWage";

    NSLog(@"EmailTo: %@", emailTo);
    [emailTo enumerateObjectsUsingBlock: ^(NSString * targetEmail, NSUInteger index, BOOL * stop)
     {
         NSString * sendTo = [targetEmail stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

         NSLog(@"Adding: %@", sendTo);
         [ckoEmail AddTo: sendTo
            emailAddress: sendTo];
     }];

    NSString * emailTemplateHtmlPath = [[NSBundle mainBundle] pathForResource: @"EmailTemplate_Body"
                                                                       ofType: @"html"];

    NSError __autoreleasing * error = nil;
    NSString * emailTemplateHtml = [NSString stringWithContentsOfFile: emailTemplateHtmlPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSMutableString * html = [NSMutableString stringWithString: emailTemplateHtml];
    
    NSMutableDictionary * appSectionDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary * appLookup = [NSMutableDictionary dictionary];

    [[AWApplication allApplications] enumerateObjectsUsingBlock:
     ^(AWApplication* application, NSUInteger index, BOOL * stop)
     {
         NSArray * products = [AWProduct productsByApplicationId: application.applicationId];
         
         for(AWProduct * product in products)
         {
             [appLookup setObject: @{@"name": application.name, @"id": application.applicationId}
                           forKey: product.appleIdentifier];
         }

         NSDictionary * preparedHTML = [self prepareHtmlForApplicationSection: application
                                                                   dailyEmail: dailyEmail];
         [appSectionDictionary setObject: preparedHTML
                                  forKey: application.applicationId];
     }];

    NSArray * sortedKeys = [appSectionDictionary keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary * entry1, NSDictionary * entry2)
    {
        NSNumber * reviews1 = entry1[@"reviews"];
        NSNumber * reviews2 = entry2[@"reviews"];

        return [reviews2 compare: reviews1];
    }];

    // Setup our innerHTML
    NSMutableString * appSectionHTML = [NSMutableString stringWithString: @""];
    [sortedKeys enumerateObjectsUsingBlock: ^(id key, NSUInteger index, BOOL * stop)
     {
         if(0 != [appSectionDictionary[key][@"newReviews"] unsignedIntegerValue])
         {
             [appSectionHTML appendString: appSectionDictionary[key][@"html"]];
         } // End of we have reviews
     }];

    [html replaceOccurrencesOfString: @"{APPWAGE_APP_ENTRIES}"
                          withString: appSectionHTML
                             options: 0
                               range: NSMakeRange(0, html.length)];

    // Replace any dates
    // Setup our date formatter
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];

    [html replaceOccurrencesOfString: @"{APPWAGE_DATE}"
                          withString: [dateFormatter stringFromDate: yesterday]
                             options: 0
                               range: NSMakeRange(0, html.length)];

    // Update our summary section
    [self updateSummary: &html
              appLookup: appLookup];

    [ckoEmail SetHtmlBody: [NSString stringWithString: html]];

    // Setup our subject
    ckoEmail.Subject = [NSString stringWithFormat: @"%@ - Daily Stats for %@",
                        kAppDisplayName,
                        [dateFormatter stringFromDate: yesterday]];
    
    //    NSLog(@"HTML is: %@", html);
    
    CkoMailMan * ckoMailMan = [[CkoMailMan alloc] init];
    [ckoMailMan UnlockComponent: CHILKAT_EMAIL_KEY];

    // Send email.
    ckoMailMan.SmtpHost     = smtpHost;
    ckoMailMan.SmtpUsername = smtpFrom;
    ckoMailMan.SmtpPassword = password;
    ckoMailMan.SmtpPort     = smtpPort;
    ckoMailMan.StartTLS     = tlsEnabled;

    bool success = [ckoMailMan SendEmail: ckoEmail];
    if(!success)
    {
        *outError = [NSError errorWithDomain: AWErrorDomain
                                        code: 0
                                    userInfo: @{NSLocalizedDescriptionKey: @"Failed to send testing email. Please verify that the details are entered correctly."}];

        NSLog(@"Error! %@.", ckoMailMan.LastErrorXml);
        NSLog(@"Error2: %@", ckoMailMan.LastErrorText);
        NSLog(@"Error3: %@", ckoMailMan.LastErrorHtml);
    } // End of no success

    [ckoMailMan CloseSmtpConnection];
    
    return success;
} // End of sendDailyEmail

- (void) updateSummary: (NSMutableString*__autoreleasing*) outHtml
             appLookup: (NSDictionary*) appLookup
{
    // Dereference, becuase i'm lazy and dont want to type extras every time.
    NSMutableString * html = *outHtml;

    // Get yesterdayDate
    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                        fromDate: [NSDate date]];

    NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone        = [NSTimeZone timeZoneWithName: @"UTC"];

    NSDate * yesterday        = [gregorian dateFromComponents: dateComponents];
    
    // Set our date subtraction
    NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
    [subtractComponents setDay: -1];

    // get a new date by adding components
    yesterday =
        [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                      toDate: yesterday
                                                     options: 0];

    __block NSArray * allReports = nil;
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase* salesDatabase) {
        NSString * salesQuery = [NSString stringWithFormat: @"SELECT * FROM salesReportCache WHERE date = %ld", (NSUInteger)yesterday.timeIntervalSince1970];

        NSMutableArray * tempReports = @[].mutableCopy;

        FMResultSet * results = [salesDatabase executeQuery: salesQuery];
        while([results next])
        {
            [tempReports addObject: [results resultDictionary]];
        }

        allReports = tempReports;
    }];

    __block CGFloat totalDownloads = 0, totalRevenue = 0;

    NSMutableDictionary * summaryDetails = [NSMutableDictionary dictionary];

    // Loop through the full lookup adding a default entry for each item.
    [appLookup enumerateKeysAndObjectsUsingBlock: ^(NSString * key, NSDictionary * appDetails, BOOL * stop)
     {
         NSMutableDictionary * entry = [NSMutableDictionary dictionaryWithDictionary: @{
            @"downloads":@0,
            @"revenue":@0,
            @"newReviews":@0,
            @"name": appDetails[@"name"],
            @"appId": appDetails[@"id"]
            }];

         [summaryDetails setObject: entry
                            forKey: appDetails[@"name"]];
     }];

    NSLog(@"All reports: %ld", allReports.count);
    NSPredicate * downloadsPredicate = [NSPredicate predicateWithFormat: @"cacheType = %ld",
                                        DashboardChartDisplayTotalSales];

    NSArray * allDownloads = [allReports filteredArrayUsingPredicate: downloadsPredicate];
    [allDownloads enumerateObjectsUsingBlock: ^(NSDictionary * report, NSUInteger reportIndex, BOOL * stop)
     {
         NSNumber * appleIdentifier = report[@"productId"];

         NSDictionary * appDetails = appLookup[appleIdentifier];
         NSString * appName = nil;
         NSNumber * appId   = nil;

         if(nil == appDetails)
         {
             appName = [NSString stringWithFormat: @"Unknown (%@)", appleIdentifier];
             appId   = appleIdentifier;
         }
         else
         {
             appName = appDetails[@"name"];
             appId   = appDetails[@"id"];
         }

         NSMutableDictionary * entry = [summaryDetails objectForKey: appName];

         double cacheValue = [report[@"cacheValue"] doubleValue];
         if(nil == entry)
         {
             entry = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                      @"downloads":@0,
                                                                      @"revenue":@0,
                                                                      @"newReviews":@0,
                                                                      @"name": appName,
                                                                      @"appId": appId
                                                                      }];

             [summaryDetails setObject: entry
                                forKey: appName];
         }

         NSNumber * currentDownloads = entry[@"downloads"];
         totalDownloads += cacheValue;

         currentDownloads = [NSNumber numberWithFloat: currentDownloads.doubleValue + cacheValue];
         [entry setObject: currentDownloads
                   forKey: @"downloads"];
     }];

    NSPredicate * revenuePredicate = [NSPredicate predicateWithFormat: @"cacheType = %ld",
                                        DashboardChartDisplayTotalRevenue];

    NSArray * paidDownloads = [allReports filteredArrayUsingPredicate: revenuePredicate];
    NSLog(@"There are %ld paid downloads.", paidDownloads.count);

    [paidDownloads enumerateObjectsUsingBlock: ^(NSDictionary * report, NSUInteger reportIndex, BOOL * stop)
     {
         NSNumber * appleIdentifier = report[@"productId"];

         double cacheValue = [report[@"cacheValue"] doubleValue];
         NSDictionary * appDetails = appLookup[appleIdentifier];
         NSString * appName = nil;
         NSNumber * appId   = nil;
         
         if(nil == appDetails)
         {
             appName = [NSString stringWithFormat: @"Unknown (%@)", appleIdentifier];
             appId   = appleIdentifier;
         }
         else
         {
             appName = appDetails[@"name"];
             appId   = appDetails[@"id"];
         }

         NSMutableDictionary * entry = [summaryDetails objectForKey: appName];

         if(nil == entry)
         {
             entry = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                      @"downloads":@0,
                                                                      @"revenue":@0,
                                                                      @"newReviews":@0,
                                                                      @"name": appName,
                                                                      @"appId": appId
                                                                      }];

             [summaryDetails setObject: entry
                                forKey: appName];
         }

         NSNumber * currentRevenue = entry[@"revenue"];

         totalRevenue += cacheValue;

         currentRevenue = [NSNumber numberWithFloat: currentRevenue.doubleValue + cacheValue];
         [entry setObject: currentRevenue
                   forKey: @"revenue"];
     }];

    // Our review database
    [[AWSQLiteHelper reviewDatabaseQueue] inDatabase: ^(FMDatabase* reviewDatabase) {
        __block NSUInteger index = 0;
        [summaryDetails enumerateKeysAndObjectsUsingBlock:
         ^(NSString * key, NSMutableDictionary * entry, BOOL * stop)
         {
             NSPredicate * applicationPredicate = [NSPredicate predicateWithFormat: @"name LIKE[cd] %@", entry[@"name"]];
             AWApplication * application = [[AWApplication allApplications] filteredArrayUsingPredicate: applicationPredicate].firstObject;
             if(nil == application)
             {
                 return;
             }

             NSString * applicationReviewsQuery = [NSString stringWithFormat: @"SELECT COUNT(*) FROM review WHERE applicationId = %@ AND lastUpdated >= %ld", application.applicationId, (NSUInteger)yesterday.timeIntervalSince1970];

             entry[@"newReviews"] = @([reviewDatabase intForQuery: applicationReviewsQuery]);
             ++index;
         }];
    }];
    
    // Want want the top revenue first, then the top downloaded.
    NSArray * sortedKeys = [summaryDetails keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary * obj1, NSDictionary * obj2)
    {
        NSNumber * revenue1 = obj1[@"revenue"];
        NSNumber * revenue2 = obj2[@"revenue"];

        NSComparisonResult result = [revenue2 compare: revenue1];

        // If the revenue is the same (most likely for a free product),
        // then we will then compare the downloads.
        if(NSOrderedSame == result)
        {
            result = [obj2[@"downloads"] compare: obj1[@"downloads"]];
        }

        return result;
    }];

    // If our application has had no updates, then remove everything.
    [sortedKeys enumerateObjectsUsingBlock: ^(NSString * key, NSUInteger index, BOOL * stop)
     {
         NSDictionary * entry = summaryDetails[key];

         NSNumber * downloads  = entry[@"downloads"];
         NSNumber * revenue    = entry[@"revenue"];
         NSNumber * newReviews = entry[@"newReviews"];

         if(0 == downloads.doubleValue && 0 == revenue.doubleValue && 0 == newReviews.doubleValue)
         {
             [summaryDetails removeObjectForKey: key];
         } // End of application had no updates
     }];

    // Sort again: TODO ---- Functionalize sorting
    sortedKeys =
        [summaryDetails keysSortedByValueUsingComparator:
         ^NSComparisonResult(NSDictionary * obj1, NSDictionary * obj2)
                  {
                      NSNumber * revenue1 = obj1[@"revenue"];
                      NSNumber * revenue2 = obj2[@"revenue"];
                      
                      NSComparisonResult result = [revenue2 compare: revenue1];
                      
                      // If the revenue is the same (most likely for a free product),
                      // then we will then compare the downloads.
                      if(NSOrderedSame == result)
                      {
                          result = [obj2[@"downloads"] compare: obj1[@"downloads"]];
                      }
                      
                      return result;
                  }];

    __block NSUInteger totalNewReviews = 0;
    NSMutableString * summaryRowsHtml = [NSMutableString string];

    NSString * lightGreyStyle = @" style=\"color: #ddd;\"";
    NSString * redStyle       = @" style=\"color: #d00;\"";

    [sortedKeys enumerateObjectsUsingBlock: ^(NSString * key, NSUInteger index, BOOL * stop)
     {
         NSDictionary * entry = summaryDetails[key];

         NSNumber * downloads  = entry[@"downloads"];
         NSNumber * revenue    = entry[@"revenue"];
         NSNumber * newReviews = entry[@"newReviews"];

         NSString * iconPath = [NSString stringWithFormat: @"https://appwage.com/appIcons/icon.php?applicationId=%@",
                                entry[@"appId"]];

         NSMutableString * rowHtml = [NSMutableString string];

         [rowHtml appendString: @"<tr"];

         if(((index + 1) % 2) == 0)
         {
             [rowHtml appendString: @" style=\"background-color:#fdfdfd;\""];
         } // End of background color
         else
         {
             [rowHtml appendString: @" style=\"background-color:#fefefe;\""];
         } // End of background color

         [rowHtml appendString: @">"];

//  style=\"border-top:1px solid #f1f1f1\"
         [rowHtml appendFormat: @"<td style=\"height:25px;padding-left:11px;overflow: hidden;text-overflow: ellipsis;white-space: nowrap;\"><img width=\"16px\" height=\"16px\" src=\"%@\" style=\"border:0px; padding-right: 8px;\" valign=\"middle\" /><span>%@</span></td>",
          iconPath, entry[@"name"]];

         // Add the downloads column
         [rowHtml appendFormat: @"<td width=\"80\" style=\"text-align: right;\"><span class=\"summaryEntry\"%@>%@</span></td>",
          0 == downloads.integerValue ? lightGreyStyle : @"",
          [wholeNumberFormatter stringFromNumber: downloads]];

         NSString * colorStyle = @"";

         // Have to check double value as revenue could be $0.01
         if(0 == revenue.doubleValue)
         {
             colorStyle = lightGreyStyle;
         }
         else if(0 > revenue.integerValue)
         {
             colorStyle = redStyle;
         }

         // Add the revenue
         [rowHtml appendFormat: @"<td width=\"80\" style=\"text-align: right;\"><span class=\"summaryEntry\"%@>%@</span></td>",
          colorStyle,
          [currencyFormatter stringFromNumber: revenue]];

         // Add the new reviews
         [rowHtml appendFormat: @"<td width=\"100\" style=\"text-align:right;padding-right:10px;\"><span class=\"summaryEntry\"%@>%@</span></td>",
          0 == newReviews.integerValue ? lightGreyStyle : @"",
          [wholeNumberFormatter stringFromNumber: newReviews]];

         [summaryRowsHtml appendString: rowHtml];

         // Setup our total new reviews
         totalNewReviews += newReviews.unsignedIntegerValue;
     }];

    // Replace our summary rows
    [html replaceOccurrencesOfString: @"{APPWAGE_SUMMARY_ENTRIES}"
                          withString: summaryRowsHtml
                             options: 0
                               range: NSMakeRange(0, html.length)];

    // Finally, set our total downloads and total revenue
    [html replaceOccurrencesOfString: @"{APPWAGE_SUMMARY_TOTAL_DOWNLOADS}"
                          withString: [wholeNumberFormatter stringFromNumber: [NSNumber numberWithFloat: totalDownloads]]
                             options: 0
                               range: NSMakeRange(0, html.length)];

    [html replaceOccurrencesOfString: @"{APPWAGE_SUMMARY_TOTAL_REVENUE}"
                          withString: [currencyFormatter stringFromNumber: [NSNumber numberWithFloat: totalRevenue]]
                             options: 0
                               range: NSMakeRange(0, html.length)];

    [html replaceOccurrencesOfString: @"{APPWAGE_SUMMARY_TOTAL_NEWREVIEWS}"
                          withString: [wholeNumberFormatter stringFromNumber: [NSNumber numberWithFloat: totalNewReviews]]
                             options: 0
                               range: NSMakeRange(0, html.length)];
} // End of updateSummary

- (NSDictionary*) prepareHtmlForApplicationSection: (AWApplication*) application
                                        dailyEmail: (BOOL) dailyEmail
{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone        = [NSTimeZone timeZoneWithName: @"UTC"];

    // Get our current date. Midnight
    const NSUInteger dateEnum =
        NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour;

    NSDateComponents * dateComponents = [gregorian components: dateEnum
                                                     fromDate: [NSDate date]];

    [dateComponents setSecond: 0];
    [dateComponents setMinute: 0];
    [dateComponents setHour: 0];

    NSDate * baseDate   = [gregorian dateFromComponents: dateComponents];

    // Set our date subtraction
    NSDateComponents * subtractComponents = [[NSDateComponents alloc] init];
    [subtractComponents setDay: -1];

    // get a new date by adding components
    baseDate =
        [[NSCalendar currentCalendar] dateByAddingComponents: subtractComponents
                                                      toDate: baseDate
                                                     options: 0];

    __block NSUInteger totalReviewsForApplication = 0;
    __block NSArray * applicationReviews = nil;

    [[AWSQLiteHelper reviewDatabaseQueue] inDatabase: ^(FMDatabase* database) {
        // Figure out our total reviews
        NSString * countQuery = [NSString stringWithFormat: @"SELECT COUNT(*) FROM review WHERE applicationId = %@", application.applicationId];

        totalReviewsForApplication = [database intForQuery: countQuery];

        NSMutableArray * allReviews = @[].mutableCopy;

        NSString * reviewClause = [NSString stringWithFormat: @"applicationId = %@ AND lastUpdated >= %ld", application.applicationId, (NSUInteger)baseDate.timeIntervalSince1970];

        NSString * reviewQueryString = [NSString stringWithFormat: @"SELECT * FROM review WHERE %@ ORDER BY lastUpdated DESC", reviewClause];

        FMResultSet * results = [database executeQuery: reviewQueryString];
        while([results next])
        {
            [allReviews addObject: [results resultDictionary]];
        }

        // If are emails are set to be mark reviews as read
        if(dailyEmail && [AWSystemSettings sharedInstance].emailsMarkSentReviewsAsRead)
        {
            NSString * updateQuery = [NSString stringWithFormat: @"UPDATE review SET readByUser = 1 WHERE %@", reviewClause];

            [database executeQuery: updateQuery];
        } // End of emails mark reviews as end

        applicationReviews = allReviews;
    }];

    NSUInteger newReviews = applicationReviews.count;

    NSString * emailTemplateHtmlPath = [[NSBundle mainBundle] pathForResource: @"EmailTemplate_AppEntry"
                                                                       ofType: @"html"];
    NSString * reviewTemplateHtmlPath = [[NSBundle mainBundle] pathForResource: @"EmailTemplate_AppEntry _Review"
                                                                        ofType: @"html"];
    
    NSError __autoreleasing * error = nil;
    NSString * emailTemplateHtml = [NSString stringWithContentsOfFile: emailTemplateHtmlPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSMutableString * html = [NSMutableString stringWithString: emailTemplateHtml];

    NSString * iconPath = [NSString stringWithFormat: @"https://appwage.com/appIcons/icon.php?applicationId=%@",
                          application.applicationId.stringValue];

    [html replaceOccurrencesOfString: @"{APPWAGE_APP_ICON}"
                          withString: iconPath
                             options: 0
                               range: NSMakeRange(0, html.length)];
    
    // Setup the app name.
    [html replaceOccurrencesOfString: @"{APPWAGE_APP_NAME}"
                          withString: application.name
                             options: 0
                               range: NSMakeRange(0, html.length)];

    [html replaceOccurrencesOfString: @"{APPWAGE_APP_NEW_REVIEWS}"
                          withString: [NSString stringWithFormat: @"%ld reviews, %ld new",
                                       totalReviewsForApplication,
                                       newReviews]
                             options: 0
                               range: NSMakeRange(0, html.length)];

    NSString * reviewTemplateHTML = [NSString stringWithContentsOfFile: reviewTemplateHtmlPath
                                                              encoding: NSUTF8StringEncoding
                                                                 error: &error];

    NSMutableString * reviewHTML = [NSMutableString string];

    [applicationReviews enumerateObjectsUsingBlock: ^(NSDictionary * review, NSUInteger reviewIndex, BOOL * stop)
     {
         NSUInteger reviewStars       = [review[@"stars"] integerValue];
         NSString * title             = review[@"title"];
         NSString * translatedTitle   = review[@"translatedTitle"];
         NSString * content           = review[@"content"];
         NSString * translatedContent = review[@"translatedContent"];
         NSNumber * countryId         = review[@"countryId"];
         
         NSPredicate * countryPredicate = [NSPredicate predicateWithFormat: @"countryId = %@", countryId];
         AWCountry * country = [[AWCountry allCountries] filteredArrayUsingPredicate: countryPredicate].firstObject;

         NSMutableString * tempReview = [reviewTemplateHTML mutableCopy];

         // Not pretty code, but it works. I don't want to bother writing a pad routine
         // unless I need to re-use it somewhere else.
         NSString * starAlt = @"";

         if(1 == reviewStars)
         {
             starAlt = @"*";
         }
         else if(2 == reviewStars)
         {
             starAlt = @"**";
         }
         else if(3 == reviewStars)
         {
             starAlt = @"***";
         }
         else if(4 == reviewStars)
         {
             starAlt = @"****";
         }
         else if(5 == reviewStars)
         {
             starAlt = @"*****";
         }

         NSString * starImgSrc = [NSString stringWithFormat: @"https://appwage.com/images/%ldstar.png", reviewStars];

         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_TITLE}"
                                     withString: [NSNull null] == (id)translatedTitle ? title : translatedTitle
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];
         
         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_CONTENT}"
                                     withString: [NSNull null] == (id)translatedContent ? content : translatedContent
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];

         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_STARALT}"
                                     withString: starAlt
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];

         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_STARIMGSRC}"
                                     withString: starImgSrc
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];

         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_COUNTRYNAME}"
                                     withString: @"todo country name"
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];

         [tempReview replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEW_COUNTRYIMGSRC}"
                                     withString: [NSString stringWithFormat: @"https://appwage.com/images/flags_16/%@.png", country.countryCode.lowercaseString]
                                        options: 0
                                          range: NSMakeRange(0, tempReview.length)];

         [reviewHTML appendString: tempReview];
     }];

    [html replaceOccurrencesOfString: @"{APPWAGE_APP_REVIEWS}"
                          withString: reviewHTML
                             options: 0
                               range: NSMakeRange(0, html.length)];

    // Append a spacer
    [html appendString: @"<div style=\"min-height:20px;line-height:1px;font-size:1px\"><br style=\"visibility:hidden\" /></div>"];

    NSString * outHtml = [NSString stringWithString: html];

    // If we have no new reviews, then we will remove the reviews section
    if(0 == newReviews)
    {
        NSError __autoreleasing * error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString: outHtml
                                                                       error: &error];
        if (doc == nil) { return nil; }

        if(nil != error && nil != doc)
        {
            NSLog(@"Error creating NSDocument from data. %@", error.localizedDescription);
            return nil;
        }

        NSArray * appEntryNodes = [doc.rootElement nodesForXPath: @"//tr[@class=\"appEntryDetails\"]"
                                                           error: &error];

//        NSArray *  = [parser.body findChildrenOfClass: @"appEntryDetails"];
        if(1 == appEntryNodes.count)
        {
            GDataXMLElement * node = appEntryNodes[0];
            while(node.childCount > 0)
            {
                [node removeChild: [node childAtIndex: 0]];
            }

            outHtml = [[NSString alloc] initWithData: [doc XMLData]
                                            encoding: NSUTF8StringEncoding];
        } // End of we have nodes
    } // End of we had no new reviews.

    return @{
             @"html": outHtml,
             @"newReviews": @(newReviews),
             @"reviews":[NSNumber numberWithInteger: totalReviewsForApplication]
             };
} // End of htmlForApplicationSection

@end
