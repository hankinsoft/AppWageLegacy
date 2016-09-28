//
//  IconCollectorOperation.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/18/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Application;

@protocol AWIconCollectionProtocol <NSObject>

- (void) receivedIconForApplicationId: (NSNumber*) applicationId;

@optional
- (void) receivedErrorForApplicationId: (NSNumber*) applicationId error: (NSError*) error;

@end

@interface IconCollectorOperation : NSOperation

@property(nonatomic,retain) NSNumber * applicationId;
@property(nonatomic,assign) BOOL shouldRoundIcon;
@property(nonatomic,weak)   id<AWIconCollectionProtocol> delegate;

@end
