//
//  WebServer.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-05.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWWebServer.h"
#import <HTTPServer.h>
#import "AWHTTPConnection.h"

@implementation AWWebServer
{
    HTTPServer          * httpServer;
}

+(instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static AWWebServer *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWWebServer alloc] init];
    });

    return sharedInstance;
}

- (void) startServerOnPort: (NSUInteger) port
{
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];

	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];

	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort: port];

	// We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
	// This allows us to do custom password protection on our sensitive directories.
	[httpServer setConnectionClass: [AWHTTPConnection class]];

	NSError *error;
	BOOL success = [httpServer start:&error];
    if(!success)
    {
        NSLog(@"Failed to start the webserver: %@.", error.localizedDescription);
        return;
    }
}

- (void) stopServer
{
    [httpServer stop];
}

@end
