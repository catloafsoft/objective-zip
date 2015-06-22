//
//  ZipErrorCodes.h
//

#import <Foundation/Foundation.h>


// kOZCEC_ - konstant Objective-Zip Common Error Code
// kOZCEM_ - konstant Objective-Zip Common Error Message

// kOZEC_ - konstant Objective-Zip Error Code
// kOZEM_ - konstant Objective-Zip Error Message

// kOUZEC_ - konstant Objective-(Un)Zip Error Code
// kOUZEM_ - konstant Objective-(Un)Zip Error Message


// common error codes
static NSString * kOZCEM_ZipErrorDomain = @"ZipErrorDomain";

static NSInteger  kOZCEC_UserCancelledError = -128;
static NSString * kOZCEM_UserCancelledError = @"User cancelled error";

static NSInteger  kOZCEC_IndeterminateError = 90;
static NSString * kOZCEM_IndeterminateError = @"Unknown failure";

static NSInteger  kOZCEC_NotEnoughDiskSpace = 98;
static NSString * kOZCEM_NotEnoughDiskSpace = @"Not enough disk space at requested location";

static NSInteger  kOZCEC_CannotReadSystemFolderAttributes = 99;
static NSString * kOZCEM_CannotReadSystemFolderAttributes = @"Cannot read folder attributes to verify disk space";



// zip error codes

static NSInteger  kOZEC_WriteStreamCreationError = 100;
static NSString * kOZEM_WriteStreamCreationError = @"Failed to create write stream for zip file";

static NSInteger  kOZEC_ZeroLengthFileNames = 101;
static NSString * kOZEM_ZeroLengthFileNames = @"Cannot create a zip file with file names of zero length";

static NSInteger  kOZEC_DuplicateFileNames = 102;
static NSString * kOZEM_DuplicateFileNames = @"Cannot create a zip file with duplicate file names";

static NSInteger  kOZEC_ZipLocationIsFile = 103;
static NSString * kOZEM_ZipLocationIsFile = @"Cannot create a zip file at requested location (is a file, not a folder)";

static NSInteger  kOZEC_ZipLocationDoesNotExist = 104;
static NSString * kOZEM_ZipLocationDoesNotExist = @"Requested location for zip file does not exist";

static NSInteger  kOZEC_ZipLocationReadOnly = 105;
static NSString * kOZEM_ZipLocationReadOnly = @"Requested location for zip file is read only";

static NSInteger  kOZEC_ReadDataFailure = 106;
static NSString * kOZEM_ReadDataFailure = @"Failed to read data to add to zip file";



// unzip error codes

static NSInteger  kOUZEC_PathDoesNotExist = 120;
static NSString * kOUZEM_PathDoesNotExist = @"Extraction path does not exist";

static NSInteger  kOUZEC_CannotCreateFolder = 121;
static NSString * kOUZEM_CannotCreateFolder = @"Could not create folder to extract files into";

static NSInteger  kOUZEC_CannotCreateExtractionQueue = 122;
static NSString * kOUZEM_CannotCreateExtractionQueue = @"Failed to get a system queue to extract data from zip file";

static NSInteger  kOUZEC_CannotFindInfoForFileInArchive = 123;
static NSString * kOUZEM_CannotFindInfoForFileInArchive = @"File does not exist in archive";


