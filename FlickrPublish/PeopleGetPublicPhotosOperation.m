//
//  PeopleGetPublicPhotosOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PeopleGetPublicPhotosOperation.h"
#import "Photo.h"

@interface PeopleGetPublicPhotosOperation()

@property (nonatomic, strong) PeopleGetPublicPhotos *request;

@property (nonatomic, strong) id<PeopleGetPublicPhotosOperationDelegate> delegate;

@end

@implementation PeopleGetPublicPhotosOperation

- (instancetype) initWithRequest: (PeopleGetPublicPhotos *) request Delegate:(id<PeopleGetPublicPhotosOperationDelegate>) delegate
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
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedGroupPhotos:photos];
}

@end
