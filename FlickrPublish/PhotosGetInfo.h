//
//  PhotosGetInfo.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 24/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PhotosGetInfo : BaseRequest

@property (nonatomic, strong) NSString* photoId;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId;

- (NSString *) getUrl;

@end
