//
//  AWReviewCollectorOperation.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWReviewCollectorOperation.h"
#import "AWCollectionOperationQueue.h"

@interface AWReviewCollectorOperation()
{
    NSDateFormatter * dateFormatter;
    NSURL           * targetURL;
}

@property(nonatomic,assign) NSUInteger      page;
@property(nonatomic,copy)   NSDictionary    * applicationDetails;
@property(nonatomic,copy)   NSDictionary    * countryDetails;

@end

@implementation AWReviewCollectorOperation

@synthesize page = _page;
@synthesize applicationDetails = _applicationDetails;
@synthesize countryDetails = _countryDetails;

static NSRegularExpression * appleReviewPageRegularExpression;

+ (void) initialize
{
    NSError __autoreleasing * error = nil;

    // Setup our regular expression
    appleReviewPageRegularExpression =
    [NSRegularExpression regularExpressionWithPattern: @"/page=([0-9]+)/"
                                              options: NSRegularExpressionCaseInsensitive
                                                error: &error];

    NSAssert(nil == error, error.localizedDescription);
}

- (id) initWithApplicationDetails: (NSDictionary*) applicationDetails
                   countryDetails: (NSDictionary*) countryDetails
                             page: (NSUInteger) page
{
    self = [super init];
    if(self)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];

        self.applicationDetails = applicationDetails;
        self.countryDetails     = countryDetails;
        self.page               = page;

        ///////////
        /// https://rss.itunes.apple.com/us/?urlDesc=%2Fcustomerreviews
        ///////////
/*
        NSString * reviewURLString = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/customerreviews/page=%ld/id=%@/limit=300/sortBy=mostRecent/xml",
                                      self.countryDetails[@"countryCode"], self.page, self.applicationDetails[@"applicationId"]];
*/
        NSString * reviewURLString = nil;
        uint32_t random = arc4random_uniform(2);
        if(0 == random)
        {
            reviewURLString = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/customerreviews/page=%ld/id=%@/sortBy=mostRecent/xml",
                                      self.countryDetails[@"countryCode"], self.page, self.applicationDetails[@"applicationId"]];
        }
        else
        {
            reviewURLString = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/customerreviews/page=%ld/id=%@/xml",
                               self.countryDetails[@"countryCode"], self.page, self.applicationDetails[@"applicationId"]];
        }

        targetURL     = [[NSURL alloc] initWithString: reviewURLString];
    } // End of self

    return self;
}

- (NSString*) reviewURL
{
    return targetURL.path;
}

- (id) initWithReviewCollectionOperation: (AWReviewCollectorOperation*) existingReviewCollectionOperation
                                    page: (NSUInteger) page
{
    self = [self initWithApplicationDetails: existingReviewCollectionOperation.applicationDetails
                             countryDetails: existingReviewCollectionOperation.countryDetails
                                       page: page];
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        [super main];

        // Raise our delegate
        [self.delegate reviewCollectionOperationDidStart: self
                                    withApplicationNamed: self.applicationDetails[@"name"]];

    /*
        ---- Json does not have review date. So we do not download using it.

        // Attempt JSON
        if([self downloadReviewsJSON])
        {
             NSLog(@"Finished downloading reviews in country: %@ for application %@.",
             self.country.name,
             self.application.name
             );
            return;
        }
    */

        // Attempt to download via XML
        if (![self isCancelled])
        {
            [self downloadReviewsXML];
        }

    } // End of autoreleasePool

    if (![self isCancelled])
    {
        [self.delegate reviewCollectionOperationDidFinish: self];
    }

    return;
}
/*
- (BOOL) downloadReviewsJSON
{
    NSString * reviewURLString = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/customerreviews/page=%ld/id=%@/sortBy=mostRecent/json",
                                  country.countryCode, (unsigned long)page, application.applicationId];

    NSError __autoreleasing * error = nil;

    NSData * reviewData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: reviewURLString]
                                                        options: NSDataReadingUncached
                                                          error: &error];

    if(nil != error)
    {
        NSLog(@"Error getting review data: %@. (URL: %@).",
              error.localizedDescription, reviewURLString);

        NSLog(@"Error: %@", error);
        return false;
    }

    NSDictionary * details = [NSJSONSerialization JSONObjectWithData: reviewData
                                                             options: kNilOptions
                                                               error: &error];

    NSDictionary * feed  = [details objectForKey: @"feed"];
    NSArray * entries    = [feed objectForKey: @"entry"];

    NSUInteger voteArray = 0;

    // Loop through our entries
    for(NSDictionary * entry in entries)
    {
        // Look for rankings. Those are the entries with voteSum
        if(![[entry allKeys] containsObject: @"im:voteSum"])
        {
            continue;
        }

        NSString * temp        = [[[entry objectForKey: @"author"] objectForKey: @"uri"] objectForKey: @"label"];

        NSString * reviewId    = [[entry objectForKey: @"id"] objectForKey: @"label"];
        NSString * reviewTitle = [[entry objectForKey: @"title"] objectForKey: @"label"];
        NSString * appVersion  = [[entry objectForKey: @"im:version"] objectForKey: @"label"];
        NSString * rating      = [[entry objectForKey: @"im:rating"] objectForKey: @"label"];
        NSString * details     = [[entry objectForKey: @"content"] objectForKey: @"label"];
        NSString * author      = [[[entry objectForKey: @"author"] objectForKey: @"name"] objectForKey: @"label"];

        if(NSNotFound == [temp rangeOfString: [NSString stringWithFormat: @"itunes.apple.com/%@", country.countryCode] options: NSCaseInsensitiveSearch].location)
        {
            [counted addObject: country.name];
            NSLog(@"\r\n\r\nTest: %@", [counted componentsJoinedByString: @", "]);
            return true;
        }

        ++voteArray;
    } // End of entries loop


    NSLog(@"Entries: %lu", (unsigned long)voteArray);
    return true;
} // End of main
*/
- (BOOL) downloadReviewsXML
{
    NSData * reviewData = nil;
    NSError __autoreleasing * error = nil;

    for(NSUInteger attempt = 0; attempt < 5; ++attempt)
    {
        NSURLResponse * response = nil;

        // Remove any existing cookies
        NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookiesForURL: [NSURL URLWithString:@"https://itunes.apple.com"]];

        for (NSHTTPCookie *cookie in cookies)
        {
            [cookieStorage deleteCookie:cookie];
        } // End of cookies

        NSMutableURLRequest * request =
            [NSMutableURLRequest requestWithURL: targetURL
                                    cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                timeoutInterval: 10];

        [request setValue: @"gzip"
       forHTTPHeaderField: @"Accept-Encoding"];

        [request setValue:@"https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/28.0.0.11.5.0.9.3.3.1.0.13.3.1.1.0"
       forHTTPHeaderField: @"Referer"];

        [request setValue: @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
       forHTTPHeaderField: @"User-Agent"];

        // Get our reviewData
        reviewData = [NSURLConnection sendSynchronousRequest: request
                                           returningResponse: &response
                                                       error: &error];

        if(nil != error || nil == reviewData || 0 == reviewData.length)
        {
            NSLog(@"Failed to get review data: Error: %@. (URL: %@). Review data length: %@.",
                  error.localizedDescription, targetURL.path,
                  nil == reviewData ? @"<nil>" : [NSString stringWithFormat: @"%ld", reviewData.length]);

            if(nil != response)
            {
                NSHTTPURLResponse * test = (NSHTTPURLResponse*)response;
                NSInteger statusCode = [test statusCode];
                NSLog(@"Status code: %ld", statusCode);

                // Apple is slowing us down. Thats ok. Wait then try again.
                if(403 == statusCode)
                {
                    [self.delegate reviewCollectionOperationReceived403: self];
                    return false;
                }
                else
                {
                    NSLog(@"Status code was %ld (attempt #%ld). Will retry.", statusCode, attempt);
                    // Other error. Small delay and try again.
                    [NSThread sleepForTimeInterval: 2];
                    continue;
                }
            } // End of response
        }
    } // End of attempts loop

    if(nil != error || nil == reviewData || 0 == reviewData.length)
    {
        NSLog(@"Failed to get reports %@, %p", error.localizedDescription, reviewData);
        return false;
    }

//    NSLog(@"Got the XML! (From %@)", reviewURLString);

    NSXMLDocument * xmlDocument = [[NSXMLDocument alloc] initWithData: reviewData
                                                              options: 0
                                                                error: &error];
    if(nil != error)
    {
        NSLog(@"Error creating NSDocument from data. %@", error.localizedDescription);
        return false;
    } // End of error

    NSMutableArray * foundReviews = [NSMutableArray array];

    NSXMLElement * feedElement = xmlDocument.rootElement;
    [feedElement.children enumerateObjectsUsingBlock:
     ^(NSXMLNode * childNode, NSUInteger childElementIndex, BOOL * stop)
    {
        NSXMLElement * childElement = (NSXMLElement*) childNode;

        // If we are the first page, then we may need to parse more pages
        if(1 == self.page && [[childElement name] isEqualToString: @"link"])
        {
            // We only care about the last page.
            NSXMLNode * lastPageAttribute = [childElement attributeForName: @"rel"];
            NSXMLNode * hrefAttribute = [childElement attributeForName: @"href"];

            if(NULL == lastPageAttribute ||
               NULL == hrefAttribute ||
               0 == hrefAttribute.stringValue.length ||
               NSOrderedSame != [lastPageAttribute.stringValue caseInsensitiveCompare: @"last"]) return;

            NSString * matchString = hrefAttribute.stringValue;

            NSTextCheckingResult * match =
                [appleReviewPageRegularExpression firstMatchInString: matchString
                                                             options: 0
                                                               range: NSMakeRange(0, matchString.length)];

            // If we do not have the proper number of matches, then we are screwed.
            if(nil == match || match.numberOfRanges != 2) return;

            NSInteger lastPage = [[matchString substringWithRange: [match rangeAtIndex: 1]] integerValue];

            // Blah. last page is the first page. No need.
            if(1 == lastPage) return;

            // Raise the delegate. Will add more operations.
            [self.delegate reviewCollectionOperation: self hasMorePages: lastPage];

            return;
        } // End of we are the first page

        if(0 == [childElement elementsForName: @"im:voteSum"].count)
        {
            return;
        }

        NSString * reviewId    = [self valueForElement: childElement childNamed: @"id"];
        NSString * reviewTitle = [self valueForElement: childElement childNamed: @"title"];
        NSString * appVersion  = [self valueForElement: childElement childNamed: @"im:version"];
        NSString * rating      = [self valueForElement: childElement childNamed: @"im:rating"];
        NSString * details     = [self valueForElement: childElement childNamed: @"content"];
        NSString * reviewUpdatedString = [self valueForElement: childElement childNamed: @"updated"];

        NSArray * authorElements = [childElement elementsForName: @"author"];
        if(0 == authorElements.count)
        {
            NSLog(@"Unable to process a review in url %@. Author element has no children.",
                      targetURL.path);
            return;
        }

        NSXMLElement * authorElement = authorElements[0];
        NSArray * authorNameElements = [authorElement elementsForName: @"name"];
        if(0 == authorNameElements.count)
        {
            NSLog(@"Unable to process a review in url %@. Author name element has no children.",
                      targetURL.path);
            return;
        }

        NSString * author      = [authorNameElements[0] stringValue];

        if(
           0 == reviewId.length ||
           0 == reviewTitle.length ||
           0 == appVersion.length ||
           0 == rating.length ||
           0 == details.length ||
           0 == reviewUpdatedString.length ||
           0 == author.length
           )
        {
            NSLog(@"Unable to process a review in url %@. Some of the details were empty.",
                      targetURL.path);
            return;
        } // End of date values are empty

        __block NSDate   * reviewUpdated;

        if(nil != reviewUpdatedString && reviewUpdatedString.length > 0 && NSNotFound != [reviewUpdatedString rangeOfString: @"T"].location)
        {
            reviewUpdatedString = [reviewUpdatedString substringToIndex: [reviewUpdatedString rangeOfString: @"T"].location + 6];

            reviewUpdated = [dateFormatter dateFromString: reviewUpdatedString];
        } // End of set the review update string

        if(nil == reviewUpdated)
        {
            NSLog(@"Unable to process a review in url %@. ReviewUpdate could not be processed.",
                      targetURL.path);
            return;
        } // End of reviewUpdated was invalid

        if([self isCancelled])
        {
            *stop = YES;
            return;
        }

        if([appVersion isEqualTo: @"0"])
        {
            return;
        } // End of invalid review app version

        // Add our reviews
        [foundReviews addObject: @{
                                      @"reviewId": [NSNumber numberWithInteger: reviewId.integerValue],
                                      @"title": reviewTitle,
                                      @"stars": [NSNumber numberWithInt: rating.intValue],
                                      @"reviewer": author,
                                      @"content": details,
                                      @"appVersion": appVersion,
                                      @"lastUpdated": reviewUpdated,

                                      @"countryCode": self.countryDetails[@"countryCode"],
                                      @"applicationId": self.applicationDetails[@"applicationId"]
                                      }];
    }];

    // If we have reviews, we will insert them
    if(foundReviews.count > 0)
    {
        [self.delegate reviewCollectionOperation: self hasReviews: [foundReviews copy]];
    } // End of we had reviews

    return true;
} // End of downloadReviewXml

- (NSString*) valueForElement: (NSXMLElement*) element childNamed: (NSString*) childName
{
    NSArray * entries = [element elementsForName: childName];

    // Incase we have more than one entry
    for(NSXMLElement * childElement in entries)
    {
        NSXMLNode * typeAttribute = [childElement attributeForName: @"type"];

        if(nil != typeAttribute && NSOrderedSame == [[typeAttribute stringValue] caseInsensitiveCompare: @"text"])
        {
            return childElement.stringValue;
        }
    }

    // No entries? No result!
    if(0 == entries.count) return nil;

    NSXMLElement * firstElement = entries[0];
    return firstElement.stringValue;
}

@end
