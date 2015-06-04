//
//  ProgressDelegate.h
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

- (void) updateError:(NSError *) theError;
- (void) updateProgress:(double)percentComplete;

@optional
- (void) updateProgress:(double)percentComplete forFile:(NSURL *)fileNameInZip;
- (void) updateCurrentFile:(NSURL *)fileNameInZip;

@end
