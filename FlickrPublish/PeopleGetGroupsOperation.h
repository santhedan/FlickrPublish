//
//  PeopleGetGroupsOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"
#import "PeopleGetGroups.h"

@protocol PeopleGetGroupsOperationHandler <NSObject>

@required

- (void) receivedGroups: (NSArray *) groups;

@end

@interface PeopleGetGroupsOperation : NSOperation

- (instancetype) initWithRequest: (PeopleGetGroups *) request ExcludeGroups: (NSArray *) groupsToExclude Delegate:(id<PeopleGetGroupsOperationHandler>) delegate;

@end
