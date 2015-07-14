//
//  Utility.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (BOOL) writeData: (NSData*) data toFile: (NSString*) filePath
{
    NSError* error;
    BOOL retval = [data writeToFile:filePath options:0 error:&error];
    return retval;
}

@end
