//
//  LVDebounce.h
//  LayerVault
//
//  Created by Kelly Sutton on 7/23/13.
//  Copyright (c) 2013 LayerVault. Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface LVDebounce : NSObject

+ (void)fireAfter:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo;

@end