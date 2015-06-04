//
//  UnzipWithProgress.mm
//

#import "UnzipWithProgress.h"

#import "FileInZipInfo.h"
#import "ZipException.h"
#import "ZipFile.h"
#import "ZipReadStream.h"

#include <set>

//
// UnzipWithProgress private interface
//
@interface UnzipWithProgress()
{
   NSArray *            _zipRequiredFiles;
   NSMutableArray *     _filesUnzipped;
   NSURL *              _zipFileURL;
   NSURL *              _extractionURL;
   NSError *            _zipFileError;
   ZipFile *            _zipFile;
   id<ProgressDelegate> _zipDelegate;
   
   unsigned long long   _totalDestinationFileSize;
   unsigned long long   _totalDestinationBytesWritten;
}

@end


//
// UnzipWithProgress
//
@implementation UnzipWithProgress

- (void) createZipFileIfNeeded
{
   if (_zipFile == nil)
   {
      @try
      {
         _zipFile = [[ZipFile alloc] initWithFileName:[_zipFileURL path] mode:ZipFileModeUnzip];
      }
      @catch (NSException * exception)
      {
         [self setErrorCode:10 errorMessage:exception.reason andNotify:YES];
         _zipFile = nil;   // something failed during initialization
      }
   }
}

- (id) initWithZipFilePath:(NSURL *)zipFileURL andArray:(NSArray *)requiredFiles
{
   if (self = [self init])
   {
      _zipFileURL = zipFileURL;
      _zipRequiredFiles = requiredFiles;
      [self createZipFileIfNeeded];
      if (_zipFile == nil) return nil;
   }
   
   return self;
}

- (void)dealloc
{
   [_zipFile close];
}

- (void) setProgressDelegate:(id<ProgressDelegate>)delegate
{
   _zipDelegate = delegate;
}

- (NSArray *) zipFileList
{
   NSMutableArray * result = nil;
   NSArray * fileInfoList = [_zipFile listFileInZipInfos];
   if (fileInfoList.count)
   {
      result = [NSMutableArray arrayWithCapacity:fileInfoList.count];
      for (FileInZipInfo * info in fileInfoList)
         if (info.name)
            [result addObject:info.name];
   }
   
   return result;
}

- (BOOL) canUnzipToLocation:(NSURL *)unzipToFolder;
{
   if (![self insureRequiredFilesExist:_zipRequiredFiles]) return NO;
   if ([self totalDstinationFileSize] == 0) return NO;
   if (![self insureCanUnzipToLocation:unzipToFolder]) return NO;
   if (![self insureAdequateDiskSpace:unzipToFolder]) return NO;

   return YES;
}

- (void) unzipOneFile:(NSString *)fileName toLocation:(NSURL *)unzipToFolder
{
   FileInZipInfo * fileInfo = nil;
   ZipReadStream * readStream = nil;
   
   if ([_zipFile locateFileInZip:fileName])
   {
      FileInZipInfo * info = [ _zipFile getCurrentFileInZipInfo];
      if ([info.name compare:fileName] == NSOrderedSame)
      {
         readStream = [_zipFile readCurrentFileInZip];
         fileInfo = info;
      }
   }
   
   if (readStream == nil)
   {
      // do a case insensitive search for the file
      [_zipFile goToFirstFileInZip];
      
      do
      {
         FileInZipInfo * info = [_zipFile getCurrentFileInZipInfo];
         if ([info.name compare:fileName options:NSCaseInsensitiveSearch] == NSOrderedSame)
         {
            readStream = [_zipFile readCurrentFileInZip];
            fileInfo = info;
            break;
         }
      } while ([_zipFile goToNextFileInZip]);
   }
   
   if (readStream != nil)
   {
      _totalDestinationBytesWritten = 0;
      [self extractStream:readStream
                 toFolder:unzipToFolder
                 withInfo:fileInfo
           singleFileOnly:YES];
      
      [readStream finishedReading];
   }
}

- (void) addToFilesUnzipped:(NSURL *) url
{
   if (_filesUnzipped == nil)
      _filesUnzipped = [NSMutableArray new];
   
   if (url)
      [_filesUnzipped addObject:url];
}

- (BOOL) createUnZipFolderAtURL:(NSURL *)unzipToFolder
{
   NSFileManager * manager = [NSFileManager defaultManager];
   BOOL isFolder = NO;
   BOOL success = [manager fileExistsAtPath:[unzipToFolder path] isDirectory:&isFolder];
   if (success == NO || isFolder == NO)
   {
      // TODO:LEA: Put a valid message and code here
      int errorCode = 3;
      NSString * message = @"Extraction path does not exist";
      [self setErrorCode:errorCode errorMessage:message andNotify:YES];
      return NO;
   }
   
   if (_extractionURL) _extractionURL = nil;
   
   NSURL * lastComponent = [NSURL URLWithString:[_zipFileURL lastPathComponent]];
   NSString * folderPart = [[lastComponent URLByDeletingPathExtension] path];

   unsigned loopCount = 1;
   
   do
   {
      NSError * error = nil;
      NSString * folder =
         (loopCount > 1)? [NSString stringWithFormat:@"%@ %u", folderPart, loopCount] : folderPart;
      
      NSURL * fullPath = [unzipToFolder URLByAppendingPathComponent:folder isDirectory:YES];
      
      success = [manager createDirectoryAtPath:[fullPath path]
                   withIntermediateDirectories:NO
                                    attributes:nil
                                         error:&error];
      if (success == NO || error != nil)
         ++loopCount;
      else
         _extractionURL = fullPath;
      
   } while (_extractionURL == nil && loopCount < 1000);
   
   
   if (_extractionURL == nil)
   {
      // TODO:LEA: Put a valid message and code here
      int errorCode = 3;
      NSString * message = @"Could not create folder to extract zip file into";
      [self setErrorCode:errorCode errorMessage:message andNotify:YES];
      return NO;
   }
   
   return YES;
}

- (void) unzipToLocation:(NSURL *)unzipToFolder
{
   _totalDestinationBytesWritten = 0;
   [_filesUnzipped removeAllObjects];
   
   [self createZipFileIfNeeded];
   
   if (_zipFile == nil) return;
   
   if (self.cancelUnzip) [self setCancelErrorAndCleanup];
   
   if ([self createUnZipFolderAtURL:unzipToFolder] == NO) return;
                           
   if ([self insureAdequateDiskSpace:unzipToFolder] == NO)  return;
   
   [_zipFile goToFirstFileInZip];
   
   do
   {
      FileInZipInfo * info = [_zipFile getCurrentFileInZipInfo];
      
      ZipReadStream * readStream = [_zipFile readCurrentFileInZip];
      
      [self extractStream:readStream
                 toFolder:_extractionURL
                 withInfo:info
           singleFileOnly:NO];
      
      [readStream finishedReading];
      
      if (_zipFileError != nil) break;
      if (self.cancelUnzip)
      {
         [self setCancelErrorAndCleanup];
         break;
      }
      
   } while ([_zipFile goToNextFileInZip]);
}

- (void) cleanUpUnarchiver
{
   if (_zipFile)
   {
      [_zipFile close];
      _zipFile = nil;
   }
}

- (void) unzipToLocation:(NSURL *)unzipToFolder
     withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion
{
   self.cancelUnzip = NO;
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue,
                     ^{
                        [self unzipToLocation:unzipToFolder];
                        [self cleanUpUnarchiver];
                        if (completion) completion(_extractionURL, _zipFileError);
                     });
      
   }
   else
   {
      [_zipFile close];
      _zipFile = nil;
      
      NSString * message = @"Failed to get a system queue to extract date from zip file";
      [self setErrorCode:2 errorMessage:message andNotify:((completion)? NO : YES)];
      
      if (completion) completion(_extractionURL, _zipFileError);
   }
}


#pragma mark helpers
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

- (void) performFileCleanup
{
   // clean up all of the files we have created
   for (NSURL * url in _filesUnzipped)
   {
      NSError * error = nil;
      BOOL result = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
      if (result == NO || error != nil)
         [self setError:error andNotify:YES];
   }
   
   if (_extractionURL)
   {
      NSError * error = nil;
      BOOL result = [[NSFileManager defaultManager] removeItemAtURL:_extractionURL error:&error];
      if (result == NO || error != nil)
         [self setError:error andNotify:YES];
   }
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

- (BOOL) insureRequiredFilesExist:(NSArray *)requredFiles
{
   if (requredFiles == nil) return YES;
   
   NSUInteger numFilesInZip = [_zipFile numFilesInZip];
   if (numFilesInZip == 0) return NO;

   NSArray * fileInfoList = [_zipFile listFileInZipInfos];
   for (NSString * name in requredFiles)
      for (FileInZipInfo * info in fileInfoList)
         if ([name compare:info.name] != NSOrderedSame)
            return NO;
   
   return YES;
}

- (NSUInteger) totalDstinationFileSize
{
   if (_totalDestinationFileSize) return _totalDestinationFileSize;
   
   NSArray * fileInfoList = [_zipFile listFileInZipInfos];
   for (FileInZipInfo * info in fileInfoList)
      _totalDestinationFileSize += info.size;
   
   return _totalDestinationFileSize;
}

- (BOOL) insureCanUnzipToLocation:(NSURL *)folderToUnzipTo
{
   // TODO:LEA: test for write access to folder
   return YES;
}

- (BOOL) insureAdequateDiskSpace:(NSURL *)folderToUnzipTo
{
   NSUInteger spaceNeeded = [self totalDstinationFileSize];
   if (spaceNeeded) return YES;
   // TODO:LEA: need to check for enough space in the destination location
   return YES;
}

- (void) updateProgress:(unsigned long long) bytesReadFromFile
             forFileURL:(NSURL *)fileUrl
            withFileInfo:(FileInZipInfo*) info
         singleFileOnly:(BOOL) singleFileOnly
{
   if (_zipDelegate == nil) return;
   
   double progress = (info.size)? static_cast<double>(bytesReadFromFile) / info.size : 0;
   
   // update current file progress
   if ([_zipDelegate respondsToSelector:@selector(updateProgress:forFile:)])
      [_zipDelegate updateProgress:progress forFile:fileUrl];
   
   // update overall progress
   if (singleFileOnly == NO)
   {
      double totalToSend = self.totalDstinationFileSize;
      progress = (totalToSend)? _totalDestinationBytesWritten / totalToSend : 0;
   }
   
   [_zipDelegate updateProgress:progress];
}

- (BOOL) extractStream:(ZipReadStream *) readStream
              toFolder:(NSURL *) unzipToFolder
              withInfo:(FileInZipInfo *) info
        singleFileOnly:(BOOL) singleFileOnly
{
   BOOL result = NO;
   
   NSURL * fullUrl = [unzipToFolder URLByAppendingPathComponent:info.name];
   
   if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
      [_zipDelegate  updateCurrentFile:fullUrl];
   
   // create an empty file - don't overwrite an existing file
   NSError * error = nil;
   NSData * emptyData = [NSData new];
   BOOL success = [emptyData writeToURL:fullUrl
                                options:NSDataWritingWithoutOverwriting
                                  error:&error];
   
   if (success == NO || error != nil)
   {
      [self setError:error andNotify:YES];
      return result;
   }
   
   [self addToFilesUnzipped:fullUrl];
   
   // open a file handle for writing to the file
   error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForWritingToURL:fullUrl  error:&error];
   if (handle == nil || error != nil)
   {
      [self setError:error andNotify:YES];
      return result;
   }
   
   [handle seekToFileOffset:0];
   
   if (info.size == 0)
   {
      // zipfile contains a file with 0 byte length?
      // should we write out the file anyways?
      [handle closeFile];
      return result;
   }
   
   unsigned long long totalBytesWritten = 0;
   unsigned long  bytesToRead = 1024 * 64; // read/write 64k at a time
   
   [self updateProgress:totalBytesWritten
             forFileURL:fullUrl
           withFileInfo:info
         singleFileOnly:singleFileOnly];
   
   @try
   {
      do
      {
         if (self.cancelUnzip) break;
         
         if (bytesToRead > (info.size - totalBytesWritten))
            bytesToRead = info.size - totalBytesWritten;
         
         NSData * data = [readStream readDataOfLength:bytesToRead];
         [handle writeData:data];
         totalBytesWritten += data.length;
         _totalDestinationBytesWritten += data.length;
         
         [self updateProgress:totalBytesWritten
                   forFileURL:fullUrl
                 withFileInfo:info
               singleFileOnly:singleFileOnly];
         
      } while (totalBytesWritten < info.size);
      
      result = YES;
   }
   @catch (ZipException *ze)
   {
      NSString * reason = [ze reason];
      [self setErrorCode:ze.error errorMessage:reason andNotify:YES];
   }
   @catch (id e)
   {
      NSString * reason = [e description];
      [self setErrorCode:1 errorMessage:reason andNotify:YES];
   }
   
   [handle closeFile];
   
   return result;
}


@end
