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

@interface PhotoCollectionController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PhotosetGetPhotosHandler>

@property (nonatomic, strong) PhotoSet* set;

- (void) receivedPhotos: (NSArray *) photos;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
