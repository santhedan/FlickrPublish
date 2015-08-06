//
//  GroupPoolPhotoDisplayController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "GroupsPoolsGetPhotosOperation.h"
#import "PhotosCommentsAddCommentOperation.h"
#import "DownloadFileOperation.h"

@interface GroupPoolPhotoDisplayController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GroupsPoolsGetPhotosOperationDelegate, PhotosCommentsAddCommentOperationDelegate, DownloadFileOperationDelegate>

@property (nonatomic, strong) Group* group;

- (void) receivedFileData: (NSData *) imageData;

@end
