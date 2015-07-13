//
//  RequestTokenOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "RequestTokenOperation.h"

@interface RequestTokenOperation()

@property (nonatomic, strong) RequestToken* request;

@property (nonatomic, strong) id<RequestTokenResponseHandler> handler;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* secret;

@end

@implementation RequestTokenOperation

- (instancetype) initWithRequest: (RequestToken *) request Handler: (id<RequestTokenResponseHandler>) handler
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.handler = handler;
        //
        self.token = nil;
        self.secret = nil;
    }
    return self;
}

- (void) main
{
    NSError* error = nil;
    // Create a NSURL from the request
    NSURL *url = [NSURL URLWithString:[self.request getUrl]];
    NSString* response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"response -> %@", response);
    if (error == nil)
    {
        // Check if the response starts with oauth_callback_confirmed=true
        if ([response containsString:@"oauth_callback_confirmed=true"])
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
                if ([key isEqualToString:@"oauth_token"])
                {
                    self.token = value;
                }
                else if ([key isEqualToString:@"oauth_token_secret"])
                {
                    self.secret = value;
                }
            }
        }
    }
    // Call the handler
    [self.handler receivedRequestToken:self.token Secret:self.secret];
}

@end
