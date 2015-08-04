//
//  GroupsGetInfoOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"
#import "GroupsGetInfo.h"

@protocol GroupsGetInfoOperationDelegate <NSObject>

@required

- (void) receivedGroupInformation: (Group *) group;

@end

@interface GroupsGetInfoOperation : NSOperation

- (instancetype) initWithRequest: (GroupsGetInfo *) request Delegate: (id<GroupsGetInfoOperationDelegate>) delegate;

@end
