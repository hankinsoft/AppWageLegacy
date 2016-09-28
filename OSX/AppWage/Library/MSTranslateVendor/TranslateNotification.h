//
//  TranslateNotification.h
//  MSTranslateVendorDemo
//
//  Created by SHIM MIN SEOK on 13. 7. 14..
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRequestTranslate       @"requestTranslate"
#define kRequestTranslateArray  @"requestTranslateArray"
#define kRequestDetectLanguage  @"requestDetectLanguage"
#define kRequestBreakSentences  @"requestBreakSentences"

@interface TranslateNotification : NSObject

@property (nonatomic, strong) id translateNotification;
@property (nonatomic, strong) NSMutableArray * translateArrayNotification;
@property (nonatomic, strong) id detectNotification;
@property (nonatomic, strong) id breakSentencesNotification;
+ (TranslateNotification*)sharedObject;
@end
