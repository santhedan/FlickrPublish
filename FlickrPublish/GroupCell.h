//
//  GroupCell.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupName;

@property (weak, nonatomic) IBOutlet UILabel *remainingCount;

@property (weak, nonatomic) IBOutlet UILabel *membershipType;

@property (weak, nonatomic) IBOutlet UILabel *members;

@property (weak, nonatomic) IBOutlet UILabel *photos;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@property (weak, nonatomic) IBOutlet UIButton *showPhotosBtn;

@property (weak, nonatomic) IBOutlet UIButton *configureCommentsBtn;

@end
