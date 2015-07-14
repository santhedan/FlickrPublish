//
//  Utility.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString *)applicationDocumentsDirectory;

+ (BOOL) writeData: (NSData*) data toFile: (NSString*) filePath;

@end
