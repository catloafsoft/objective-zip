//
//  ZipWithProgress.h
//

#import <Foundation/Foundation.h>

#include <map>
#include <string>


//
// ProgressDelegate - called with progress of zipfile creation
//    NOTES: progress is an estimate.  this only works well when no compression is being used
//           In this case, we get the total file size of all of the files being added, and
//           then track the size of the zipfile as it is being created.  We update the progress
//           percent based on the ratio of zipfile size / total file size
//
@protocol ProgressDelegate <NSObject>
@required

- (void) updateZipEror:(NSUInteger) errorCode;

- (void) updateZipProgress:(double)percentComplete;

@optional
- (void) updateZipProgress:(double)percentComplete forFile:(NSString *)fileNameInZip;
- (void) updateCurrentFileBeingZipped:(NSString *)fileNameInZip;

@end


//
// ZipWithProgress
//
@interface ZipWithProgress : NSObject
{
}

// zipFilePath - the path and file name of the zipfile
// filesToZip  - map<fullPathAndFileNameToFilesToAddToArchive nameOfFileInArchive>
- (id) initWithZipFilePath:(NSString *)zipFilePath andArray:(std::map<std::string, std::string>)filesToZip;
- (void) setProgressDelegate:(id<ProgressDelegate>)delegate;
- (BOOL) canZipFlatFile;
- (void) createFlatZipFile;

@end
