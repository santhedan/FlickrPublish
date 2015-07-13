//
//  FlickrBaseRequest.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface FlickrBaseRequest : BaseRequest

@property (nonatomic, strong) NSString* methodName;

@property (nonatomic, strong) NSString* apiKey;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* apiSignature;

@end
