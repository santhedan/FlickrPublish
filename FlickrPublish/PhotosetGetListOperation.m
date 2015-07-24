//
//  PhotosetGetListOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 13/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosetGetListOperation.h"
#import "PhotoSet.h"
#import "Utility.h"

@interface PhotosetGetListOperation()

@property (nonatomic, strong) PhotosetGetList *request;

@property (nonatomic, strong) id<PhotosetGetListHandler> delegate;

@end

@implementation PhotosetGetListOperation

- (instancetype) initWithRequest: (PhotosetGetList *) request Delegate: (id<PhotosetGetListHandler>) delegate
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
    NSMutableArray* photosets = [[NSMutableArray alloc] init];
    // Parse the data
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* dictPhotoSets = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [dictPhotoSets valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* sets = [[dictPhotoSets valueForKey:@"photosets"] valueForKey:@"photoset"];
                for (NSDictionary *set in sets)
                {
                    PhotoSet* pset = [[PhotoSet alloc] init];
                    pset.id = [set valueForKey:@"id"];
                    pset.photos = [NSString stringWithFormat:@"%@", [set valueForKey:@"photos"]];
                    pset.videos = [NSString stringWithFormat:@"%@", [set valueForKey:@"videos"]];
                    pset.views = [NSString stringWithFormat:@"%@", [set valueForKey:@"count_views"]];
                    NSDictionary* nameDict = [set valueForKey:@"title"];
                    pset.name = [nameDict valueForKey:@"_content"];
                    NSDictionary* extraDict = [set valueForKey:@"primary_photo_extras"];
                    NSString* thumbnailPath = [[extraDict valueForKey:@"url_s"] stringByReplacingOccurrencesOfString:@"_m.jpg" withString:@"_q.jpg"];
                    
                    // Get the last path component of the URL
                    NSString* fileName = [thumbnailPath lastPathComponent];
                    // Now create path to the file in documents directory
                    NSString* fullFilePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[Utility applicationDocumentsDirectory], pset.id, fileName, nil]];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
                    {
                        pset.photosetPhoto = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailPath]];
                        // Create directory
                        NSString* dirPath = [fullFilePath stringByDeletingLastPathComponent];
                        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&localError];
                        if (localError == nil)
                        {
                            [Utility writeData:pset.photosetPhoto toFile:fullFilePath];
                        }
                    }
                    else
                    {
                        pset.photosetPhoto = [NSData dataWithContentsOfFile:fullFilePath];
                    }
                    [photosets addObject:pset];
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedPhotoSets: photosets];
}

@end
