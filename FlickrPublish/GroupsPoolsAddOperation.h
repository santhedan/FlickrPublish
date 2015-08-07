//
//  GroupsPoolsAddOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GroupsPoolsAddOperationHandler <NSObject>

@required

- (void) addedToGroups: (NSArray *) groups;

- (void) showProgressMessage: (NSString *) progressMessage;

@end

@interface GroupsPoolsAddOperation : NSOperation

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId Groups: (NSArray *) groups Delegate: (id<GroupsPoolsAddOperationHandler>) delegate;

@end
