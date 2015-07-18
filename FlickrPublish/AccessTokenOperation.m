//
//  AccessTokenOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "AccessTokenOperation.h"

@interface AccessTokenOperation()

@property (nonatomic, strong) AccessToken* request;

@property (nonatomic, strong) id<AccessTokenResponseHandler> handler;

@property (nonatomic, strong) NSString* fullName;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* nsid;

@property (nonatomic, strong) NSString* userName;

@end

@implementation AccessTokenOperation

- (instancetype) initWithRequest: (AccessToken *) request Handler: (id<AccessTokenResponseHandler>) handler
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.handler = handler;
        //
        self.fullName = nil;
        self.token = nil;
        self.secret = nil;
        self.nsid = nil;
        self.userName = nil;
    }
    return self;
}

- (void) main
{
    NSError* error = nil;
    // Create a NSURL from the request
    NSURL *url = [NSURL URLWithString:[self.request getUrl]];
    NSString* response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error == nil)
    {
        // Check if the response starts with oauth_callback_confirmed=true
        if ([response containsString:@"fullname"])
        {
            // Split the string using &
            NSArray* respList = [response componentsSeparatedByString:@"&"];
            // Iterate and find token and secret
            for (NSString* entry in respList)
            {
                NSArray* entryList = [entry componentsSeparatedByString:@"="];
                // Get the key and value
                NSString* key = [entryList objectAtIndex:0];
                NSString* value = [entryList objectAtIndex:1];
                if ([key isEqualToString:@"fullname"])
                {
                    self.fullName = value;
                }
                else if ([key isEqualToString:@"oauth_token"])
                {
                    self.token = value;
                }
                else if ([key isEqualToString:@"oauth_token_secret"])
                {
                    self.secret = value;
                }
                else if ([key isEqualToString:@"user_nsid"])
                {
                    self.nsid = value;
                }
                else if ([key isEqualToString:@"username"])
                {
                    self.userName = value;
                }
            }
        }
    }
    //
    [self.handler receivedRequestToken:self.token Secret:self.secret FullName:self.fullName UserNSID:self.nsid UserName:self.userName];
}

@end
