//
//  NSString+Extend.m
//  MSTranslateVendor
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "NSString+Extend.h"

@implementation NSString (Extend)

- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag
{
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    return [self rangeOfString:aString options:mask].length > 0;
}

- (BOOL)containsString:(NSString *)aString
{
    return [self containsString:aString ignoringCase:NO];
}

- (NSString *)urlEncodedUTF8String
{
    return (__bridge_transfer id)CFURLCreateStringByAddingPercentEscapes(0, (CFStringRef)self, 0,
                                                       (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);
}

@end
