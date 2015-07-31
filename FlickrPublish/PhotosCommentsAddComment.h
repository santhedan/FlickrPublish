//
//  PhotosCommentsAddComment.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PhotosCommentsAddComment : BaseRequest

@property (nonatomic, strong) NSString* photoId;

@property (nonatomic, strong) NSString* comment;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId Comment: (NSString *) comment;

- (NSString *) getUrl;

- (NSData *) getBody;

@end
