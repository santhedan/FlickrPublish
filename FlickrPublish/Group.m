//
//  Group.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "Group.h"

@implementation Group

- (NSString *) getDefaultComment
{
    NSString* comment = [NSString stringWithFormat:@"Very nice photo. Thanks for sharing.<br />Seen & Admired in <a href='http://www.flickr.com/groups/%@/'>%@</a><br /><img src='%@' width='75' height='75' alt='%@' /><br />", self.id, self.name, self.groupImagePath, self.name];
    return comment;
}

- (NSComparisonResult)compare: (Group *) otherObject
{
    return [self.name compare:otherObject.name options:NSCaseInsensitiveSearch];
}

- (NSComparisonResult)compareMembers: (Group *) otherObject
{
    if (self.members.doubleValue == otherObject.members.doubleValue) {
        return NSOrderedSame;
    } else if (self.members.doubleValue > otherObject.members.doubleValue) {
        return NSOrderedAscending;
    } else if (self.members.doubleValue < otherObject.members.doubleValue) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)comparePhotos: (Group *) otherObject
{
    if (self.poolPhotoCount.doubleValue == otherObject.poolPhotoCount.doubleValue) {
        return NSOrderedSame;
    } else if (self.poolPhotoCount.doubleValue > otherObject.poolPhotoCount.doubleValue) {
        return NSOrderedAscending;
    } else if (self.poolPhotoCount.doubleValue < otherObject.poolPhotoCount.doubleValue) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@end
