//
//  OAuthRequest.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface RequestToken : BaseRequest

@property (nonatomic, strong) NSString* nonce;

@property (nonatomic, strong) NSString* timeStamp;

@property (nonatomic, strong) NSString* consumerKey;

@property (nonatomic, strong) NSString* consumerSecret;

@property (nonatomic, strong) NSString* signatureMethod;

@property (nonatomic, strong) NSString* version;

@property (nonatomic, strong) NSString* callbackUrl;

@property (nonatomic, strong) NSString* signature;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret CallbackUrl: (NSString *) callbackUrl;

- (NSString *) getUrl;

@end
