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
   NSString *                         _zipFilePath;
   id<ProgressDelegate>               _zipDelegate;
   unsigned long long                 _totalSourceFileSize;
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
   }
   
   return self;
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
   if (![self canZipFlatFile]) return;
   
   ZipFile * zipFile = [[ZipFile alloc] initWithFileName:_zipFilePath mode:ZipFileModeCreate];
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for (; it != _zipFileMapping.end(); ++it)
   {
      NSString * sourceFileName = [NSString stringWithUTF8String:it->first.c_str()];
      NSString * fileinArchiveName = [NSString stringWithUTF8String:it->second.c_str()];
      
      if ([_zipDelegate respondsToSelector:@selector(updateCurrentFile:)])
         [_zipDelegate  updateCurrentFile:sourceFileName];
         
      ZipWriteStream * writeStream = [zipFile writeFileInZipWithName:fileinArchiveName
                                                    compressionLevel:ZipCompressionLevelNone];
      if (writeStream)
      {
         [self writeStream:writeStream
                  fromFile:[NSURL fileURLWithPath:sourceFileName]
            singleFileOnly:NO];
      }
      else
      {
         // TODO:LEA: close andclean up the zipfile??
         if (_zipDelegate)
         {
            NSString * message = @"Failed to create write stream for zip file";
            NSError * error =
               [NSError errorWithDomain:@"ZipException"
                                   code:0
                               userInfo:[NSDictionary dictionaryWithObject:message
                                                                    forKey:NSLocalizedDescriptionKey]];
            [_zipDelegate updateEror:error];
         }
         break;
      }
   }
   
   [zipFile close];
}

#pragma mark helpers
- (NSUInteger) totalSourceFileSize
{
   if (_totalSourceFileSize) return _totalSourceFileSize;
   
   std::map<std::string, std::string>::iterator it = _zipFileMapping.begin();
   for( ; it != _zipFileMapping.end(); ++it)
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
            [_zipDelegate updateEror:error];
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
      NSString * sourceFileName = [NSString stringWithUTF8String:it->first.c_str()];
      NSData * data = [NSData dataWithContentsOfFile:sourceFileName];
      if (data == nil) return NO;
   }
   
   return YES;
}

- (BOOL) insureAdequateDiskSpace
{
   return YES;
}

- (BOOL) insureCanCreateZipFileAtLocation
{
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
   // TODO:LEA:track if there is an exception or error and clean up after it
   BOOL result = NO;
   
   NSError * error = nil;
   NSFileHandle * handle = [NSFileHandle fileHandleForReadingFromURL:fileToZip  error:&error];
   if (handle == nil || error != nil)
   {
      [_zipDelegate updateEror:error];
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
      
      [writeStream finishedWriting];
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
      result = YES;
      do
      {
         if (bytesToRead > (bytesInFile - totalBytesWritten))
            bytesToRead = bytesInFile - totalBytesWritten;
         
         NSData * data = [handle readDataOfLength:bytesToRead];
         if (data && data.length == bytesToRead)
         {
            [writeStream writeData:data];
            totalBytesWritten += bytesToRead;

            [self updateProgress:totalBytesWritten
                         forFile:fileToZip
                          ofSize:bytesInFile
                  singleFileOnly:singleFileOnly];
         }
         else
         {
            // TODO:LEA: report error and delete the archive
            NSLog(@"Failed to write entire file bytesToRead = %lu, data.length = %lu",
                  bytesToRead, data.length);
            result = NO;
            break;
         }
         
      } while (totalBytesWritten < bytesInFile);
   }
   @catch (ZipException *ze)
   {
      if (_zipDelegate)
      {
         NSString * reason = [ze reason];
         if (reason == nil)
            reason = @"Unknown failure";
         
         NSError * error =
         [NSError errorWithDomain:@"ZipException"
                             code:ze.error
                         userInfo:[NSDictionary dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
         [_zipDelegate updateEror:error];
      }
      
      NSLog(@"ZipException caught: %ld - %@", (long)ze.error, [ze reason]);
   }
   @catch (id e)
   {
      if (_zipDelegate)
      {
         NSString * reason = [e description];
         if (reason == nil)
            reason = @"Unknown failure";
         
         NSError * error =
         [NSError errorWithDomain:@"ZipException"
                             code:1
                         userInfo:[NSDictionary dictionaryWithObject:reason
                                                              forKey:NSLocalizedDescriptionKey]];
         [_zipDelegate updateEror:error];
      }
      
      NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
   }
   
   [writeStream finishedWriting];
   return result;
}


@end
