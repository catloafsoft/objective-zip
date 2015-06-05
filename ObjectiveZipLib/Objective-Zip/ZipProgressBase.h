//
//  ZipProgressBase.h
//

#import <Foundation/Foundation.h>
#import "ProgressDelegate.h"

#include <map>
#include <string>


// forward declarations
@class ZipFile;


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

// ideally, protected methods
- (id) initWithZipFile:(NSURL *)zipFileURL
               forMode:(unsigned) mode
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
