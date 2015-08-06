//
//  MainController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "MainController.h"
#import "PhotosetGetList.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PhotosetCell.h"
#import "PhotoSet.h"
#import "PhotoCollectionController.h"

@interface MainController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray* photosets;

@property (nonatomic, strong) PhotoSet* selectedSet;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL visible;

@end

@implementation MainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;
    // Do any additional setup after loading the view.
    self.title = @"Your Sets";
    //
    [self.activityIndicator startAnimating];
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosetGetList* request = [[PhotosetGetList alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid];
    // Create operation
    PhotosetGetListOperation* op = [[PhotosetGetListOperation alloc] initWithRequest:request Delegate:self];
    //
    UIBarButtonItem* groupItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group"] style:UIBarButtonItemStylePlain target:self action:@selector(showGroups)];
    self.navigationItem.rightBarButtonItem = groupItem;
    //
    [delegate enqueueOperation:op];
    //
    [self.collectionView setLayoutMargins:UIEdgeInsetsZero];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.visible = YES;
    //
    if (self.currentIndex < [self.photosets count])
    {
        // Start loading images
        PhotoSet* set = [self.photosets objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:set.photosetPhotoUrl Directory:set.id Delegate:self];
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

- (void)showGroups
{
    NSLog(@"Show groups");
    [self performSegueWithIdentifier:@"ManageGroups" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receivedPhotoSets: (NSArray *) photosets
{
    self.photosets = photosets;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.collectionView reloadData];
    });
    if ([self.photosets count] > 0)
    {
        // Start loading images
        PhotoSet* set = [self.photosets objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:set.photosetPhotoUrl Directory:set.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhotos"])
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        PhotoCollectionController* ctrl = segue.destinationViewController;
        ctrl.set = self.selectedSet;
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosets.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoSetCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    PhotoSet* set = [self.photosets objectAtIndex:indexPath.item];
    cell.photosetName.text = set.name;
    cell.photos.text = set.photos;
    cell.videos.text = set.videos;
    cell.views.text = set.views;
    if (set.photosetPhoto != nil)
    {
        cell.photosetPhoto.image = [UIImage imageWithData:set.photosetPhoto];
    }
    else
    {
        cell.photosetPhoto.image = [UIImage imageNamed:@"small_placeholder"];
    }
    //
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [cell tintColor].CGColor;
    //
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoSet* set = [self.photosets objectAtIndex:indexPath.item];
    self.selectedSet = set;
    [self performSegueWithIdentifier:@"ShowPhotos" sender:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 20;
    
    // Divide this with the minimum desired width of the cell
    int itemsInRow = collectionViewWidth / 240;
    
    // So we can fit "itemsInRow"
    int desiredItemWidth = (collectionViewWidth - (itemsInRow - 1) * 10) / itemsInRow;
    
    // Height is fixed
    int desiredItemHeight = 80;
    
    // Create size object from above and return
    CGSize itemSize = CGSizeMake(desiredItemWidth, desiredItemHeight);
    
    return itemSize;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
}

- (void) receivedFileData: (NSData *) imageData
{
    PhotoSet* set = [self.photosets objectAtIndex:self.currentIndex];
    set.photosetPhoto = imageData;
    NSIndexPath* path = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
    });
    self.currentIndex = self.currentIndex + 1;
    if (self.currentIndex < [self.photosets count] && self.visible)
    {
        // Start loading images
        set = [self.photosets objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:set.photosetPhotoUrl Directory:set.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
}

@end
