//
//  Person.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 19/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* iconServer;

@property (nonatomic, strong) NSString* iconFarm;

@property (nonatomic, strong) NSString* userName;

@property (nonatomic, strong) NSString* realName;

@property (nonatomic, strong) NSString* location;

@property (nonatomic, strong) NSString* photoCount;

@property (nonatomic, strong) UIImage* buddyIcon;

@end
