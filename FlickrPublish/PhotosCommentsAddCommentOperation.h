//
//  PhotosCommentsAddCommentOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotosCommentsAddCommentOperationDelegate <NSObject>

@required

- (void) commentsAdded;

@end

@interface PhotosCommentsAddCommentOperation : NSOperation

- (instancetype) initWithPhotoIds: (NSArray *) photos GroupId: (NSString *) groupId Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate;

- (instancetype) initWithPhotoIds: (NSArray *) photos Comment: (NSString *) comment Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate;

- (instancetype) initWithPhotoId: (NSString *) photoId Comment: (NSString *) comment Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate;

@end
