//
//  NSMutableURLRequest+WebServiceExtend.m
//  MSTranslateVendor
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "NSMutableURLRequest+WebServiceExtend.h"
#import "NSString+Extend.h"

@implementation NSMutableURLRequest (WebServiceExtend)

+ (NSString *)encodeFormPostParameters: (NSDictionary *)parameters
{
    NSMutableString *formPostParams = [[NSMutableString alloc] init];
    
    NSEnumerator *keys = [parameters keyEnumerator];
    
    NSString *name = [keys nextObject];
    while (nil != name) {
        NSString *encodedValue = [[parameters objectForKey: name] urlEncodedUTF8String];
        
        [formPostParams appendString: name];
        [formPostParams appendString: @"="];
        [formPostParams appendString: encodedValue];
        
        name = [keys nextObject];
        
        if (nil != name) {
            [formPostParams appendString: @"&"];
        }
    }
    
    return formPostParams;
}

- (void)setFormPostParameters: (NSDictionary *)parameters
{
    NSString *formPostParams = [NSMutableURLRequest encodeFormPostParameters: parameters];
    
    [self setHTTPBody: [formPostParams dataUsingEncoding: NSUTF8StringEncoding]];
    [self setValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
}

@end
