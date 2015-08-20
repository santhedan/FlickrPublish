//
//  PeopleGetPublicPhotos.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PeopleGetPublicPhotos : BaseRequest

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* userId;

@property (nonatomic, strong) NSString* extras;

@property (nonatomic, strong) NSString* perPage;

@property (nonatomic, strong) NSString* pageNo;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token UserID: (NSString *) userId PageNumber: (NSInteger) pageNumber;

- (NSString *) getUrl;

@end
