//
//  PeopleGetGroupsOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PeopleGetGroupsOperation.h"
#import "Group.h"

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
    NSLog(@"URL -> %@", [url description]);
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
