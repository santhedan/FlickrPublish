//
//  BaseRequest.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEscapeChars @"`!@#$^&*()=+[]\\{}|;':\",/<>?"

@interface BaseRequest : NSObject

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) NSString* httpVerb;

@property (nonatomic, strong) NSString* nonce;

@property (nonatomic, strong) NSString* timeStamp;

@property (nonatomic, strong) NSString* consumerKey;

@property (nonatomic, strong) NSString* consumerSecret;

@property (nonatomic, strong) NSString* signatureMethod;

@property (nonatomic, strong) NSString* version;

@property (nonatomic, strong) NSString* signature;

@end
