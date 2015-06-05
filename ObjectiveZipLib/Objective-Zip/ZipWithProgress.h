//
//  ZipWithProgress.h
//

#import <Foundation/Foundation.h>

#import "ProgressDelegate.h"
#import "ZipProgressBase.h"

#include <map>
#include <string>


//
// ZipWithProgress
//
@interface ZipWithProgress : ZipProgressBase
{
}

// zipFilePath - the path and file name of the zipfile
// filesToZip  - map<fullPathAndFileNameToFilesToAddToArchive nameOfFileInArchive>
// delegate - ProgressDelegate protocol object to call with progress and errors
- (id)   initWithZipFilePath:(NSURL *)zipFileURL
                     fileMap:(std::map<std::string, std::string>)filesToZip
                 andDelegate:(id<ProgressDelegate>)delegate;

- (BOOL) canZipFiles;
- (void) createZipFileWithCompletionBlock:(void(^)(NSError * error))completion;

@end
