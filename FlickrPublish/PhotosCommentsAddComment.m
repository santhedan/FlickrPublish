//
//  PhotosCommentsAddComment.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosCommentsAddComment.h"
#import "OFUtilities.h"

@interface PhotosCommentsAddComment()

@property (nonatomic, strong) NSString* inComment;

@end

@implementation PhotosCommentsAddComment

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId Comment: (NSString *) comment
{
    self = [super init];
    if (self)
    {
        // Additional initialization
        self.httpVerb = @"POST";
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
        self.photoId = [NSString stringWithFormat:@"photo_id=%@", photoId];
        self.comment = [NSString stringWithFormat:@"comment_text=%@", OFEscapedURLStringFromNSStringWithExtraEscapedChars(comment, kEscapeChars)];
        self.inComment = comment;
        //
        self.method = @"method=flickr.photos.comments.addComment";
        self.nojsoncallback = @"nojsoncallback=1";
        self.format = @"format=json";
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
    [array addObject:self.photoId];
    [array addObject:self.comment];
    [array addObject:self.nonce];
    [array addObject:self.timeStamp];
    [array addObject:self.signatureMethod];
    [array addObject:self.version];
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
    return [NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@&%@&%@&%@&%@&%@", self.url, self.nojsoncallback, self.format, self.consumerKey, self.authToken, self.method, self.signature, self.nonce, self.timeStamp, self.signatureMethod, self.version];
}

- (NSData *) getBody
{
    NSString* strBody = [NSString stringWithFormat:@"%@&%@", self.photoId, self.comment];
    return [strBody dataUsingEncoding:NSUTF8StringEncoding];
}

@end
