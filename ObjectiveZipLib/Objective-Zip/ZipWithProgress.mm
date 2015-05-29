//
//  ZipWithProgress.mm
//

#import "ZipWithProgress.h"

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
   if (![self insureAdequateDiskSpace] == 0) return NO;
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
      
      ZipWriteStream * stream = [zipFile writeFileInZipWithName:fileinArchiveName
                                               compressionLevel:ZipCompressionLevelNone];
      
      NSData * data = [NSData dataWithContentsOfFile:sourceFileName];
      [stream writeData:data];
      [stream finishedWriting];
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
         NSData * data = [NSData dataWithContentsOfFile:sourceFileName];
         if (data)
            _totalSourceFileSize += data.length;
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
   return NO;
}

- (BOOL) insureCanCreateZipFileAtLocation
{
   return NO;
}

@end
