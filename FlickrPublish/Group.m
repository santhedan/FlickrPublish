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
    NSString* comment = [NSString stringWithFormat:@"<b>Very nice photo. Thanks for sharing.</b>\nSeen & Admired in <a href='http://www.flickr.com/groups/%@/'>%@</a>\n<img src='%@' width='75' height='75' alt='%@' />\n<b>Commented using </b><a href='https://itunes.apple.com/us/app/fotopub-for-flickr/id1020917730?mt=8'>&nbsp;&nbsp;FotoPub for Flickr</a>\n<img src='https://c2.staticflickr.com/4/3761/20292546278_f0fcbec8f7_s.jpg' width='75' height='75' alt='FotoPub for Flickr' />\n", self.id, self.name, self.groupImagePath, self.name];
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
