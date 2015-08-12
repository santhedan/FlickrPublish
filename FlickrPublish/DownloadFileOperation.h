//
//  DownloadFileOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 06/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadFileOperationDelegate <NSObject>

@required

- (void) receivedFileData: (NSData *) imageData;

@optional

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId;

@end

@interface DownloadFileOperation : NSOperation

- (instancetype) initWithURL: (NSString *) urlOfImage Directory: (NSString *) localDirectory Delegate: (id<DownloadFileOperationDelegate>) delegate;

- (instancetype) initWithURL: (NSString *) urlOfImage Directory: (NSString *) localDirectory FileId: (NSString *) fileId Delegate: (id<DownloadFileOperationDelegate>) delegate;

@end
