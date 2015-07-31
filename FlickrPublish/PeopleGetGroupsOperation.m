//
//  PeopleGetGroupsOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PeopleGetGroupsOperation.h"
#import "Group.h"
#import "Constants.h"
#import "Utility.h"

@interface PeopleGetGroupsOperation()

@property (nonatomic, strong) PeopleGetGroups* request;

@property (nonatomic, strong) id<PeopleGetGroupsOperationHandler> delegate;

@property (nonatomic, strong) NSArray *groupsToExclude;

@end

@implementation PeopleGetGroupsOperation

- (instancetype) initWithRequest: (PeopleGetGroups *) request ExcludeGroups: (NSArray *) groupsToExclude Delegate:(id<PeopleGetGroupsOperationHandler>) delegate
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.delegate = delegate;
        self.groupsToExclude = groupsToExclude;
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
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* dictGroups = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [dictGroups valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* groupsArr = [[dictGroups valueForKey:@"groups"] valueForKey:@"group"];
                for (NSDictionary *group in groupsArr)
                {
                    Group* g = [[Group alloc] init];
                    g.id = [group valueForKey:@"nsid"];
                    // return groups that do not exist in the exclude groups list
                    if (![self.groupsToExclude containsObject:g.id])
                    {
                        g.name = [group valueForKey:@"name"];
                        g.members = [group valueForKey:@"members"];
                        g.poolPhotoCount = [group valueForKey:@"pool_count"];
                        
                        NSNumber* isAdmin = [group valueForKey:@"is_admin"];
                        NSNumber* isMod = [group valueForKey:@"is_moderator"];
                        NSNumber* isMem = [group valueForKey:@"is_member"];
                        
                        if (isAdmin.intValue == 1)
                        {
                            g.memType = ADMIN;
                        }
                        else if (isMod.intValue == 1)
                        {
                            g.memType = MODERATOR;
                        }
                        else if (isMem.intValue == 1)
                        {
                            g.memType = MEMBER;
                        }
                        
                        NSString* iconFarm = [group valueForKey:@"iconfarm"];
                        NSString* iconServer = [group valueForKey:@"iconserver"];
                        
                        g.remaining = ((NSString *)[[group valueForKey:@"throttle"] valueForKey:@"remaining"]).integerValue;
                        g.throttleCount = ((NSString *)[[group valueForKey:@"throttle"] valueForKey:@"count"]).integerValue;
                        g.throttleMode = [[group valueForKey:@"throttle"] valueForKey:@"mode"];

                        NSString* imageUrlPath = [NSString stringWithFormat:GROUP_IMAGE_URL, iconFarm, iconServer, g.id];
                        
                        // Get the last path component of the URL
                        NSString* fileName = [imageUrlPath lastPathComponent];
                        // Now create path to the file in documents directory
                        NSString* fullFilePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[Utility applicationDocumentsDirectory], g.id, fileName, nil]];
                        if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
                        {
                            g.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlPath]];
                            // Create directory
                            NSString* dirPath = [fullFilePath stringByDeletingLastPathComponent];
                            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&localError];
                            if (localError == nil)
                            {
                                [Utility writeData:g.imageData toFile:fullFilePath];
                            }
                        }
                        else
                        {
                            g.imageData = [NSData dataWithContentsOfFile:fullFilePath];
                        }
                        [groups addObject:g];
                    }
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedGroups: groups];
}

@end
