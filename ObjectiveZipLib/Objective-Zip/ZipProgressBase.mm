//
//  ZipProgressBase.mm
//

#import "ZipProgressBase.h"

#import "FileInZipInfo.h"
#import "ZipException.h"
#import "ZipFile.h"
#import "ZipReadStream.h"


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
               forMode:(ZipFileMode) mode
          withDelegate:(id<ProgressDelegate>)delegate;
{
   if (self = [self init])
   {
      _zipFileURL = zipFileURL;
      _zipFileMode = mode;
      
      if (![self createZipToolIfNeeded]) return nil;
      
      _zipDelegate = delegate;
   }
   
   return self;
}

- (void)dealloc
{
   [self performZipToolCleanup];
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
      @catch (NSException * exception)
      {
         [self setErrorCode:10 errorMessage:exception.reason andNotify:YES];
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
         [self setError:error andNotify:YES];
   }
}

- (void) setError:(NSError *)error andNotify:(BOOL)notify
{
   if (error)
   {
      _zipFileError = error;
      if (notify) [_zipDelegate updateError:_zipFileError];
   }
}

- (void) setErrorCode:(NSInteger)code errorMessage:(NSString *)message andNotify:(BOOL)notify
{
   if (message == nil) message = @"Unknown failure";
   
   [self setError:[NSError errorWithDomain:@"ZipException"
                                      code:code
                                  userInfo:[NSDictionary
                                            dictionaryWithObject:message
                                            forKey:NSLocalizedDescriptionKey]]
        andNotify:notify];
}

- (void) setCancelError
{
   NSString * message = @"User cancelled error";
   [self setErrorCode:-128 errorMessage:message andNotify:YES];
}

- (void) setCancelErrorAndCleanup
{
   [self setCancelError];
   [self performFileCleanup];
}



@end
