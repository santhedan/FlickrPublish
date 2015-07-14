//
//  PhotosetGetListOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 13/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosetGetListOperation.h"
#import "PhotoSet.h"

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
    NSLog(@"URL -> %@", [url description]);
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
                    NSDictionary* nameDict = [set valueForKey:@"title"];
                    pset.name = [nameDict valueForKey:@"_content"];
                    [photosets addObject:pset];
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedPhotoSets: photosets];
}

@end
