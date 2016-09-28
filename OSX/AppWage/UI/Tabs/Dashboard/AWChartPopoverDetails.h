//
//  AWChartPopoverDetails.h
//  AppWage
//
//  Created by Kyle Hankinson on 2016-09-01.
//  Copyright © 2016 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWChartPopoverDetails : NSObject<NSCopying>

@property(nonatomic,copy) id date;
@property(nonatomic,copy) NSNumber * index;
@property(nonatomic,copy) id identifier;
@property(nonatomic,copy) NSString * mouseLocation;
@property(nonatomic,copy) NSNumber * edge;
@property(nonatomic,copy) NSString * ammount;
@property(nonatomic,copy) NSString * country;
@property(nonatomic,copy) NSString * details;

@property(nonatomic,copy) NSNumber * percentage;
@property(nonatomic,copy) id value;

@end
