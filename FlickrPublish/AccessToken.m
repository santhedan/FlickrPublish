//
//  AccessToken.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "AccessToken.h"
#import "OFUtilities.h"

@implementation AccessToken

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Verifier: (NSString *) verifier
{
    self = [super init];
    if (self)
    {
        // Additional initialization
        self.httpVerb = @"GET";
        self.url = @"https://www.flickr.com/services/oauth/access_token";
        self.version = @"oauth_version=1.0";
        self.signatureMethod = @"oauth_signature_method=HMAC-SHA1";
        // timestamp
        NSString* ts = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        self.timeStamp = [NSString stringWithFormat:@"oauth_timestamp=%@", ts];
        self.nonce = [NSString stringWithFormat:@"oauth_nonce=%@", ts];
        //
        self.consumerKey = [NSString stringWithFormat:@"oauth_consumer_key=%@", key];
        self.consumerSecret = secret;
        //
        self.token = [NSString stringWithFormat:@"oauth_token=%@", token];
        self.verifier = [NSString stringWithFormat:@"oauth_verifier=%@", verifier];
        //
        NSString* signow = [self calculateSignature];
        signow = [signow stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSLog(@"accesstoken signow 1 -> %@",  signow);
        self.signature = [NSString stringWithFormat:@"oauth_signature=%@", signow];
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
    [array addObject:self.verifier];
    [array addObject:self.consumerKey];
    [array addObject:self.signatureMethod];
    [array addObject:self.version];
    [array addObject:self.token];
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
    NSString* signow = [self calculateSignature];
    NSLog(@"accesstoken signow 2 -> %@",  signow);
    return [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@&%@&%@&%@",self.url, self.nonce, self.timeStamp, self.verifier, self.consumerKey, self.signatureMethod, self.version, self.token, self.signature];
}

@end
