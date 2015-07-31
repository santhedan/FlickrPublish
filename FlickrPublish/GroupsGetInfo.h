//
//  GroupsGetInfo.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface GroupsGetInfo : BaseRequest

@property (nonatomic, strong) NSString* groupId;

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token GroupId: (NSString *) groupId;

- (NSString *) getUrl;

@end
