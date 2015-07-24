//
//  PhotoInfo.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 24/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoInfo : NSObject

@property (nonatomic, assign) BOOL isPublic;

@property (nonatomic, assign) NSInteger faves;

@property (nonatomic, assign) NSInteger comments;

@end
