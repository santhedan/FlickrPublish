//
//  PhotoSetCell.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *photosetName;

@property (weak, nonatomic) IBOutlet UILabel *photos;

@property (weak, nonatomic) IBOutlet UILabel *videos;

@property (weak, nonatomic) IBOutlet UILabel *views;

@property (weak, nonatomic) IBOutlet UIImageView *photosetPhoto;

@end
