//
//  PhotosGetAllContextsOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotosGetAllContexts.h"
#import "PhotoInfo.h"

@protocol PhotosGetAllContextsHandler <NSObject>

@required

- (void) receivedPhotoGroups: (NSArray *) groups Info: (PhotoInfo *) info;

@end

@interface PhotosGetAllContextsOperation : NSOperation

- (instancetype) initWithRequest: (PhotosGetAllContexts *) request Delegate:(id<PhotosGetAllContextsHandler>) delegate;

@end
