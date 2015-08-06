//
//  DownloadFileOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 06/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "DownloadFileOperation.h"
#import "Utility.h"

@interface DownloadFileOperation()

@property (nonatomic, strong) NSString* urlOfImage;

@property (nonatomic, strong) NSString* localDirectory;

@property (nonatomic, strong) id<DownloadFileOperationDelegate> delegate;

@end

@implementation DownloadFileOperation

- (instancetype) initWithURL: (NSString *) urlOfImage Directory: (NSString *) localDirectory Delegate: (id<DownloadFileOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.urlOfImage = urlOfImage;
        self.localDirectory = localDirectory;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // Local vars
    NSError* localError = nil;
    // Get the last path component of the URL
    NSString* fileName = [self.urlOfImage lastPathComponent];
    //DO we have to save the file locally?
    if (self.localDirectory != nil)
    {
        // Now create path to the file in documents directory
        NSString* fullFilePath = [NSString pathWithComponents:[NSArray arrayWithObjects:[Utility applicationDocumentsDirectory], self.localDirectory, fileName, nil]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath])
        {
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlOfImage]];
            // Create directory
            NSString* dirPath = [fullFilePath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&localError];
            if (localError == nil)
            {
                [Utility writeData:imageData toFile:fullFilePath];
            }
            [self.delegate receivedFileData:imageData];
        }
        else
        {
            NSData* imageData = [NSData dataWithContentsOfFile:fullFilePath];
            [self.delegate receivedFileData:imageData];
        }
    }
    else
    {
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: self.urlOfImage]];
        [self.delegate receivedFileData:imageData];
    }
}

@end
