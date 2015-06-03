//
//  ZipWithProgress.h
//

#import <Foundation/Foundation.h>

#import "ProgressDelegate.h"

#include <map>
#include <string>


//
// ZipWithProgress
//
@interface ZipWithProgress : NSObject
{
}

// zipFilePath - the path and file name of the zipfile
// filesToZip  - map<fullPathAndFileNameToFilesToAddToArchive nameOfFileInArchive>
- (id)   initWithZipFilePath:(NSString *)zipFilePath
                    andArray:(std::map<std::string, std::string>)filesToZip;
- (void) setProgressDelegate:(id<ProgressDelegate>)delegate;
- (BOOL) canZipFlatFile;
- (void) createFlatZipFile;

- (void) createFlatZipFileWithCompletionBlock:(void(^)(NSError * error))completion;

@end
