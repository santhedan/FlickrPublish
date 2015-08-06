//
//  PhotosetGetPhotosOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosetGetPhotosOperation.h"
#import "Photo.h"
#import "Utility.h"

@interface PhotosetGetPhotosOperation()

@property (nonatomic, strong) PhotosetGetPhotos *request;

@property (nonatomic, strong) id<PhotosetGetPhotosHandler> delegate;

@end

@implementation PhotosetGetPhotosOperation

- (instancetype) initWithRequest: (PhotosetGetPhotos *) request Delegate: (id<PhotosetGetPhotosHandler>) delegate
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
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* dictPhotos = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [dictPhotos valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* photoDictArray = [[dictPhotos valueForKey:@"photoset"] valueForKey:@"photo"];
                for (NSDictionary *photo in photoDictArray)
                {
                    // Create Photo object
                    Photo* p = [[Photo alloc] init];
                    p.id = [photo valueForKey:@"id"];   
                    p.name = [photo valueForKey:@"title"];
                    p.views = ((NSString *)[photo valueForKey:@"views"]).intValue;
                    p.smallImageURL = [[photo valueForKey:@"url_s"] stringByReplacingOccurrencesOfString:@"_m.jpg" withString:@"_q.jpg"];
                    p.height = ((NSString *)[photo valueForKey:@"height_s"]).intValue;
                    p.width = ((NSString *)[photo valueForKey:@"width_s"]).intValue;
                    //
                    [photos addObject:p];
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedPhotos:photos];
}

@end
