//
//  MSTranslateVendor.h
//  MSTranslateVendor
//
//  Software License Agreement (BSD License)
//
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in
//  the documentation and/or other materials provided with the
//  distribution.
//
//  3. Neither the name of Infrae nor the names of its contributors may
//  be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL INFRAE OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

enum
{
    MP3_FORMAT,
    WAV_FORMAT
};
typedef NSUInteger MSRequestAudioFormat;

@interface MSTranslateVendor : NSObject<NSXMLParserDelegate>

//default is getting a [MSTranslateAccessTokenRequester sharedRequester].accessToken
@property (nonatomic, strong) NSString *accessToken;

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
@end
