//
//  GroupsPoolsGetPhotos.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface GroupsPoolsGetPhotos : BaseRequest

@property (nonatomic, strong) NSString* groupId;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* extras;

@property (nonatomic, strong) NSString* perPage;

@property (nonatomic, strong) NSString* pageNo;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token GroupId: (NSString *) groupId;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token GroupId: (NSString *) groupId PageNumber: (NSInteger) pageNumber;

- (NSString *) getUrl;

@end
