//
//  OAuthRequest.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "RequestToken.h"
#import "OFUtilities.h"

@implementation RequestToken

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret CallbackUrl: (NSString *) callbackUrl
{
    self = [super init];
    if (self)
    {
        self.httpVerb = @"GET";
        self.url = @"https://www.flickr.com/services/oauth/request_token";
        self.version = @"oauth_version=1.0";
        self.signatureMethod = @"oauth_signature_method=HMAC-SHA1";
        // timestamp
        NSString* ts = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        self.timeStamp = [NSString stringWithFormat:@"oauth_timestamp=%@", ts];
        self.nonce = [NSString stringWithFormat:@"oauth_nonce=%@", ts];
        //
        self.consumerKey = [NSString stringWithFormat:@"oauth_consumer_key=%@", key];
        //
        self.consumerSecret = [NSString stringWithFormat:@"%@&", secret];
        // Encode callback URL
        self.callbackUrl = [NSString stringWithFormat:@"oauth_callback=%@", OFEscapedURLStringFromNSStringWithExtraEscapedChars(callbackUrl, kEscapeChars)];
        //
        self.signature = [NSString stringWithFormat:@"oauth_signature=%@", [self calculateSignature]];
    }
    return self;
}

- (NSString *) calculateSignature
{
    // Create array
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // Add the values to array
    [array addObject:self.nonce];
    [array addObject:self.timeStamp];
    [array addObject:self.consumerKey];
    [array addObject:self.signatureMethod];
    [array addObject:self.version];
    [array addObject:self.callbackUrl];
    // Sort the array
    NSArray* sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    // Create string buffer
    NSMutableString* firstPart = [[NSMutableString alloc] init];
    [firstPart appendString:self.httpVerb];
    [firstPart appendString:@"&"];
    [firstPart appendString: OFEscapedURLStringFromNSStringWithExtraEscapedChars(self.url, kEscapeChars)];
    [firstPart appendString:@"&"];
    //
    NSString* data = [sortedArray componentsJoinedByString:@"&"];
    NSString* encoded = OFEscapedURLStringFromNSStringWithExtraEscapedChars(data, kEscapeChars);
    // Now append first and last part
    [firstPart appendString:encoded];
    //
    NSLog(@"Encoding data (%@)", firstPart);
    NSLog(@"Using key (%@)", self.consumerSecret);
    // Now calculate HMAC-SHA1 of data
    return OFHMACSha1Base64(self.consumerSecret, firstPart);
}

- (NSString *) getUrl
{
    return [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@&%@&%@", self.url, self.nonce, self.timeStamp, self.consumerKey, self.signatureMethod, self.version, self.signature, self.callbackUrl];
}

@end
