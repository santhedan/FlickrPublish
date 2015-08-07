//
//  Photo.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (NSComparisonResult)compareViews: (Photo *) otherObject
{
    if (self.views == otherObject.views) {
        return NSOrderedSame;
    } else if (self.views > otherObject.views) {
        return NSOrderedAscending;
    } else if (self.views < otherObject.views) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareFaves: (Photo *) otherObject
{
    if (self.faves == otherObject.faves) {
        return NSOrderedSame;
    } else if (self.faves > otherObject.faves) {
        return NSOrderedAscending;
    } else if (self.faves < otherObject.faves) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSComparisonResult)compareComments: (Photo *) otherObject
{
    if (self.comments == otherObject.comments) {
        return NSOrderedSame;
    } else if (self.comments > otherObject.comments) {
        return NSOrderedAscending;
    } else if (self.comments < otherObject.comments) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@end
