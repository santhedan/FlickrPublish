//
//  OAuthRequest.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface RequestToken : BaseRequest

@property (nonatomic, strong) NSString* callbackUrl;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret CallbackUrl: (NSString *) callbackUrl;

- (NSString *) getUrl;

@end
