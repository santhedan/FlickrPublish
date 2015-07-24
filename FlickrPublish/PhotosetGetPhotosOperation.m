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
                NSString* photosetId = [[dictPhotos valueForKey:@"photoset"] valueForKey:@"id"];
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
                    // Get the last path component of the URL
                    NSString* fileName = [p.smallImageURL lastPathComponent];
                    // Now create path to the file in documents directory
                    NSString* fullFilePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[Utility applicationDocumentsDirectory], photosetId, fileName, nil]];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
                    {
                        p.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:p.smallImageURL]];
                        // Create directory
                        NSString* dirPath = [fullFilePath stringByDeletingLastPathComponent];
                        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&localError];
                        if (localError == nil)
                        {
                            [Utility writeData:p.imageData toFile:fullFilePath];
                        }
                    }
                    else
                    {
                        p.imageData = [NSData dataWithContentsOfFile:fullFilePath];
                    }
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
