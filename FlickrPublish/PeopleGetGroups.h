//
//  PeopleGetGroups.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PeopleGetGroups : BaseRequest

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* userId;

@property (nonatomic, strong) NSString* extra;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token UserID: (NSString *) userId;

- (NSString *) getUrl;

@end
