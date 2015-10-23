//
//  PhotosGetAllContextsOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosGetAllContextsOperation.h"
#import "Group.h"
#import "PhotosGetInfo.h"
#import "PhotosGetFavorites.h"

@interface PhotosGetAllContextsOperation()

@property (nonatomic, strong) PhotosGetAllContexts *request;

@property (nonatomic, strong) id<PhotosGetAllContextsHandler> delegate;

@end

@implementation PhotosGetAllContextsOperation

- (instancetype) initWithRequest: (PhotosGetAllContexts *) request Delegate:(id<PhotosGetAllContextsHandler>) delegate
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
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    // Parse the data
    if (!self.isCancelled && response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* contexts = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [contexts valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* groupArray = [contexts valueForKey:@"pool"];
                for (NSDictionary *group in groupArray)
                {
                    // Create Photo object
                    NSString* groupId = [group valueForKey:@"id"];
                    //
                    [groups addObject:groupId];
                }
            }
        }
    }
    // Create photo info object
    PhotoInfo* info = [[PhotoInfo alloc] init];
    // Create get info request
    PhotosGetInfo* infoRequest = [[PhotosGetInfo alloc] initWithKey:self.request.consumerKey Secret:self.request.consumerSecret Token:self.request.authToken PhotoId:self.request.photoId];
    url = [NSURL URLWithString:[infoRequest getUrl]];
    response = [NSData dataWithContentsOfURL:url];
    // Parse the data
    if (!self.isCancelled && response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* infos = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [infos valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSNumber* isPublic = [[[infos valueForKey:@"photo"] valueForKey:@"visibility"] valueForKey:@"ispublic"];
                info.isPublic = (isPublic.intValue == 1);
                NSString* comments = [[[infos valueForKey:@"photo"] valueForKey:@"comments"] valueForKey:@"_content"];
                info.comments = [comments intValue];
            }
        }
    }
    // Create get fav request
    PhotosGetFavorites* favRequest = [[PhotosGetFavorites alloc] initWithKey:self.request.consumerKey Secret:self.request.consumerSecret Token:self.request.authToken PhotoId:self.request.photoId];
    url = [NSURL URLWithString:[favRequest getUrl]];
    response = [NSData dataWithContentsOfURL:url];
    // Parse the data
    if (!self.isCancelled && response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* favs = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [favs valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSString* favCount = [[favs valueForKey:@"photo"] valueForKey:@"total"];
                info.faves = [favCount intValue];
            }
        }
    }
    if (!self.isCancelled)
    {
        // Call delegate
        [self.delegate receivedPhotoGroups:groups Info: info];
    }
}

@end
