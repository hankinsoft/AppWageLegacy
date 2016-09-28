//
//  NSXMLParser+Taged.m
//  MSTranslateVendorDemo
//
//  Created by Minseok Shim on 13. 1. 15..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "NSXMLParser+Taged.h"

@implementation NSXMLParser (Taged)
static NSString *kTagKey = @"tagKey";

- (NSInteger)tag
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(kTagKey)) integerValue];
}

- (void)setTag:(NSInteger)tag
{
    objc_setAssociatedObject(self, (__bridge const void *)(kTagKey), [NSNumber numberWithInteger:tag], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
