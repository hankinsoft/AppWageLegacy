MSTranslateVendor
=================

[![Version](http://cocoapod-badges.herokuapp.com/v/MSTranslateVendor/badge.png)](http://cocoapod-badges.herokuapp.com/v/MSTranslateVendor/badge.png)
[![Platform](http://cocoapod-badges.herokuapp.com/p/MSTranslateVendor/badge.png)](http://cocoapod-badges.herokuapp.com/p/MSTranslateVendor/badge.png)

Microsoft Translate iOS API

Microsoft ends free Bing Search API, moves to paid service on Azure Marketplace. Bing translator is deprecated, and it forces developers to use a more complicated way than the previous way using AppID.

The Microsoft Translate new API involves a temporal token, named as access token, which will expire in 10 minutes after you get it. before you get a token, your application must be registered.

Please refer to the steps below.(Microsoft Azure Market Join step is omitted.) 

(1) access https://datamarket.azure.com/developer/applications and register the client application (that is, the app using the API), where you can create your own Client ID and Name, and you also have to type in
redirect URI which should be a valid URL address (like "http://www.....");
  
![](https://s3.amazonaws.com/Y1J8k27YH1U3r6LeEwCOP2cvY97xxXTs/img0.png)

(2) If you complete the registration, the following screen appears. 
  
![](https://s3.amazonaws.com/Y1J8k27YH1U3r6LeEwCOP2cvY97xxXTs/img1.png)

For more information: http://msdn.microsoft.com/en-us/library/hh454950.aspx

MSTranslateVendor was constructed based on Microsoft Translator V2 HTTP. and is based on block-based.  As much as possible to not have a dependency on another framework is designed Cocoa library only was used.

## Installation ##

MSTranslateVendor is possible via CocoaPods. Just add the following to your Podfile.

    platform :ios
    pod 'MSTranslateVendor'

Another way to, drag the included <b>MSTranslateVendor</b> folder into your project.

## Usage ##

In <b>`MSTranslateAccessTokenRequester.h`</b> `CLIENT_ID`, `CLIENT_SECRET` must change to Client id and Client secret your registered applications. refer a above image. 

    #define CLIENT_ID       @""
    #define CLIENT_SECRET   @""

These classes was written under the ARC. Be sure to specify `-fobjc-arc` the 'Compile Sources' Build Phase for each file if you aren't using ARC project-wide

## Supported Method ##

	- (void)requestTranslate:(NSString *)text
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock;

	//if 'from' is a nil, 'from language' automatically detect.
	- (void)requestTranslate:(NSString *)text
                    from:(NSString *)from
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock;

	- (void)requestTranslateArray:(NSArray *)translateArray
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock;

	//if 'from' is a nil, 'from language' automatically detect.
	- (void)requestTranslateArray:(NSArray *)translateArray
                         from:(NSString *)from
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock;

	- (void)requestDetectTextLanguage:(NSString *)text
                 blockWithSuccess:(void (^)(NSString *language))successBlock
                          failure:(void (^)(NSError *error))failureBlock;

	//return audio type default(.mp3)
	- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock;

	- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
                audioFormat:(MSRequestAudioFormat)requestAudioFormat
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock;

	//return number of a letter. a key is began from @"1",... @"1" means first sentence.
	- (void)requestBreakSentences:(NSString *)text
                   language:(NSString *)language
           blockWithSuccess:(void (^)(NSDictionary *sentencesDict))successBlock
                    failure:(void (^)(NSError *error))failureBlock;

## Sample Code ##

    #import "MSTranslateAccessTokenRequester.h"
    #import "MSTranslateVendor.h"
    
    /*
      The value of access token can be used for subsequent calls to the Microsoft Translator API. 
      The access token expires after 10 minutes. It is always better to check elapsed time between time at which token 
      issued and current time.
    */
    [[MSTranslateAccessTokenRequester sharedRequester] requestSynchronousAccessToken:CLIENT_ID clientSecret:CLIENT_SECRET];
    
    MSTranslateVendor *vendor = [[MSTranslateVendor alloc] init];
    [vendor requestTranslate:@"독도는 대한민국 영토 입니다." from:@"ko" to:@"en" blockWithSuccess:
     ^(NSString *translatedText)
    {
        NSLog(@"translatedText: %@", translatedText);
    }
    failure:^(NSError *error)
    {
        NSLog(@"error_translate: %@", error);
    }];
    
    [vendor requestDetectTextLanguage:@"독도는 대한민국 영토 입니다." blockWithSuccess:
     ^(NSString *language)
    {
        NSLog(@"language:%@", language);
    }
    failure:
     ^(NSError *error)
    {
        NSLog(@"error_detect: %@", error);
    }];
    
    [vendor requestSpeakingText:@"Dokdo is korean territory." language:@"en" blockWithSuccess:
     ^(NSData *streamData)
     {
         NSError *error;
         self.player = [[AVAudioPlayer alloc] initWithData:streamData error:&error];
         [_player play];
     }
     failure:
     ^(NSError *error)
     {
         NSLog(@"error_speak: %@", error);
     }];
     
    [vendor requestBreakSentences:@"Dokdo est un territoire de la République de Corée. Géographiquement situé dans l'est de la République de Corée.
                                     Historiquement, géographiquement Vonage Dokdo est clairement le territoire de la République de Corée." 
                                     language:@"fr" blockWithSuccess:
     ^(NSDictionary *sentencesDict)
     {
        NSLog(@"sentences_dict:%@", sentencesDict);
     }
     failure:^(NSError *error)
     {
        
     }];
     
	[vendor requestTranslateArray:@[@"만나서 반갑습니다.", @"이 라이브러리가 당신에게 조금이나마 도움이 되기를 바랍니다.", @"최선을 다하겠습니다. 감사합니다."] from:@"ko" to:@"en" blockWithSuccess:^(NSArray *translatedTextArray) {
        
        NSLog(@"translatedTextArray:%@", translatedTextArray);
    } failure:^(NSError *error) {
        
    }];


## License ##

Software License Agreement (BSD License)

Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.

  3. Neither the name of Infrae nor the names of its contributors may
     be used to endorse or promote products derived from this software
     without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL INFRAE OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Contact ##

bitmapdata.com@gmail.com
