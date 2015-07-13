//
//  RequestTokenOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestToken.h"

@protocol RequestTokenResponseHandler <NSObject>

@required

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret;

@end

@interface RequestTokenOperation : NSOperation

- (instancetype) initWithRequest: (RequestToken *) request Handler: (id<RequestTokenResponseHandler>) handler;

@end
