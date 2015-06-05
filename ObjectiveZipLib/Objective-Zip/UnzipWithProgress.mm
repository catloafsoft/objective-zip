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
   NSArray * _zipRequiredFiles;
   NSURL *   _extractionURL;
}

@end


//
// UnzipWithProgress
//
@implementation UnzipWithProgress

- (id) initWithZipFilePath:(NSURL *)zipFileURL
             requiredFiles:(NSArray *)requiredFiles
               andDelegate:(id<ProgressDelegate>)delegate
{
   if (self = [super initWithZipFile:zipFileURL forMode:ZipFileModeUnzip withDelegate:delegate])
   {
      _zipRequiredFiles = requiredFiles;
   }
   
   return self;
}

- (NSArray *) zipFileList
{
   NSMutableArray * result = nil;
   NSArray * fileInfoList = [_zipTool listFileInZipInfos];
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
   if ( [self totalDstinationFileSize] == 0) return NO;
   if (![self insureCanUnzipToLocation:unzipToFolder]) return NO;
   if (![self insureAdequateDiskSpace:unzipToFolder]) return NO;

   return YES;
}

- (BOOL) unzipOneFile:(NSString *)fileName toLocation:(NSURL *)unzipToFolder
{
   BOOL result = NO;
   
   if (![self insureCanUnzipToLocation:unzipToFolder]) return result;
   
   // find the stream and info for the file in the archive
   FileInZipInfo * fileInfo = nil;
   ZipReadStream * readStream = nil;
   
   [_zipTool goToFirstFileInZip];
   
   do
   {
      FileInZipInfo * info = [_zipTool getCurrentFileInZipInfo];
      if ([info.name compare:fileName] == NSOrderedSame)
      {
         readStream = [_zipTool readCurrentFileInZip];
         fileInfo = info;
         break;
      }
   } while ([_zipTool goToNextFileInZip]);
   
   
   if (readStream == nil || fileInfo == nil) return result;
   if (![self insureAdequateDiskSpaceInFolder:unzipToFolder forSize:fileInfo.size]) return NO;
   
   // extract the file
   _totalDestinationBytesWritten = 0;
   result = [self extractStream:readStream
                       toFolder:unzipToFolder
                       withInfo:fileInfo
                 singleFileOnly:YES];
   
   [readStream finishedReading];
   
   return result;
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
   if (![self prepareForOperation]) return;
   
   if (self.cancelOperation) return [self setCancelErrorAndCleanup];
   
   if ([self createUnZipFolderAtURL:unzipToFolder] == NO) return;
                           
   if ([self insureAdequateDiskSpace:unzipToFolder] == NO)  return;
   
   [_zipTool goToFirstFileInZip];
   
   do
   {
      FileInZipInfo * info = [_zipTool getCurrentFileInZipInfo];
      
      ZipReadStream * readStream = [_zipTool readCurrentFileInZip];
      
      [self extractStream:readStream
                 toFolder:_extractionURL
                 withInfo:info
           singleFileOnly:NO];
      
      [readStream finishedReading];
      
      if (_zipFileError != nil) break;
      if (self.cancelOperation)
      {
         [self setCancelErrorAndCleanup];
         break;
      }
      
   } while ([_zipTool goToNextFileInZip]);
}

- (void) unzipToLocation:(NSURL *)unzipToFolder
     withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion
{
   self.cancelOperation = NO;
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue,
                     ^{
                        [self unzipToLocation:unzipToFolder];
                        [self performZipToolCleanup];
                        if (completion) completion(_extractionURL, _zipFileError);
                     });
      
   }
   else
   {
      [self performZipToolCleanup];
      
      NSString * message = @"Failed to get a system queue to extract date from zip file";
      [self setErrorCode:2 errorMessage:message andNotify:((completion)? NO : YES)];
      
      if (completion) completion(_extractionURL, _zipFileError);
   }
}


#pragma mark helpers

- (void) performFileCleanup
{
   // clean up all of the files we have created
   [super performFileCleanup];
   
   if (_extractionURL)
   {
      NSError * error = nil;
      BOOL result = [[NSFileManager defaultManager] removeItemAtURL:_extractionURL error:&error];
      if (result == NO || error != nil)
         [self setError:error andNotify:YES];
   }
}

- (BOOL) insureRequiredFilesExist:(NSArray *)requredFiles
{
   if (requredFiles == nil) return YES;
   
   NSUInteger numFilesInZip = [_zipTool numFilesInZip];
   if (numFilesInZip == 0) return NO;

   NSArray * fileInfoList = [_zipTool listFileInZipInfos];
   for (NSString * name in requredFiles)
      for (FileInZipInfo * info in fileInfoList)
         if ([name compare:info.name] != NSOrderedSame)
            return NO;
   
   return YES;
}

- (NSUInteger) totalDstinationFileSize
{
   if (_totalFileSize) return _totalFileSize;
   
   NSArray * fileInfoList = [_zipTool listFileInZipInfos];
   for (FileInZipInfo * info in fileInfoList)
      _totalFileSize += info.size;
   
   return _totalFileSize;
}

- (BOOL) insureCanUnzipToLocation:(NSURL *)folderToUnzipTo
{
   NSFileManager * manager = [NSFileManager defaultManager];
   BOOL isFolder = NO;
   BOOL success = [manager fileExistsAtPath:[folderToUnzipTo path] isDirectory:&isFolder];
   if (success == NO || isFolder == NO)
      return NO;
   
   NSString * tmpString = [folderToUnzipTo path];
   if (![tmpString hasSuffix:@"/"])
      tmpString = [tmpString stringByAppendingString:@"/"];
   
   return [manager isWritableFileAtPath:tmpString];
}

- (BOOL) insureAdequateDiskSpaceInFolder:(NSURL *)folderToUnzipTo
                                 forSize:(unsigned long long) spaceNeeded
{
   static const unsigned long long s_freeSpaceBuffer = 1024 * 10000; // 10 MB buffer min disk space
   if (spaceNeeded)
   {
      NSError * error = nil;
      NSDictionary * dict = [[NSFileManager defaultManager]
                             attributesOfFileSystemForPath:[folderToUnzipTo path] error:&error];
      
      if (dict == nil || error != nil) return NO;
      
      unsigned long long freeSpace =
      [[dict objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
      
      if (freeSpace < s_freeSpaceBuffer) return NO;
      if (spaceNeeded >= (freeSpace - s_freeSpaceBuffer)) return NO;
   }
   
   return YES;
}

- (BOOL) insureAdequateDiskSpace:(NSURL *)folderToUnzipTo
{
   unsigned long long spaceNeeded = [self totalDstinationFileSize];
   return [self insureAdequateDiskSpaceInFolder:folderToUnzipTo forSize:spaceNeeded];
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
   
   [self addToFilesCreated:fullUrl];
   
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
         if (self.cancelOperation) break;
         
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
