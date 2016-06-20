//
//  PhotosGetContactsPhotosOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/06/16.
//  Copyright © 2016 Sanjay Dandekar. All rights reserved.
//

#import "PhotosGetContactsPhotosOperation.h"
#import "Photo.h"

@interface PhotosGetContactsPhotosOperation()

@property (nonatomic, strong) PhotosGetContactsPhotos* request;

@property (nonatomic, strong) id<PhotosGetContactsPhotosOperationDelegate> delegate;

@end

@implementation PhotosGetContactsPhotosOperation

- (instancetype) initWithRequest: (PhotosGetContactsPhotos *) request Delegate:(id<PhotosGetContactsPhotosOperationDelegate>) delegate;
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // Create a NSURL from the request
    NSURL *url = [NSURL URLWithString:[self.request getUrl]];
    //
    NSData* response = [NSData dataWithContentsOfURL:url];
    // Create empty return value
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    // Parse the data
    if (!self.isCancelled && response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* dictPhotos = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [dictPhotos valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* photoDictArray = [[dictPhotos valueForKey:@"photos"] valueForKey:@"photo"];
                for (NSDictionary *photo in photoDictArray)
                {
                    // Create Photo object
                    Photo* p = [[Photo alloc] init];
                    p.id = [photo valueForKey:@"id"];
                    p.name = [photo valueForKey:@"title"];
                    p.views = ((NSString *)[photo valueForKey:@"views"]).intValue;
                    p.ownerId = [photo valueForKey:@"owner"];
                    p.ownerName = [photo valueForKey:@"ownername"];
                    p.smallImageURL = [[photo valueForKey:@"url_s"] stringByReplacingOccurrencesOfString:@"_m.jpg" withString:@"_q.jpg"];
                    p.height = ((NSString *)[photo valueForKey:@"height_s"]).intValue;
                    p.width = ((NSString *)[photo valueForKey:@"width_s"]).intValue;
                    p.selected = NO;
                    [photos addObject:p];
                    if (self.isCancelled)
                    {
                        // Break as we are cancelled
                        break;
                    }
                }
            }
        }
    }
    if (!self.isCancelled)
    {
        // Call delegate
        [self.delegate receivedPhotos:photos];
    }
}

@end
