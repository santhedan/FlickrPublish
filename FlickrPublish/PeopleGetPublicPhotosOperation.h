//
//  PeopleGetPublicPhotosOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeopleGetPublicPhotos.h"

@protocol PeopleGetPublicPhotosOperationDelegate <NSObject>

@required

- (void) receivedGroupPhotos: (NSArray *) photos;

@end

@interface PeopleGetPublicPhotosOperation : NSOperation

- (instancetype) initWithRequest: (PeopleGetPublicPhotos *) request Delegate:(id<PeopleGetPublicPhotosOperationDelegate>) delegate;

@end
