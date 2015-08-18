//
//  FavoritesAdd.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 18/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface FavoritesAdd : BaseRequest

@property (nonatomic, strong) NSString* photoId;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId;

- (NSString *) getUrl;

- (NSData *) getBody;

@end
