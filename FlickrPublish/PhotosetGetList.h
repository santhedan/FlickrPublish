//
//  PhotosetGetList.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 13/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PhotosetGetList : BaseRequest

@property (nonatomic, strong) NSString* consumerKey;

@property (nonatomic, strong) NSString* consumerSecret;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* signature;

@property (nonatomic, strong) NSString* userId;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* nonce;

@property (nonatomic, strong) NSString* timeStamp;

@property (nonatomic, strong) NSString* signatureMethod;

@property (nonatomic, strong) NSString* version;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token UserID: (NSString *) userId;

- (NSString *) getUrl;

@end
