//
//  HTTPJsonReponse.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-05.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "HTTPJsonReponse.h"

@implementation HTTPJsonReponse

- (NSDictionary *)httpHeaders
{
    NSString *key   = @"Content-Type";
    NSString *value = @"application/json";

    return [NSDictionary dictionaryWithObjectsAndKeys:value, key, nil];
} // End of httpHeaders

@end
