//
//  GroupListController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "PhotosGetAllContextsOperation.h"
#import "PeopleGetGroupsOperation.h"
#import "GroupsPoolsAddOperation.h"
#import "DownloadFileOperation.h"

@interface GroupListController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, PhotosGetAllContextsHandler, PeopleGetGroupsOperationHandler, GroupsPoolsAddOperationHandler, DownloadFileOperationDelegate>

@property (nonatomic, strong) Photo* photo;
@property (weak, nonatomic) IBOutlet UIImageView *imageToAdd;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *progressContainer;
@property (weak, nonatomic) IBOutlet UILabel *faveCount;
@property (weak, nonatomic) IBOutlet UILabel *viewCount;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@property (weak, nonatomic) IBOutlet UILabel *publicState;

- (void) handleAdd;

- (void) addedToGroups: (NSArray *) groups;

- (void) showProgressMessage: (NSString *) progressMessage;

- (void) receivedGroups: (NSArray *) groups;

- (void) receivedPhotoGroups: (NSArray *) groups Info: (PhotoInfo *) info;

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId;

@end
