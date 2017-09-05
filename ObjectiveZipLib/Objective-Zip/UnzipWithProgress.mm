//
//  UnzipWithProgress.mm
//

#import "UnzipWithProgress.h"

#import "FileInZipInfo.h"
#import "ZipErrorCodes.h"
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
   if (![self insureAdequateDiskSpace:unzipToFolder]) return NO;

   return YES;
}

- (BOOL) unzipOneFile:(NSString *)fileName toLocation:(NSURL *)unzipToFolder
{
   static const unsigned long long s_freeSpaceBuffer = 1024 * 1000 * 10; // 10 MB buffer min disk space
   
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
   
   
   if (readStream == nil || fileInfo == nil)
   {
      [self setErrorCode:ZipErrorCodes.OUZEC_CannotFindInfoForFileInArchive
            errorMessage:ZipErrorCodes.OUZEM_CannotFindInfoForFileInArchive
               andNotify:YES];
      return result;
   }
   
   if (![self insureAdequateDiskSpaceInFolder:unzipToFolder
                                      forSize:fileInfo.length
                           andFreeSpaceBuffer:s_freeSpaceBuffer]) return NO;
   
   // extract the file
   _totalDestinationBytesWritten = 0;
   result = [self extractStream:readStream
                       toFolder:unzipToFolder
                       withInfo:fileInfo
                 singleFileOnly:YES];
   
   [readStream finishedReading];
   
   return result;
}

- (BOOL) createUnZipFolderAtURL:(NSURL *)destinationFolder
{
   NSFileManager * manager = [NSFileManager defaultManager];
   BOOL isFolder = NO;
   BOOL success = [manager fileExistsAtPath:[[destinationFolder URLByDeletingLastPathComponent] path] isDirectory:&isFolder];
   if (success == NO || isFolder == NO)
   {
      [self setErrorCode:ZipErrorCodes.OUZEC_PathDoesNotExist
            errorMessage:ZipErrorCodes.OUZEM_PathDoesNotExist
               andNotify:YES];
      return NO;
   }
   
   if (_extractionURL) _extractionURL = nil;
   
   NSError * error = nil;

   NSURL * fullPath = destinationFolder;
   
   success = [manager createDirectoryAtPath:[fullPath path]
                withIntermediateDirectories:NO
                                 attributes:nil
                                      error:&error];
   if (success == YES && error == nil)
      _extractionURL = fullPath;
      
   if (_extractionURL == nil)
   {
      [self setErrorCode:ZipErrorCodes.OUZEC_CannotCreateFolder
            errorMessage:ZipErrorCodes.OUZEM_CannotCreateFolder
               andNotify:YES];
      return NO;
   }
   
   return YES;
}

- (void) unzipToURL:(NSURL *)destinationFolder
{
   if (![self prepareForOperation]) return;
   
   if (self.cancelOperation) return [self setCancelErrorAndCleanup];
   
   if ([self createUnZipFolderAtURL:destinationFolder] == NO) return;
                           
   if ([self insureAdequateDiskSpace:destinationFolder] == NO)  return;
   
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

- (void) unzipToURL:(NSURL *)destinationFolder
     withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion
{
   self.cancelOperation = NO;
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue,
                     ^{
                        [self unzipToURL:destinationFolder];
                        [self performZipToolCleanup];
                        if (completion) completion(_extractionURL, _zipFileError);
                     });
      
   }
   else
   {
      [self performZipToolCleanup];
      
      [self setErrorCode:ZipErrorCodes.OUZEC_CannotCreateExtractionQueue
            errorMessage:ZipErrorCodes.OUZEM_CannotCreateExtractionQueue
               andNotify:((completion)? NO : YES)];
      
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
         [self notifyError:error];
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
      _totalFileSize += info.length;
   
   return _totalFileSize;
}

- (BOOL) insureCanUnzipToLocation:(NSURL *)folderToUnzipTo
{
   NSFileManager * manager = [NSFileManager defaultManager];
   BOOL isFolder = NO;
   BOOL success = [manager fileExistsAtPath:[folderToUnzipTo path] isDirectory:&isFolder];
   if (success == NO || isFolder == NO)
      return NO;
   
   return [manager isWritableFileAtPath:[folderToUnzipTo path]];
}

- (BOOL) insureAdequateDiskSpace:(NSURL *)folderToUnzipTo
{
   static const unsigned long long s_freeSpaceBuffer = 1024 * 1000 * 10; // 10 MB buffer min disk space
   
   unsigned long long spaceNeeded = [self totalDstinationFileSize];
   return [self insureAdequateDiskSpaceInFolder:folderToUnzipTo
                                        forSize:spaceNeeded
                             andFreeSpaceBuffer:s_freeSpaceBuffer];
}

- (void) updateProgress:(unsigned long long) bytesReadFromFile
             forFileURL:(NSURL *)fileUrl
            withFileInfo:(FileInZipInfo*) info
         singleFileOnly:(BOOL) singleFileOnly
{
   if (_zipDelegate == nil) return;
   
   double progress = (info.length)? static_cast<double>(bytesReadFromFile) / info.length : 0;
   
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
   
   NSURL * fullURL = [unzipToFolder URLByAppendingPathComponent:info.name];
   
   if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
      [_zipDelegate  updateCurrentFile:fullURL];
   
   // create an empty file - don't overwrite an existing file
   NSError * error = nil;
   
   NSURL * parentURL = [fullURL URLByDeletingLastPathComponent];
   NSFileManager * fileManager = [NSFileManager defaultManager];
   
   if ( ![fileManager fileExistsAtPath:parentURL.path] )
   {
      [fileManager createDirectoryAtURL:parentURL withIntermediateDirectories:YES attributes:nil error:&error];
   }
   NSData * emptyData = [NSData new];
   BOOL success = [emptyData writeToURL:fullURL
                                options:NSDataWritingWithoutOverwriting
                                  error:&error];
   
   if (success == NO || error != nil)
   {
      [self setErrorCode:ZipErrorCodes.OUZEC_FileAlreadyExists
            errorMessage:ZipErrorCodes.OUZEM_FileAlreadyExists
               andNotify:YES];
      return result;
   }
   
   [self addToFilesCreated:fullURL];
   
   // open a file handle for writing to the file
   error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForWritingToURL:fullURL  error:&error];
   if (handle == nil || error != nil)
   {
      [self setErrorCode:ZipErrorCodes.OUZEC_FileCouldNotBeOpenedForWriting
            errorMessage:ZipErrorCodes.OUZEM_FileCouldNotBeOpenedForWriting
               andNotify:YES];
      return result;
   }
   
   [handle seekToFileOffset:0];
   
   if (info.length == 0)
   {
      // zipfile contains a file with 0 byte length
      [handle closeFile];
      return YES;
   }
   
   unsigned long long totalBytesWritten = 0;
   unsigned long  bytesToRead = 1024 * 64; // read/write 64k at a time
   
   [self updateProgress:totalBytesWritten
             forFileURL:fullURL
           withFileInfo:info
         singleFileOnly:singleFileOnly];
   
   @try
   {
      do
      {
         if (self.cancelOperation) break;
         
         if (bytesToRead > (info.length - totalBytesWritten))
            bytesToRead = info.length - totalBytesWritten;
         
         NSData * data = [readStream readDataOfLength:bytesToRead];
         [handle writeData:data];
         totalBytesWritten += data.length;
         _totalDestinationBytesWritten += data.length;
         
         [self updateProgress:totalBytesWritten
                   forFileURL:fullURL
                 withFileInfo:info
               singleFileOnly:singleFileOnly];
         
      } while (totalBytesWritten < info.length);
      
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
      [self setErrorCode:ZipErrorCodes.OZCEC_Indeterminate errorMessage:reason andNotify:YES];
   }
   
   [handle closeFile];
   
   return result;
}

@end
