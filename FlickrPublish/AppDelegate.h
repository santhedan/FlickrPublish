//
//  AppDelegate.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadGroupComments.h"
#import "SaveGroupComments.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, LoadGroupCommentsHandler, SaveGroupCommentsHandler>

@property (strong, nonatomic) UIWindow *window;

- (void) enqueueOperation: (NSOperation *) op;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* fullName;

@property (nonatomic, strong) NSString* nsid;

@property (nonatomic, strong) NSString* userName;

@property (nonatomic, strong) NSString* hmacsha1Key;

@property (nonatomic, assign) BOOL isAuthenticated;

- (void) loadedGroupComments: (NSDictionary*) groupComments;

- (void) didSaveGroupComments;

- (void) addComment: (NSString *) comment forGroup: (NSString *) groupId;

- (void) removeCommentForGroup: (NSString *) groupId;

- (NSString *) getCommentForGroup: (NSString *) groupId;

@end

