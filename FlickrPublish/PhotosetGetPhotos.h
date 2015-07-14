//
//  PhotosetGetPhotos.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PhotosetGetPhotos : BaseRequest

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* userId;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* photosetId;

@property (nonatomic, strong) NSString* extras;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token UserID: (NSString *) userId PhotosetId: (NSString *) photosetId;

- (NSString *) getUrl;


@end
