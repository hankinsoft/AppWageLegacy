//
//  MSTranslateVendor.m
//  MSTranslateVendor
//
//  Created by SHIM MIN SEOK on 13. 1. 14..
//  Copyright (c) 2013 SHIM MIN SEOK. All rights reserved.
//

#import "MSTranslateVendor.h"
#import "MSTranslateAccessTokenRequester.h"
#import "NSMutableURLRequest+WebServiceExtend.h"
#import "NSString+Extend.h"
#import "NSXMLParser+Taged.h"
#import "TranslateNotification.h"

@interface MSTranslateVendor()
{
    NSMutableData *_responseData;
    NSMutableURLRequest *_request;
    NSString *_elementString;
    NSMutableString    * elementContents;
    NSMutableArray *_attributeCollection;
    NSMutableArray *_translatedArray;
    NSMutableDictionary *_sentencesDict;
    NSUInteger _sentenceCount;
    
    NSDate              * lastAccessToken;
}
@end

@implementation MSTranslateVendor

typedef enum
{
    REQUEST_TRANSLATE_TAG,
    REQUEST_TRANSLATE_ARRAY_TAG,
    REQUEST_DETECT_TEXT_TAG,
    REQUEST_BREAKSENTENCE_TAG
}ParserTag;

#pragma mark - C functions

NSString * generateSchema(NSString *);

NSString * generateSchema(NSString * text)
{
    return [NSString stringWithFormat:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">%@></string>", text];
}

#pragma mark - Microsoft Translate Method

- (void)requestTranslate:(NSString *)text
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock
{
    [self requestTranslate:text from:nil to:to blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestTranslate:(NSString *)text
                    from:(NSString *)from
                      to:(NSString *)to
        blockWithSuccess:(void (^)(NSString *translatedText))successBlock
                 failure:(void (^)(NSError *error))failureBlock
{
    
    if(![TranslateNotification sharedObject].translateNotification)
    {
        [TranslateNotification sharedObject].translateNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestTranslate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                                 {
                                     if([noti.object[@"isSuccessful"] boolValue])
                                     {
                                         successBlock(noti.object[@"result"]);
                                     }
                                     else
                                     {
                                         failureBlock(noti.object[@"result"]);
                                     }
                                     
                                     [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].translateNotification];
                                     [TranslateNotification sharedObject].translateNotification = nil;
                                 }];
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];

    NSString *uriString = NULL;
    if(from)
    {
        uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&from=%@&to=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], from, to];
    }
    else
    {
        uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&to=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],to];
    }
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];

    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_TRANSLATE_TAG;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }
     }];
}

- (void)requestTranslateArray:(NSArray *)translateArray
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    [self requestTranslateArray:translateArray
                           from:nil
                             to:to
               blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestTranslateArray:(NSArray *)translateArray
                         from:(NSString *)from
                           to:(NSString *)to
             blockWithSuccess:(void (^)(NSArray *translatedTextArray))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    if(0 == [CLIENT_ID length] || 0 == [CLIENT_SECRET length])
    {
        NSError * failureError =
            [NSError errorWithDomain: @""
                                code: 0
                            userInfo: @{NSLocalizedDescriptionKey : @"Client id and secret must be defined"}];

        failureBlock(failureError);

        return;
    } // End of no client id or secret

    id requester = [MSTranslateAccessTokenRequester sharedRequester];
    if(![requester requestSynchronousAccessTokenIfRequired: CLIENT_ID
                                              clientSecret: CLIENT_SECRET])
    {
        failureBlock([NSError errorWithDomain: @""
                                         code: 0
                                     userInfo: @{NSLocalizedDescriptionKey : @"Failed to receive access key"}]);
        return;
    } // End of failed to translate

    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName: kRequestTranslateArray
                                                                object: nil
                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
   {
       if([noti.object[@"isSuccessful"] boolValue])
       {
           NSLog(@"MSTranslate success");
           successBlock(noti.object[@"result"]);
       }
       else
       {
           NSLog(@"MSTranslate fail");
           failureBlock(noti.object[@"result"]);
       }

       [[NSNotificationCenter defaultCenter] removeObserver: observer];
       @synchronized([TranslateNotification sharedObject].translateArrayNotification)
       {
           [[TranslateNotification sharedObject].translateArrayNotification removeObject: observer];
       } // End of synchronized
   }];

    @synchronized([TranslateNotification sharedObject].translateArrayNotification)
    {
        [[TranslateNotification sharedObject].translateArrayNotification addObject:  observer];
    } // End of synchronized

    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken];

    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"TranslateArrayRequest"];
    [root addChild: [NSXMLElement elementWithName: @"AppId"]];

    if(0 != from.length)
    {
        NSXMLElement * fromElement = [NSXMLElement elementWithName: @"From" stringValue: from];
        [root addChild: fromElement];
    } // End of from length

    NSXMLElement * optionsNode = [NSXMLElement elementWithName: @"Options"];

    NSXMLElement * categoryNode = [NSXMLElement elementWithName: @"Category"];
    [categoryNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: categoryNode];

    NSXMLElement * contentTypeNode = [NSXMLElement elementWithName: @"ContentType" stringValue: @"text/plain"];
    [contentTypeNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: contentTypeNode];

    NSXMLElement * reservedFlagsNode = [NSXMLElement elementWithName: @"ReservedFlags"];
    [reservedFlagsNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: reservedFlagsNode];

    NSXMLElement * stateNode = [NSXMLElement elementWithName: @"State"];
    [stateNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: stateNode];

    NSXMLElement * uriNode = [NSXMLElement elementWithName: @"Uri"];
    [uriNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: uriNode];

    NSXMLElement * userNode = [NSXMLElement elementWithName: @"User"];
    [userNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"]];
    [optionsNode addChild: userNode];

    [root addChild: optionsNode];

    NSXMLElement * textsNode = [NSXMLElement elementWithName: @"Texts"];
    for (NSString *text in translateArray)
    {
        NSXMLElement * stringNode = [NSXMLElement elementWithName: @"string" stringValue: text];
        [stringNode addAttribute: [NSXMLNode attributeWithName: @"xmlns" stringValue: @"http://schemas.microsoft.com/2003/10/Serialization/Arrays"]];
        [textsNode addChild: stringNode];
    } // End of for loop

    [root addChild: textsNode];
    [root addChild: [NSXMLElement elementWithName: @"To" stringValue: to]];

    NSXMLDocument *xmlRequest = [NSXMLDocument documentWithRootElement: root];
    NSData * xmlData = [xmlRequest XMLDataWithOptions: NSXMLNodePrettyPrint];

    NSURL *requestURL = [NSURL URLWithString:@"http://api.microsofttranslator.com/v2/Http.svc/TranslateArray"];

    [_request setURL:[requestURL standardizedURL]];
    [_request setHTTPMethod:@"POST"];
    [_request setHTTPBody: xmlData];
    [_request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:_appId forHTTPHeaderField:@"Authorization"];

    NSLog(@"Translate sending request (%@) on %@ thread.",
          xmlRequest,
          [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND");
    [NSURLConnection sendAsynchronousRequest: _request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSLog(@"Translate received response. Data length: %ld. Error message: %@.",
               data.length,
               error.localizedDescription);

         NSString * responseString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
         NSLog(@"Translate response is: %@", responseString);
         if(NSNotFound != [responseString rangeOfString: @"<h1>System.Runtime.Serialization.SerializationException</h1>"].location)
         {
             failureBlock([NSError errorWithDomain: @""
                                              code: 0
                                          userInfo: @{NSLocalizedDescriptionKey: responseString}]);
             return;
         }

         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_TRANSLATE_ARRAY_TAG;
         _parser.delegate = self;

         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }
         
     }];
}

- (void)requestDetectTextLanguage:(NSString *)text
                 blockWithSuccess:(void (^)(NSString *language))successBlock
                          failure:(void (^)(NSError *error))failureBlock
{
    if(![TranslateNotification sharedObject].detectNotification)
    {
        [TranslateNotification sharedObject].detectNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestDetectLanguage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].detectNotification];
                                  [TranslateNotification sharedObject].detectNotification = nil;
                              }];
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];
    
    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Detect?appId=%@&text=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_DETECT_TEXT_TAG;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }

     }];
}

- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock
{
    [self requestSpeakingText:text language:language audioFormat:MP3_FORMAT blockWithSuccess:successBlock failure:failureBlock];
}

- (void)requestSpeakingText:(NSString *)text
                   language:(NSString *)language
                audioFormat:(MSRequestAudioFormat)requestAudioFormat
           blockWithSuccess:(void (^)(NSData *audioData))successBlock
                    failure:(void (^)(NSError *error))failureBlock
{
    NSString *content_type;
    switch (requestAudioFormat)
    {
        case MP3_FORMAT:
            content_type = @"audio/wav";
            break;
        case WAV_FORMAT:
            content_type = @"audio/mp3";
            break;
        default:
            content_type = @"audio/mp3";
            break;
    }
    
    _request = [[NSMutableURLRequest alloc] init];
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];
    
    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Speak?appId=%@&text=%@&language=%@&format=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], language, content_type];
    
    NSURL *uri = [NSURL URLWithString:uriString];
    
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         successBlock(data);
         
         if(error)
         {
             failureBlock(error);
         }
     }];
}

- (void)requestBreakSentences:(NSString *)text
                     language:(NSString *)language
             blockWithSuccess:(void (^)(NSDictionary *sentencesDict))successBlock
                      failure:(void (^)(NSError *error))failureBlock
{
    
    if(![TranslateNotification sharedObject].breakSentencesNotification)
    {
        [TranslateNotification sharedObject].breakSentencesNotification = [[NSNotificationCenter defaultCenter] addObserverForName:kRequestBreakSentences object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *noti)
                              {
                                  if([noti.object[@"isSuccessful"] boolValue])
                                  {
                                      successBlock(noti.object[@"result"]);
                                  }
                                  else
                                  {
                                      failureBlock(noti.object[@"result"]);
                                  }
                                  
                                  [[NSNotificationCenter defaultCenter] removeObserver:[TranslateNotification sharedObject].breakSentencesNotification];
                                  [TranslateNotification sharedObject].breakSentencesNotification = nil;
                              }];
    }
    
    NSString *_appId = [[NSString stringWithFormat:@"Bearer %@", (!_accessToken)?[MSTranslateAccessTokenRequester sharedRequester].accessToken:_accessToken] urlEncodedUTF8String];

    NSString *uriString= [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/BreakSentences?appId=%@&text=%@&language=%@", _appId, [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], language];
       
    NSURL *uri = [NSURL URLWithString:uriString];
        
    [_request setURL:[uri standardizedURL]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSXMLParser *_parser = [[NSXMLParser alloc] initWithData:data];
         _parser.tag = REQUEST_BREAKSENTENCE_TAG;
         _parser.delegate = self;
         
         if(error)
         {
             failureBlock(error);
         }
         if(![_parser parse])
         {
             failureBlock(_parser.parserError);
         }
     }];
}

#pragma mark - NSXMLParser Delegate

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _elementString = NULL;
    _attributeCollection = [@[] mutableCopy];
    _translatedArray = [@[] mutableCopy];
    _sentencesDict = [@{} mutableCopy];
    _sentenceCount = 1;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _responseData = nil;
    
    if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([_translatedArray count])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslateArray object:@{@"result" : _translatedArray, @"isSuccessful": @YES}];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslateArray object:@{@"result" :[NSNull null], @"isSuccessful": @NO}];
        }
    }
    if(parser.tag == REQUEST_BREAKSENTENCE_TAG)
    {
        if([[_sentencesDict allKeys] count])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestBreakSentences object:@{@"result" : _sentencesDict, @"isSuccessful": @YES}];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _elementString = [elementName copy];

    if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([elementName isEqualToString:@"TranslatedText"])
        {
            elementContents = [NSMutableString string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(parser.tag == REQUEST_TRANSLATE_TAG)
    {
        if([_elementString isEqualToString:@"string"])
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : string, @"isSuccessful": @YES}];
        else if([_elementString isEqualToString:@"h1"])
        {
            if([string isEqualToString:@"Argument Exception"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Argument Exception" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-3 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
        else if([_elementString isEqualToString:@"p"])
        {
            if([string isEqualToString:@"Invalid appId"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Invalid appId" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-4 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestTranslate object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }

    }
    else if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([_elementString isEqualToString:@"TranslatedText"])
        {
            [elementContents appendString: string];
        }
    }
    else if(parser.tag == REQUEST_DETECT_TEXT_TAG)
    {
        if([_elementString isEqualToString:@"string"])
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : string, @"isSuccessful": @YES}];
        else if([_elementString isEqualToString:@"h1"])
        {
            if([string isEqualToString:@"Argument Exception"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Argument Exception" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-3 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
        else if([_elementString isEqualToString:@"p"])
        {
            if([string isEqualToString:@"Invalid appId"])
            {
                NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
                [errorInfo setValue:@"Invalid appId" forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"MSTranslateVendorError" code:-4 userInfo:errorInfo];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kRequestDetectLanguage object:@{@"result" : error, @"isSuccessful": @NO}];
            }
        }
    }
    else if(parser.tag == REQUEST_BREAKSENTENCE_TAG)
    {
        if([_elementString isEqualToString:@"int"])
        {
            [_sentencesDict setValue:string forKey:[NSString stringWithFormat:@"%lu", (unsigned long)_sentenceCount]];
            
            _sentenceCount ++;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(parser.tag == REQUEST_TRANSLATE_ARRAY_TAG)
    {
        if([elementName isEqualToString:@"TranslatedText"])
        {
            [_translatedArray addObject: [elementContents copy]];
        }
    } // End of translated
}

@end