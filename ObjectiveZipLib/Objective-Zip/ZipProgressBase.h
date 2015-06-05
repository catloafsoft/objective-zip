//
//  ZipProgressBase.h
//

#import <Foundation/Foundation.h>
#import "ProgressDelegate.h"
#import "ZipFile.h"

#include <map>
#include <string>


//
// ZipProgressBase
//
@interface ZipProgressBase : NSObject
{
@protected
   NSURL *              _zipFileURL;
   NSError *            _zipFileError;
   ZipFile *            _zipTool;
   id<ProgressDelegate> _zipDelegate;
   
   unsigned long long   _totalFileSize;
   unsigned long long   _totalDestinationBytesWritten;
}

// protected methods
- (id) initWithZipFile:(NSURL *)zipFileURL
               forMode:(ZipFileMode) mode
          withDelegate:(id<ProgressDelegate>)delegate;

- (BOOL) createZipToolIfNeeded;
- (void) performZipToolCleanup;

- (BOOL) prepareForOperation;

- (void) addToFilesCreated:(NSURL *) url;
- (void) performFileCleanup;

- (void) setError:(NSError *)error andNotify:(BOOL)notify;
- (void) setErrorCode:(NSInteger)code errorMessage:(NSString *)message andNotify:(BOOL)notify;

- (void) setCancelError;
- (void) setCancelErrorAndCleanup;


// public methods
@property (assign, atomic) BOOL cancelOperation;

@end
