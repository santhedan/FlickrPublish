//
//  AccessToken.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface AccessToken : BaseRequest

@property (nonatomic, strong) NSString* callbaclUrl;

@property (nonatomic, strong) NSString* verifier;

@property (nonatomic, strong) NSString* token;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Verifier: (NSString *) verifier;

- (NSString *) getUrl;

@end
