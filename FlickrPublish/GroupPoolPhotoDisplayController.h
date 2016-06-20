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
#import "FavoritesAddOperation.h"
#import "PeopleGetPublicPhotosOperation.h"
#import "PhotosGetContactsPhotosOperation.h"

@interface GroupPoolPhotoDisplayController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GroupsPoolsGetPhotosOperationDelegate, PhotosCommentsAddCommentOperationDelegate, DownloadFileOperationDelegate, FavoritesAddOperationDelegate, PeopleGetPublicPhotosOperationDelegate, PhotosGetContactsPhotosOperationDelegate>

@property (nonatomic, strong) Group* group;

@property (nonatomic, assign) PhotoListType photoListType;

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userName;

@property (weak, nonatomic) IBOutlet UIButton *addCommentCmd;
@property (weak, nonatomic) IBOutlet UIButton *commentAndFavCmd;
@property (weak, nonatomic) IBOutlet UIButton *faveCmd;
@property (weak, nonatomic) IBOutlet UIView *progressViewContainer;

- (IBAction)handleViewPhoto:(id)sender;

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId;

- (void) favoritesAdded;

@end
