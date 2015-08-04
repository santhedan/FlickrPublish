//
//  GroupsPoolsGetPhotosOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupsPoolsGetPhotos.h"

@protocol GroupsPoolsGetPhotosOperationDelegate <NSObject>

@required

- (void) receivedGroupPhotos: (NSArray *) photos;

@end

@interface GroupsPoolsGetPhotosOperation : NSOperation

- (instancetype) initWithRequest: (GroupsPoolsGetPhotos *) request Delegate:(id<GroupsPoolsGetPhotosOperationDelegate>) delegate;

@end
