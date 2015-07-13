//
//  OAuthController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestTokenOperation.h"
#import "AccessTokenOperation.h"

@interface OAuthController : UIViewController <RequestTokenResponseHandler, AccessTokenResponseHandler>

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) handleKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Verifier: (NSString *) verifier;

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret FullName: (NSString *) fullName UserNSID: (NSString *) userNSID UserName: (NSString *) userName;

@end
