//
//  PhotosGetContactsPhotosOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/06/16.
//  Copyright © 2016 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotosGetContactsPhotos.h"

@protocol PhotosGetContactsPhotosOperationDelegate <NSObject>

- (void) receivedPhotos: (NSArray *) photos;

@end

@interface PhotosGetContactsPhotosOperation : NSOperation

- (instancetype) initWithRequest: (PhotosGetContactsPhotos *) request Delegate:(id<PhotosGetContactsPhotosOperationDelegate>) delegate;

@end
