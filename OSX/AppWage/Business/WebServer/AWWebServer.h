//
//  WebServer.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-05.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWWebServer : NSObject

+ (instancetype) sharedInstance;

- (void) startServerOnPort: (NSUInteger) port;
- (void) stopServer;

@end
