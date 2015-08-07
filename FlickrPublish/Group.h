//
//  Group.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Group : NSObject

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) NSInteger remaining;

@property (nonatomic, strong) NSString* pathAlias;

@property (nonatomic, strong) NSString* iconServer;

@property (nonatomic, strong) NSString* iconFarm;

@property (nonatomic, strong) NSString* groupDescription;

@property (nonatomic, strong) NSString* rules;

@property (nonatomic, strong) NSString* members;

@property (nonatomic, strong) NSString* poolPhotoCount;

@property (nonatomic, strong) NSString* blast;

@property (nonatomic, assign) BOOL isModerated;

@property (nonatomic, assign) NSInteger throttleCount;

@property (nonatomic, strong) NSString* throttleMode;

@property (nonatomic, strong) NSString* groupImagePath;

@property (nonatomic, assign) MembershipType memType;

@property (nonatomic, strong) NSData* imageData;

- (NSString *) getDefaultComment;

- (NSComparisonResult)compare: (Group *) otherObject;

@end
