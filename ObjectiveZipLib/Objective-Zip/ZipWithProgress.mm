//
//  ZipWithProgress.mm
//

#import "ZipWithProgress.h"

#import "ZipException.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"

#include <set>

//
// ZipWithProgress private interface
//
@interface ZipWithProgress()
{
   std::map<std::string, std::string> _zipFileMapping;
}

@end


//
// ZipWithProgress
//
@implementation ZipWithProgress


- (id) initWithZipFilePath:(NSURL *)zipFileURL
                   fileMap:(const std::map<std::string, std::string> &)filesToZip
               andDelegate:(id<ProgressDelegate>)delegate
{
   if (self = [super initWithZipFile:zipFileURL forMode:ZipFileModeCreate withDelegate:delegate])
   {
      _zipFileMapping = filesToZip;
   }
   
   return self;
}

- (BOOL) canZipFiles
{
   // TODO:JUSTIN - some of these functions don't notify the delegate of an error
   if (![self insureNoDuplicates]) return NO; // <-- delegate not notified of error
   if (![self insureSourceFilesExist]) return NO;
   if (![self insureCanCreateZipFileAtLocation]) return NO;  // <-- delegate not notified of error
   if ( [self totalSourceFileSize] == 0) return NO;
   if (![self insureAdequateDiskSpace]) return NO;
   return YES;
}

- (void) createZipFile
{
   if (![self prepareForOperation]) return;
   
   [self addToFilesCreated:_zipFileURL];
   
   if (self.cancelOperation) return [self setCancelErrorAndCleanup];
   
   if (![self canZipFiles]) return [self performFileCleanup];;
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for (; it != _zipFileMapping.end(); ++it)
   {
      NSURL * sourceFileName = [NSURL fileURLWithPath:[NSString stringWithUTF8String:it->first.c_str()]];
      NSString * fileinArchiveName = [NSString stringWithUTF8String:it->second.c_str()];
      
      if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
         [_zipDelegate  updateCurrentFile:sourceFileName];
         
      ZipWriteStream * writeStream = [_zipTool writeFileInZipWithName:fileinArchiveName
                                                     compressionLevel:ZipCompressionLevelNone];
      if (writeStream)
      {
         [self writeStream:writeStream
                   fromURL:sourceFileName
            singleFileOnly:NO];
         
         [writeStream finishedWriting];
         
         if (_zipFileError != nil) break;
         
         if (self.cancelOperation)
         {
            [self setCancelErrorAndCleanup];
            break;
         }
      }
      else
      {
         NSString * message = @"Failed to create write stream for zip file";
         [self setErrorCode:1 errorMessage:message andNotify:YES];
         break;
      }
   }
}

- (void) createZipFileWithCompletionBlock:(void(^)(NSError * error))completion
{
   self.cancelOperation = NO;
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue,
                     ^{
                        [self createZipFile];
                        [self performZipToolCleanup];
                        if (completion) completion(_zipFileError);
                     });
   }
   else
   {
      [self performZipToolCleanup];
      NSString * message = @"Failed to get a system queue to execute zip file creation";
      [self setErrorCode:2 errorMessage:message andNotify:((completion)? NO : YES)];
      
      if (completion) completion(_zipFileError);
   }
}

#pragma mark helpers

- (NSUInteger) totalSourceFileSize
{
   if (_totalFileSize) return _totalFileSize;
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for ( ; it != _zipFileMapping.end(); ++it)
   {
      if (it->first.length() > 0)
      {
         NSString * sourceFileName = [NSString stringWithUTF8String:it->first.c_str()];
         
         NSError * error = nil;
         NSFileHandle * handle =
            [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:sourceFileName]
                                                error:&error];
         if (handle == nil || error != nil)
         {
            _totalFileSize = 0;
            [self setError:error andNotify:YES];
            return _totalFileSize;
         }
         
         unsigned long long bytesInFile = [handle seekToEndOfFile];
         _totalFileSize += bytesInFile;
      }
   }
   
   return _totalFileSize;
}

- (BOOL) insureNoDuplicates
{
   std::set<std::string> zipFileNames;
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for( ; it != _zipFileMapping.end(); ++it)
   {
      if (it->second.length() <= 0) return NO;
      if (zipFileNames.find(it->second) != zipFileNames.end()) return NO;
      zipFileNames.insert(it->second);
   }
   
   return YES;
}

- (BOOL) insureSourceFilesExist
{
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for( ; it != _zipFileMapping.end(); ++it)
   {
      if (it->first.length() <= 0) return NO;
      
      NSError * error = nil;
      NSString * sourceFileName = [NSString stringWithUTF8String:it->first.c_str()];
      NSFileHandle * handle =
         [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:sourceFileName]
                                             error:&error];
      [handle closeFile];
      
      if (handle == nil || error != nil)
      {
         [self setError:error andNotify:YES];
         return NO;
      }
   }
   
   return YES;
}

- (BOOL) insureCanCreateZipFileAtLocation
{
   if (_zipFileURL == nil) return NO;
   
   NSURL * folder = [_zipFileURL URLByDeletingLastPathComponent];
   
   NSFileManager * manager = [NSFileManager defaultManager];
   BOOL isFolder = NO;
   BOOL success = [manager fileExistsAtPath:[folder path] isDirectory:&isFolder];
   if (success == NO || isFolder == NO)
      return NO;
   
   NSString * tmpString = [folder path];
   if (![tmpString hasSuffix:@"/"])
      tmpString = [tmpString stringByAppendingString:@"/"];
   
   return [manager isWritableFileAtPath:tmpString];
   
   return YES;
}

- (BOOL) insureAdequateDiskSpace
{
   if (_zipFileURL == nil) return NO;
   
   unsigned long long spaceNeeded = [self totalSourceFileSize];
   if (spaceNeeded)
   {
      NSError * error = nil;
      NSDictionary * dict = [[NSFileManager defaultManager]
                             attributesOfFileSystemForPath:[_zipFileURL path] error:&error];
      
      if (dict == nil || error != nil)
      {
         [self setError:error andNotify:YES];
         return NO;
      }
      
      unsigned long long freeSpace = [[dict objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
      if (spaceNeeded >= freeSpace) // TODO:LEA: add a buffer of 10MB or so at least
         return NO;
   }
   
   return YES;
}

- (void) updateProgress:(unsigned long long) bytesReadFromFile
                forFile:(NSURL*) fileToZip
                 ofSize:(unsigned long long) fileSize
         singleFileOnly:(BOOL) singleFileOnly
{
   if (_zipDelegate == nil) return;
   
   double progress = (fileSize)? static_cast<double>(bytesReadFromFile) / fileSize : 0;
   
   // update current file progress
   if ([_zipDelegate respondsToSelector:@selector(updateProgress:forFile:)])
      [_zipDelegate updateProgress:progress forFile:fileToZip];
   
   // update overall progress
   if (singleFileOnly == NO)
   {
      double totalToWrite = self.totalSourceFileSize;
      progress = (totalToWrite)? _totalDestinationBytesWritten / totalToWrite : 0;
   }
   
   [_zipDelegate updateProgress:progress];
}


- (BOOL) writeStream:(ZipWriteStream *) writeStream
             fromURL:(NSURL *) fileToZip
      singleFileOnly:(BOOL) singleFileOnly
{
   BOOL result = NO;
   
   NSError * error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForReadingFromURL:fileToZip  error:&error];
   if (handle == nil || error != nil)
   {
      [self setError:error andNotify:YES];
      return result;
   }
   
   unsigned long long bytesInFile = [handle seekToEndOfFile];
   [handle seekToFileOffset:0];
   
   if (bytesInFile == 0)
   {
      // writing out file with no bytes???
      // should we allow this???
      [self updateProgress:1
                   forFile:fileToZip
                    ofSize:1
            singleFileOnly:singleFileOnly];
      
      return YES;
   }
   
   unsigned long long totalBytesWritten = 0;
   unsigned long  bytesToRead = 1024 * 64; // read/write 64k at a time
   
   [self updateProgress:totalBytesWritten
                forFile:fileToZip
                 ofSize:bytesInFile
         singleFileOnly:singleFileOnly];
   
   @try
   {
      do
      {
         if (self.cancelOperation) break;
         
         if (bytesToRead > (bytesInFile - totalBytesWritten))
            bytesToRead = bytesInFile - totalBytesWritten;
         
         NSData * data = [handle readDataOfLength:bytesToRead];
         if (data && data.length == bytesToRead)
         {
            [writeStream writeData:data];
            totalBytesWritten += bytesToRead;
            _totalDestinationBytesWritten += data.length;
            
            [self updateProgress:totalBytesWritten
                         forFile:fileToZip
                          ofSize:bytesInFile
                  singleFileOnly:singleFileOnly];
         }
         else
         {
            int err = -19;
            NSString * reason = @"Failed to read data to add to zip file";
            @throw [[ZipException alloc] initWithError:err reason:reason];
         }
         
      } while (totalBytesWritten < bytesInFile);
      
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
   
   return result;
}


@end
