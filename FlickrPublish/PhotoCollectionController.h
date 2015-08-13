//
//  PhotoCollectionController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoSet.h"
#import "PhotosetGetPhotosOperation.h"
#import "DownloadFileOperation.h"

@interface PhotoCollectionController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PhotosetGetPhotosHandler, DownloadFileOperationDelegate>

@property (nonatomic, strong) PhotoSet* set;

- (void) receivedPhotos: (NSArray *) photos;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId;

- (IBAction)handleViewPhoto:(id)sender;

@end
