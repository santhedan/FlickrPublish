//
//  PhotosetGetPhotosOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotosetGetPhotos.h"

@protocol PhotosetGetPhotosHandler <NSObject>

@required

- (void) receivedPhotos: (NSArray *) photos;

@end

@interface PhotosetGetPhotosOperation : NSOperation

- (instancetype) initWithRequest: (PhotosetGetPhotos *) request Delegate: (id<PhotosetGetPhotosHandler>) delegate;

@end
