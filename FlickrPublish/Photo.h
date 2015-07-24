//
//  Photo.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* smallImageURL;

@property (nonatomic, strong) NSData* imageData;

@property (nonatomic, assign) NSInteger height;

@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign) NSInteger views;

@property (nonatomic, assign) NSInteger faves;

@end
