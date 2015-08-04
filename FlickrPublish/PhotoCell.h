//
//  PhotoCell.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailSmall;

@property (weak, nonatomic) IBOutlet UILabel *imageTitle;

@property (weak, nonatomic) IBOutlet UILabel *imageViews;

@property (weak, nonatomic) IBOutlet UIImageView *selState;

@end
