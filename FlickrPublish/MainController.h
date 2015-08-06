//
//  MainController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosetGetListOperation.h"
#import "DownloadFileOperation.h"

@interface MainController : UIViewController <PhotosetGetListHandler, UICollectionViewDataSource, UICollectionViewDelegate, DownloadFileOperationDelegate>

- (void) receivedPhotoSets: (NSArray *) photosets;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void) receivedFileData: (NSData *) imageData;

@end
