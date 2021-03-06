//
//  PhotoSet.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoSet : NSObject

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* photos;

@property (nonatomic, strong) NSString* videos;

@property (nonatomic, strong) NSString* views;

@property (nonatomic, strong) UIImage* photosetPhoto;

@property (nonatomic, strong) NSString* photosetPhotoUrl;

@end
