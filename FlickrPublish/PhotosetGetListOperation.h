//
//  PhotosetGetListOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 13/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotosetGetList.h"

@protocol PhotosetGetListHandler <NSObject>

@required

- (void) receivedPhotoSets: (NSArray *) photosets;

@end

@interface PhotosetGetListOperation : NSOperation

- (instancetype) initWithRequest: (PhotosetGetList *) request Delegate: (id<PhotosetGetListHandler>) delegate;

@end
