//
//  ZipProgressBase.mm
//

#import "ZipProgressBase.h"

#import "ZipException.h"
#import "ZipErrorCodes.h"
#import "ZipFile.h"


//
// ZipProgressBase private interface
//
@interface ZipProgressBase()
{
   NSMutableArray *  _filesCreated;
   ZipFileMode       _zipFileMode;
}

@end


//
// ZipProgressBase   
//
@implementation ZipProgressBase

- (id) initWithZipFile:(NSURL *)zipFileURL
               forMode:(unsigned) mode
          withDelegate:(id<ProgressDelegate>)delegate;
{
   if (self = [self init])
   {
      [self setProgressDelegate:delegate];
      
      _zipFileURL = [zipFileURL copy];
      _zipFileMode = (ZipFileMode)mode;
      
      if (![self createZipToolIfNeeded]) return nil;
   }
   
   return self;
}

- (void)dealloc
{
   [self performZipToolCleanup];
}

- (void) setProgressDelegate:(id<ProgressDelegate>)delegate
{
   _zipDelegate = delegate;
}

#pragma mark helpers
// protected methods

- (BOOL) createZipToolIfNeeded
{
   if (_zipTool == nil)
   {
      @try
      {
         _zipTool = [[ZipFile alloc] initWithFileName:[_zipFileURL path] mode:_zipFileMode];
      }
      @catch (ZipException * exception)
      {
         [self setErrorCode:exception.error errorMessage:exception.reason andNotify:YES];
         _zipTool = nil;   // something failed during initialization
      }
   }
   
   return (_zipTool != nil);
}

- (void) performZipToolCleanup
{
   if (_zipTool)
   {
      [_zipTool close];
      _zipTool = nil;
   }
}

- (BOOL) prepareForOperation
{
   _totalDestinationBytesWritten = 0;
   [_filesCreated removeAllObjects];
   [self createZipToolIfNeeded];
   
   return (_zipTool == nil)? NO : YES;
}

- (void) addToFilesCreated:(NSURL *) url
{
   if (_filesCreated == nil)
      _filesCreated = [NSMutableArray new];
   
   if (url)
      [_filesCreated addObject:url];
}

- (void) performFileCleanup
{
   // release the zip tool so it is not hanging onto any files
   [self performZipToolCleanup];
   
   // clean up all of the files we have created
   for (NSURL * url in _filesCreated)
   {
      NSError * error = nil;
      BOOL result = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
      if (result == NO || error != nil)
         [self notifyError:error];
   }
}

- (void) notifyError:(NSError *)error
{
   if (_zipDelegate && error)
   {
      [_zipDelegate updateError:error];
   }
}

- (void) setError:(NSError *)error andNotify:(BOOL)notify
{
   if (error)
   {
      _zipFileError = error;
      if (notify) [self notifyError:_zipFileError];
   }
}

- (void) setErrorCode:(NSInteger)code errorMessage:(NSString *)message andNotify:(BOOL)notify
{
   if (message == nil) message = kOZCEM_IndeterminateError;
   
   [self setError:[NSError errorWithDomain:kOZCEM_ZipErrorDomain
                                      code:code
                                  userInfo:[NSDictionary
                                            dictionaryWithObject:message
                                            forKey:NSLocalizedDescriptionKey]]
        andNotify:notify];
}

- (void) setCancelError
{
   [self setErrorCode:kOZCEC_UserCancelledError
         errorMessage:kOZCEM_UserCancelledError
            andNotify:YES];
}

- (void) setCancelErrorAndCleanup
{
   [self setCancelError];
   [self performFileCleanup];
}

- (BOOL) insureAdequateDiskSpaceInFolder:(NSURL *)location
                                 forSize:(unsigned long long) spaceNeeded
                      andFreeSpaceBuffer:(unsigned long long) bufferSpaceRemaining
{
   if (spaceNeeded)
   {
      NSError * error = nil;
      NSDictionary * dict = [[NSFileManager defaultManager]
                             attributesOfFileSystemForPath:[location path] error:&error];
      
      if (dict == nil || error != nil)
      {
         [self setErrorCode:kOZCEC_CannotReadSystemFolderAttributes
               errorMessage:kOZCEM_CannotReadSystemFolderAttributes
                  andNotify:YES];
         return NO;
      }
      
      unsigned long long freeSpace =
         [[dict objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
      
      if (freeSpace < bufferSpaceRemaining)
      {
         [self setErrorCode:kOZCEC_NotEnoughDiskSpace
               errorMessage:kOZCEM_NotEnoughDiskSpace
                  andNotify:YES];
         return NO;
      }
      
      if (spaceNeeded >= (freeSpace - bufferSpaceRemaining))
      {
         [self setErrorCode:kOZCEC_NotEnoughDiskSpace
               errorMessage:kOZCEM_NotEnoughDiskSpace
                  andNotify:YES];
         return NO;
      }
   }
   
   return YES;
}

@end
