//
//  GroupPoolPhotoDisplayController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupPoolPhotoDisplayController.h"
#import "AppDelegate.h"
#import "GroupsPoolsGetPhotos.h"
#import "GroupsPoolsGetPhotosOperation.h"
#import "PhotoCell.h"
#import "Photo.h"

@interface GroupPoolPhotoDisplayController ()

@property (nonatomic, strong) NSArray* photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GroupPoolPhotoDisplayController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.group.name;
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get group description
    GroupsPoolsGetPhotos* request = [[GroupsPoolsGetPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token GroupId:self.group.id];
    GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithRequest:request Delegate:self];
    [delegate enqueueOperation:op];
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addComments:(id)sender
{
    NSMutableArray* photoIds = [[NSMutableArray alloc] init];
    for (Photo* p in self.photos) {
        if (p.selected)
        {
            [photoIds addObject:p.id];
        }
    }
    // Get app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get comment for the group
    NSString* comment = [delegate getCommentForGroup:self.group.id];
    if (comment == nil)
    {
        comment = [self.group getDefaultComment];
        [delegate addComment:comment forGroup:self.group.id];
    }
    //
    if (photoIds.count > 0)
    {
        // Create operation
        PhotosCommentsAddCommentOperation* op = [[PhotosCommentsAddCommentOperation alloc] initWithPhotoIds:photoIds GroupId:self.group.id Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        [self.activityIndicator startAnimating];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // Configure the cell
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    cell.imageTitle.text = p.name;
    cell.imageViews.text = [NSString stringWithFormat:@"%ld", (long)p.views];
    cell.thumbnailSmall.image = [UIImage imageWithData:p.imageData];
    if (p.selected)
    {
        [cell.selState setHidden:NO];
    }
    else
    {
        [cell.selState setHidden:YES];
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    p.selected = !(p.selected);
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 20;
    
    // Divide this with the minimum desired width of the cell
    int itemsInRow = collectionViewWidth / 150;
    
    // So we can fit "itemsInRow"
    int desiredItemWidth = (collectionViewWidth - (itemsInRow - 1) * 10) / itemsInRow;
    
    // Now calculate the height of the item
    int desiredItemHeight = desiredItemWidth;
    
    // Create size object from above and return
    CGSize itemSize = CGSizeMake(desiredItemWidth, desiredItemHeight);
    
    return itemSize;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
}

#pragma mark GroupsPoolsGetPhotosOperationDelegate

- (void) receivedGroupPhotos: (NSArray *) photos
{
    self.photos = photos;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
    });
}

- (void) commentsAdded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

@end
