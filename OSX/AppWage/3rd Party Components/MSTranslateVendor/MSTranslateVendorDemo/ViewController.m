//
//  ViewController.m
//  MSTranslateVendorDemo
//
//  Created by Minseok Shim on 13. 1. 14..
//  Copyright (c) 2013 Minseok Shim. All rights reserved.
//

#import "ViewController.h"
#import "MSTranslateAccessTokenRequester.h"
#import "MSTranslateVendor.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (strong, nonatomic) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad
{
    //Must be called before used to MSTranslateVendor
    [[MSTranslateAccessTokenRequester sharedRequester] requestSynchronousAccessToken:CLIENT_ID clientSecret:CLIENT_SECRET];
    
    [self testMethod1];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)testMethod1
{
    MSTranslateVendor *vendor = [[MSTranslateVendor alloc] init];

    [vendor requestTranslate:@"독도는 한국 영토 입니다." from:@"ko" to:@"en" blockWithSuccess:
     ^(NSString *translatedText)
     {
         NSLog(@"translatedText: %@", translatedText);
     }
                     failure:^(NSError *error)
     {
         NSLog(@"error_translate: %@", error);
     }];
    
    [vendor requestDetectTextLanguage:@"독도는 한국 영토 입니다." blockWithSuccess:
     ^(NSString *language)
     {
         NSLog(@"language:%@", language);
     }
                              failure:
     ^(NSError *error)
     {
         NSLog(@"error_language: %@", error);
     }];
        
    [vendor requestSpeakingText:@"Dokdo is Korean territory." language:@"en" blockWithSuccess:
     ^(NSData *streamData)
     {
         NSError *error;
         /*
          ****In ARC following code not working. is ARC bug.
          
          AVAudipPlayer *player = [[AVAudioPlayer alloc] initWithData:streamData error:&error];
          [player play];
          
          how is solved? AVAudioPlayer set a property strong. refer a following code.
          */
         
         self.player = [[AVAudioPlayer alloc] initWithData:streamData error:&error];
         [_player play];
     }
                        failure:
     ^(NSError *error)
     {
         NSLog(@"error_speak: %@", error);
     }];
    
    [vendor requestBreakSentences:@"Dokdo est un territoire de la République de Corée. Géographiquement situé dans l'est de la République de Corée. Historiquement, géographiquement Vonage Dokdo est clairement le territoire de la République de Corée." language:@"fr" blockWithSuccess:^(NSDictionary *sentencesDict){
        
        NSLog(@"sentences_dict:%@", sentencesDict);
        
    }
                          failure:^(NSError *error)
     {
         
     }];
    
    [vendor requestTranslateArray:@[@"만나서 반갑습니다.", @"이 라이브러리가 당신에게 조금이나마 도움이 되기를 바랍니다.", @"최선을 다하겠습니다. 감사합니다."] from: @"ko" to:@"en" blockWithSuccess:^(NSArray *translatedTextArray) {
        
        NSLog(@"translatedTextArray:%@", translatedTextArray);
    } failure:^(NSError *error) {
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
