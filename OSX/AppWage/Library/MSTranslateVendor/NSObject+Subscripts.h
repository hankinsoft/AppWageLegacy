//
//  NSObject+Subscripts.h
//  MSTranslateVendor
//
//  Created by SHIM MIN SEOK on 13. 1. 14..
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef _NSObject_Subscripts_H
#define _NSObject_Subscripts_H

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@interface NSDictionary(subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary(subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
@end

@interface NSArray(subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray(subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
#endif
#endif