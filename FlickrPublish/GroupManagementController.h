//
//  GroupManagementController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeopleGetGroupsOperation.h"

@interface GroupManagementController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PeopleGetGroupsOperationHandler>

- (void) receivedGroups: (NSArray *) groups;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)handleShowPhotos:(id)sender;

- (IBAction)handleConfigureComments:(id)sender;

@end
