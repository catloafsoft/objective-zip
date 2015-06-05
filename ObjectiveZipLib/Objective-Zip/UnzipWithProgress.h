//
//  UnzipWithProgress.h
//

#import <Foundation/Foundation.h>

#import "ProgressDelegate.h"
#import "ZipProgressBase.h"

#include <map>
#include <string>


//
// UnzipWithProgress
//
@interface UnzipWithProgress : ZipProgressBase
{
}

// zipFilePath - the path and file name of the zipfile
// requiredFiles  - an array of strings of filenames required to be in the archive (can be nil)
- (id) initWithZipFilePath:(NSURL *)zipFileURL
             requiredFiles:(NSArray *)requiredFiles
               andDelegate:()delegate;

- (NSArray *) zipFileList;

- (BOOL) unzipOneFile:(NSString *)fileNameInArchive toLocation:(NSURL *)unzipToFolder;

- (BOOL) canUnzipToLocation:(NSURL *)unzipToFolder;
- (void) unzipToLocation:(NSURL *)unzipToFolder
     withCompletionBlock:(void(^)(NSURL * extractionFolder, NSError * error))completion;

@end
