//
//  GroupsPoolsGetPhotos.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupsPoolsGetPhotos.h"
#import "OFUtilities.h"

@implementation GroupsPoolsGetPhotos

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token GroupId: (NSString *) groupId
{
    self = [super init];
    if (self)
    {
        // Additional initialization
        self.httpVerb = @"GET";
        self.url = @"https://api.flickr.com/services/rest/";
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
        self.authToken = [NSString stringWithFormat:@"oauth_token=%@", token];
        //
        self.method = @"method=flickr.groups.pools.getPhotos";
        self.nojsoncallback = @"nojsoncallback=1";
        self.format = @"format=json";
        self.extras = @"extras=views,url_s";
        self.perPage = @"per_page=50";
        self.pageNo = @"page=1";
        //
        self.groupId = [NSString stringWithFormat:@"group_id=%@", groupId];;
        //
        NSString* signow = [self calculateSignature];
        signow = [signow stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        self.signature = [NSString stringWithFormat:@"oauth_signature=%@", signow];
    }
    return self;
}

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token GroupId: (NSString *) groupId PageNumber: (NSInteger) pageNumber
{
    self = [super init];
    if (self)
    {
        // Additional initialization
        self.httpVerb = @"GET";
        self.url = @"https://api.flickr.com/services/rest/";
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
        self.authToken = [NSString stringWithFormat:@"oauth_token=%@", token];
        //
        self.method = @"method=flickr.groups.pools.getPhotos";
        self.nojsoncallback = @"nojsoncallback=1";
        self.format = @"format=json";
        self.extras = @"extras=views,url_s";
        self.perPage = @"per_page=50";
        self.pageNo = [NSString stringWithFormat:@"page=%d", pageNumber];
        //
        self.groupId = [NSString stringWithFormat:@"group_id=%@", groupId];
        //
        NSString* signow = [self calculateSignature];
        signow = [signow stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        self.signature = [NSString stringWithFormat:@"oauth_signature=%@", signow];
    }
    return self;
}

- (NSString *) calculateSignature
{
    // Create array
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // Add the values to array
    [array addObject:self.nojsoncallback];
    [array addObject:self.format];
    [array addObject:self.consumerKey];
    [array addObject:self.authToken];
    [array addObject:self.method];
    [array addObject:self.nonce];
    [array addObject:self.timeStamp];
    [array addObject:self.signatureMethod];
    [array addObject:self.version];
    [array addObject:self.groupId];
    [array addObject:self.extras];
    [array addObject:self.perPage];
    [array addObject:self.pageNo];
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
    // Now calculate HMAC-SHA1 of data
    return OFHMACSha1Base64(self.consumerSecret, firstPart);
}


- (NSString *) getUrl
{
    return [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@", self.url, self.nojsoncallback, self.format, self.consumerKey, self.authToken, self.method, self.signature, self.nonce, self.timeStamp, self.signatureMethod, self.version, self.groupId, self.extras, self.perPage, self.pageNo];
}

@end
