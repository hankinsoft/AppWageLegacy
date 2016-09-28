//
//  ReviewImportHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWReportImportHelper : NSObject

- (id) initWithWindow: (NSWindow*) parentWindow;

- (void) startImportViaDialog;
- (void) importWithUrls: (NSArray*) urls;

@end
