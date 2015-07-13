//
//  AccessTokenOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"

@protocol AccessTokenResponseHandler <NSObject>

@required

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret FullName: (NSString *) fullName UserNSID: (NSString *) userNSID UserName: (NSString *) userName;

@end

@interface AccessTokenOperation : NSOperation

- (instancetype) initWithRequest: (AccessToken *) request Handler: (id<AccessTokenResponseHandler>) handler;

@end
