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
{
    UIImage* placeHolderImage;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray* photosets;

@property (nonatomic, strong) PhotoSet* selectedSet;

@property (nonatomic, assign) NSInteger currentIndex;

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
    UIBarButtonItem* groupItem = [[UIBarButtonItem alloc] initWithTitle:@"Groups" style:UIBarButtonItemStylePlain target:self action:@selector(showGroups)];
    self.navigationItem.rightBarButtonItem = groupItem;
    //
    [delegate enqueueOperation:op];
    //
    [self.collectionView setLayoutMargins:UIEdgeInsetsZero];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate cancelAllOperation];
    [super viewWillDisappear:animated];
}

#pragma mark UIBarButtonHandler

- (void)showGroups
{
    [self performSegueWithIdentifier:@"ManageGroups" sender:self];
}

#pragma mark PhotosetGetListHandler

- (void) receivedPhotoSets: (NSArray *) photosets
{
    self.photosets = photosets;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.collectionView reloadData];
    });
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
        cell.photosetPhoto.image = set.photosetPhoto;
    }
    else
    {
        if (placeHolderImage == nil)
        {
            placeHolderImage = [UIImage imageNamed:@"small_placeholder"];
        }
        cell.photosetPhoto.image = placeHolderImage;
        // Request download - Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:set.photosetPhotoUrl Directory:set.id FileId:set.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
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

#pragma mark DownloadFileOperationDelegate

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId
{
    @synchronized (self.photosets) {
        // We have to find a photo with id fileId - so first create a filter predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", fileId];
        NSArray *filteredPhotoset = [self.photosets filteredArrayUsingPredicate:predicate];
        if (filteredPhotoset.count == 1)
        {
            PhotoSet* pset = [filteredPhotoset objectAtIndex:0];
            pset.photosetPhoto = [UIImage imageWithData: imageData];
            // get index of p
            NSInteger index = [self.photosets indexOfObject:pset];
            // Create indexPath
            NSIndexPath* path = [NSIndexPath indexPathForItem:index inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Reload the cell
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
            });
        }
    }
}

@end
