//
//  UnzipWithProgress.h
//

#import <Foundation/Foundation.h>
#import "ProgressDelegate.h"

#include <map>
#include <string>


//
// UnzipWithProgress
//
@interface UnzipWithProgress : NSObject
{
}

// zipFilePath - the path and file name of the zipfile
// requiredFiles  - an array of strings of filenames required to be in the archive (can be nil)
- (id) initWithZipFilePath:(NSString *)zipFilePath andArray:(NSArray *)requiredFiles;
- (void) setProgressDelegate:(id<ProgressDelegate>)delegate;
- (NSArray *) zipFileList;
- (BOOL) canUnzipToLocation:(NSURL *)unzipToFolder;
- (void) unzipOneFile:(NSString *)fileName toLocation:(NSURL *)unzipToFolder;
- (void) unzipToLocation:(NSURL *)unzipToFolder;

- (void) unzipToLocation:(NSURL *)unzipToFolder
     withCompletionBlock:(void(^)(NSError * error))completion;

@end
