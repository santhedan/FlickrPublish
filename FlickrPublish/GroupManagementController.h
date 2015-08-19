//
//  GroupManagementController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeopleGetGroupsOperation.h"
#import "DownloadFileOperation.h"

@interface GroupManagementController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PeopleGetGroupsOperationHandler, DownloadFileOperationDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)handleShowPhotos:(id)sender;

- (IBAction)handleConfigureComments:(id)sender;

- (void) receivedGroups: (NSArray *) groups;

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId;

- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue;

@end
