//
//  GroupsPoolsGetPhotosOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupsPoolsGetPhotosOperation.h"
#import "Photo.h"

@interface GroupsPoolsGetPhotosOperation()

@property (nonatomic, strong) GroupsPoolsGetPhotos *request;

@property (nonatomic, strong) InterestingnessGetList *intRequest;

@property (nonatomic, strong) id<GroupsPoolsGetPhotosOperationDelegate> delegate;

@end

@implementation GroupsPoolsGetPhotosOperation

- (instancetype) initWithRequest: (GroupsPoolsGetPhotos *) request Delegate:(id<GroupsPoolsGetPhotosOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.intRequest = nil;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype) initWithIntRequest: (InterestingnessGetList *) request Delegate:(id<GroupsPoolsGetPhotosOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.intRequest = request;
        self.request = nil;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // Create a NSURL from the request
    NSURL *url = nil;
    if (self.request != nil)
    {
        url = [NSURL URLWithString:[self.request getUrl]];
    }
    else if (self.intRequest != nil)
    {
        url = [NSURL URLWithString:[self.intRequest getUrl]];
    }
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
