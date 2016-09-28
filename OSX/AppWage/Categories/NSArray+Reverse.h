//
//  NSArray+Reverse.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-10.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Reverse)

- (NSArray *)reversedArray;

@end

@interface NSMutableArray (Reverse)

- (void)reverse;

@end