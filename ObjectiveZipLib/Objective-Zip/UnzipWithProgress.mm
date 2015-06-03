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
   NSString *           _zipFilePath;
   NSURL *              _unzipToFolder;
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

- (id) initWithZipFilePath:(NSString *)zipFilePath andArray:(NSArray *)requiredFiles
{
   if (self = [self init])
   {
      _zipFilePath = zipFilePath;
      _zipRequiredFiles = requiredFiles;
      _zipFile = [[ZipFile alloc] initWithFileName:_zipFilePath mode:ZipFileModeUnzip];
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

- (void) unzipToLocation:(NSURL *)unzipToFolder
{
   if ([self insureAdequateDiskSpace:unzipToFolder] == NO)  return;
       
   _totalDestinationBytesWritten = 0;
   
   [_zipFile goToFirstFileInZip];
   
   do
   {
      FileInZipInfo * info = [_zipFile getCurrentFileInZipInfo];
      
      if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
         [_zipDelegate  updateCurrentFile:info.name];
      
      ZipReadStream * readStream = [_zipFile readCurrentFileInZip];
      
      [self extractStream:readStream
                 toFolder:unzipToFolder
                 withInfo:info
           singleFileOnly:NO];
      
      [readStream finishedReading];
      
   } while ([_zipFile goToNextFileInZip]);
}

- (void) unzipToLocation:(NSURL *)unzipToFolder
     withCompletionBlock:(void(^)(NSError * error))completion
{
   if (_zipFile == nil)
      _zipFile = [[ZipFile alloc] initWithFileName:_zipFilePath mode:ZipFileModeUnzip];
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue, ^{ [self unzipToLocation:unzipToFolder]; });
   }
   else
   {
      NSString * message = @"Failed to get a system queue to extract date from zip file";
      _zipFileError = [NSError errorWithDomain:@"ZipException"
                                          code:2
                                      userInfo:[NSDictionary
                                                dictionaryWithObject:message
                                                forKey:NSLocalizedDescriptionKey]];
      [_zipDelegate updateError:_zipFileError];
   }
   
   [_zipFile close];
   _zipFile = nil;
   
   if (completion) completion(_zipFileError);
}

#pragma mark helpers
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
            forFileInfo:(FileInZipInfo*) info
         singleFileOnly:(BOOL) singleFileOnly
{
   if (_zipDelegate == nil) return;
   
   double progress = (info.size)? static_cast<double>(bytesReadFromFile) / info.size : 0;
   
   // update current file progress
   if ([_zipDelegate respondsToSelector:@selector(updateProgress:forFile:)])
      [_zipDelegate updateProgress:progress forFile:info.name];
   
   // update overall progress
   if (singleFileOnly == NO)
   {
      double totalToSend = self.totalDstinationFileSize;
      progress = (totalToSend)? bytesReadFromFile / totalToSend : 0;
   }
   
   [_zipDelegate updateProgress:progress];
}

- (BOOL) extractStream:(ZipReadStream *) readStream
              toFolder:(NSURL *) unzipToFolder
              withInfo:(FileInZipInfo *) info
        singleFileOnly:(BOOL) singleFileOnly
{
   // TODO:LEA:track if there is an exception or error and clean up after it
   BOOL result = NO;
   
   NSURL * fullUrl = [unzipToFolder URLByAppendingPathComponent:info.name];
   
   // create an empty file - don't overwrite an existing file
   NSError * error = nil;
   NSData * emptyData = [NSData new];
   BOOL success = [emptyData writeToURL:fullUrl
                                options:NSDataWritingWithoutOverwriting
                                  error:&error];
   
   if (success == NO || error != nil)
   {
      _zipFileError = error;
      [_zipDelegate updateError:_zipFileError];
      return result;
   }
   
   // open a file handle for writing to the file
   error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForWritingToURL:fullUrl  error:&error];
   if (handle == nil || error != nil)
   {
      _zipFileError = error;
      [_zipDelegate updateError:_zipFileError];
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
            forFileInfo:info
         singleFileOnly:singleFileOnly];
   
   @try
   {
      do
      {
         if (bytesToRead > (info.size - totalBytesWritten))
            bytesToRead = info.size - totalBytesWritten;
         
         NSData * data = [readStream readDataOfLength:bytesToRead];
         [handle writeData:data];
         totalBytesWritten += data.length;
         _totalDestinationBytesWritten += data.length;
         
         [self updateProgress:totalBytesWritten
                  forFileInfo:info
               singleFileOnly:singleFileOnly];
         
      } while (totalBytesWritten < info.size);
      
      result = YES;
   }
   @catch (ZipException *ze)
   {
      NSString * reason = [ze reason];
      if (reason == nil)
         reason = @"Unknown failure";
      
      _zipFileError =
         [NSError errorWithDomain:@"ZipException"
                             code:ze.error
                         userInfo:[NSDictionary dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
      [_zipDelegate updateError:_zipFileError];
   }
   @catch (id e)
   {
      NSString * reason = [e description];
      if (reason == nil)
         reason = @"Unknown failure";
      
      _zipFileError =
         [NSError errorWithDomain:@"ZipException"
                             code:1
                         userInfo:[NSDictionary dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
          
      [_zipDelegate updateError:_zipFileError];
   }
   
   [handle closeFile];
   
   return result;
}


@end
