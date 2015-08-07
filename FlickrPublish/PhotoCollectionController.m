//
//  PhotoCollectionController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotoCollectionController.h"
#import "PhotoCell.h"
#import "Photo.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PhotosetGetPhotosOperation.h"
#import "GroupListController.h"

@interface PhotoCollectionController ()
{
    UIBarButtonItem* sortItem;
}

@property (nonatomic, strong) NSArray* photos;

@property (nonatomic, strong) Photo* selectedPhoto;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL visible;

@end

@implementation PhotoCollectionController

static NSString * const reuseIdentifier = @"PhotoCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;
    self.title = self.set.name;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    sortItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortOption)];
    self.navigationItem.rightBarButtonItem = sortItem;
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosetGetPhotos* request = [[PhotosetGetPhotos alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid PhotosetId:self.set.id];
    // Create operation
    PhotosetGetPhotosOperation* op = [[PhotosetGetPhotosOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
    //
    [self.activityIndicator startAnimating];
}

- (void) showSortOption
{
    UIAlertController* ctrl = [UIAlertController alertControllerWithTitle:@"Sort photos by" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    // Sort by views
    UIAlertAction* viewAction = [UIAlertAction actionWithTitle:@"Views" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){[self sortByViews];}];
    // Sort by views
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){[self dismissViewControllerAnimated:YES completion:nil];}];
    // Add the action to controller
    [ctrl addAction: viewAction];
    [ctrl addAction: cancelAction];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        ctrl.popoverPresentationController.barButtonItem = sortItem;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else
    {
        // Now show the alert
        [self presentViewController:ctrl animated:YES completion:nil];
    }
}

- (void) sortByViews
{
    NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareViews:)];
    self.photos = sortedArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void) sortByFaves
{
    NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareFaves:)];
    self.photos = sortedArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void) sortByComments
{
    NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareComments:)];
    self.photos = sortedArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.visible = YES;
    //
    if (self.currentIndex < [self.photos count])
    {
        // Start loading images
        Photo* p = [self.photos objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:self.set.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.visible = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    self.photos = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    GroupListController* ctrl = (GroupListController *)[segue destinationViewController];
    ctrl.photo = self.selectedPhoto;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    cell.imageTitle.text = p.name;
    cell.imageViews.text = [NSString stringWithFormat:@"%ld", (long)p.views];
    if (p.imageData != nil)
    {
        cell.thumbnailSmall.image = [UIImage imageWithData:p.imageData];
    }
    else
    {
        cell.thumbnailSmall.image = [UIImage imageNamed:@"large_placeholder"];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.photos objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:@"ShowGroups" sender:self];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void) receivedPhotos: (NSArray *) photos
{
    self.photos = photos;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
    });
    if ([self.photos count] > 0)
    {
        // Get photo
        Photo* p = [self.photos objectAtIndex:self.currentIndex];
        // Get app delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:self.set.id Delegate:self];
        // Start download
        [delegate enqueueOperation:op];
    }
}

- (void) receivedFileData: (NSData *) imageData
{
    // Get photo
    Photo* p = [self.photos objectAtIndex:self.currentIndex];
    // Assign data
    p.imageData = imageData;
    // Create index path
    NSIndexPath* path = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
    });
    self.currentIndex = self.currentIndex + 1;
    if (self.currentIndex < [self.photos count] && self.visible)
    {
        // Start loading images
        p = [self.photos objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:self.set.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
}

@end
