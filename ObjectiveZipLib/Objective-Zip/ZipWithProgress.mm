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
   
   NSString *           _zipFilePath;
   NSError *            _zipFileError;
   id<ProgressDelegate> _zipDelegate;
   ZipFile *            _zipFile;
   
   unsigned long long   _totalSourceFileSize;
   unsigned long long   _totalDestinationBytesWritten;
   std::map<std::string, std::string> _zipFileMapping;
}

@end


//
// ZipWithProgress
//
@implementation ZipWithProgress

- (id) initWithZipFilePath:(NSString *)zipFilePath
                  andArray:(std::map<std::string, std::string>)filesToZip
{
   if (self = [self init])
   {
      _zipFilePath = zipFilePath;
      _zipFileMapping = filesToZip;
      _zipFile = [[ZipFile alloc] initWithFileName:_zipFilePath mode:ZipFileModeCreate];
      if (_zipFile == nil) return nil;
   }
   
   return self;
}

- (void) dealloc
{
   if (_zipFile) [_zipFile close];
}

- (void) setProgressDelegate:(id<ProgressDelegate>)delegate
{
   _zipDelegate = delegate;
}

- (BOOL) canZipFlatFile
{
   if (![self insureNoDuplicates]) return NO;
   if (![self insureSourceFilesExist]) return NO;
   if ([self totalSourceFileSize] == 0) return NO;
   if (![self insureAdequateDiskSpace]) return NO;
   if (![self insureCanCreateZipFileAtLocation]) return NO;
   return YES;
}

- (void) createFlatZipFile
{
   _totalDestinationBytesWritten = 0;
   
   if (![self canZipFlatFile]) return;
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for (; it != _zipFileMapping.end(); ++it)
   {
      NSString * sourceFileName = [NSString stringWithUTF8String:it->first.c_str()];
      NSString * fileinArchiveName = [NSString stringWithUTF8String:it->second.c_str()];
      
      if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
         [_zipDelegate  updateCurrentFile:sourceFileName];
         
      ZipWriteStream * writeStream = [_zipFile writeFileInZipWithName:fileinArchiveName
                                                     compressionLevel:ZipCompressionLevelNone];
      if (writeStream)
      {
         [self writeStream:writeStream
                  fromFile:[NSURL fileURLWithPath:sourceFileName]
            singleFileOnly:NO];
         
         [writeStream finishedWriting];
         
         if (_zipFileError != nil)
            break;
      }
      else
      {
         NSString * message = @"Failed to create write stream for zip file";
         _zipFileError = [NSError errorWithDomain:@"ZipException"
                                             code:1
                                         userInfo:[NSDictionary
                                                   dictionaryWithObject:message
                                                                 forKey:NSLocalizedDescriptionKey]];
         [_zipDelegate updateError:_zipFileError];
         break;
      }
   }
}

- (void) createFlatZipFileWithCompletionBlock:(void(^)(NSError * error))completion
{
   if (_zipFile == nil)
      _zipFile = [[ZipFile alloc] initWithFileName:_zipFilePath mode:ZipFileModeUnzip];
   
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   if (queue)
   {
      dispatch_async(queue,
                     ^{
                        [self createFlatZipFile];
                        [_zipFile close];
                        _zipFile = nil;
                        
                        if (completion) completion(_zipFileError);
                     });
      
   }
   else
   {
      NSString * message = @"Failed to get a system queue to execute zip file creation";
      _zipFileError = [NSError errorWithDomain:@"ZipException"
                                          code:2
                                      userInfo:[NSDictionary
                                                dictionaryWithObject:message
                                                forKey:NSLocalizedDescriptionKey]];
      [_zipFile close];
      _zipFile = nil;
      
      if (completion)
         completion(_zipFileError);
      else
         [_zipDelegate updateError:_zipFileError];
   }
   

}

#pragma mark helpers
- (NSUInteger) totalSourceFileSize
{
   if (_totalSourceFileSize) return _totalSourceFileSize;
   
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
            _totalSourceFileSize = 0;
            _zipFileError = error;
            [_zipDelegate updateError:_zipFileError];
            return _totalSourceFileSize;
         }
         
         unsigned long long bytesInFile = [handle seekToEndOfFile];
         _totalSourceFileSize += bytesInFile;
      }
   }
   
   return _totalSourceFileSize;
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
         _zipFileError = error;
         [_zipDelegate updateError:_zipFileError];
         return NO;
      }
   }
   
   return YES;
}

- (BOOL) insureAdequateDiskSpace
{
   if (_zipFilePath == nil) return NO;
   
   unsigned long long totalSize = [self totalSourceFileSize];
   if (totalSize)
   {
      
   }
   
   return YES;
}

- (BOOL) insureCanCreateZipFileAtLocation
{
   if (_zipFilePath == nil) return NO;
   
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
      [_zipDelegate updateProgress:progress forFile:[fileToZip path]];
   
   // update overall progress
   if (singleFileOnly == NO)
   {
      double totalToWrite = self.totalSourceFileSize;
      progress = (totalToWrite)? bytesReadFromFile / totalToWrite : 0;
   }
   
   [_zipDelegate updateProgress:progress];
}


- (BOOL) writeStream:(ZipWriteStream *) writeStream
            fromFile:(NSURL *) fileToZip
      singleFileOnly:(BOOL) singleFileOnly
{
   BOOL result = NO;
   
   NSError * error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForReadingFromURL:fileToZip  error:&error];
   if (handle == nil || error != nil)
   {
      _zipFileError = error;
      [_zipDelegate updateError:_zipFileError];
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
      if (reason == nil)
         reason = @"Unknown failure";
      
      _zipFileError = [NSError errorWithDomain:@"ZipException"
                                          code:ze.error
                                      userInfo:[NSDictionary
                                                dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
      [_zipDelegate updateError:_zipFileError];
   }
   @catch (id e)
   {
      NSString * reason = [e description];
      if (reason == nil)
         reason = @"Unknown failure";
            
      _zipFileError = [NSError errorWithDomain:@"ZipException"
                                          code:1
                                      userInfo:[NSDictionary
                                                dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
      [_zipDelegate updateError:_zipFileError];
   }
   
   return result;
}


@end
