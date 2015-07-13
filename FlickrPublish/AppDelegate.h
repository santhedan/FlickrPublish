//
//  AppDelegate.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) enqueueOperation: (NSOperation *) op;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* fullName;

@property (nonatomic, strong) NSString* nsid;

@property (nonatomic, strong) NSString* userName;

@property (nonatomic, strong) NSString* hmacsha1Key;

@property (nonatomic, assign) BOOL isAuthenticated;

@end

