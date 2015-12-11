//
//  ZipErrorCodes.h
//

#import <Foundation/Foundation.h>


// OZCEC_ - Objective-Zip Common Error Code
// OZCEM_ - Objective-Zip Common Error Message

// OZEC_ - Objective-Zip Error Code
// OZEM_ - Objective-Zip Error Message

// OUZEC_ - Objective-(Un)Zip Error Code
// OUZEM_ - Objective-(Un)Zip Error Message


@interface ZipErrorCodes : NSObject
{
}

// common error codes
@property (readonly, copy) NSString * OZCEM_ZipErrorDomain;

@property (readonly, assign) NSInteger OZCEC_UserCancelledError;
@property (readonly, copy) NSString * OZCEM_UserCancelledError;

@property (readonly, assign) NSInteger OZCEC_IndeterminateError;
@property (readonly, copy) NSString * OZCEM_IndeterminateError;

@property (readonly, assign) NSInteger OZCEC_NotEnoughDiskSpace;
@property (readonly, copy) NSString * OZCEM_NotEnoughDiskSpace;

@property (readonly, assign) NSInteger OZCEC_CannotReadSystemFolderAttributes;
@property (readonly, copy) NSString * OZCEM_CannotReadSystemFolderAttributes;

// zip error codes
@property (readonly, assign) NSInteger OZEC_WriteStreamCreationError;
@property (readonly, copy) NSString * OZEM_WriteStreamCreationError;

@property (readonly, assign) NSInteger OZEC_ZeroLengthFileNames;
@property (readonly, copy) NSString * OZEM_ZeroLengthFileNames;

@property (readonly, assign) NSInteger OZEC_DuplicateFileNames;
@property (readonly, copy) NSString * OZEM_DuplicateFileNames;

@property (readonly, assign) NSInteger OZEC_ZipLocationIsFile;
@property (readonly, copy) NSString * OZEM_ZipLocationIsFile;

@property (readonly, assign) NSInteger OZEC_ZipLocationDoesNotExist;
@property (readonly, copy) NSString * OZEM_ZipLocationDoesNotExist;

@property (readonly, assign) NSInteger OZEC_ZipLocationReadOnly;
@property (readonly, copy) NSString * OZEM_ZipLocationReadOnly;

@property (readonly, assign) NSInteger OZEC_ReadDataFailure;
@property (readonly, copy) NSString * OZEM_ReadDataFailure;

@property (readonly, assign) NSInteger OZEC_fileCouldNotBeOpenedForReading;
@property (readonly, copy) NSString * OZEM_fileCouldNotBeOpenedForReading;


// unzip error codes
@property (readonly, assign) NSInteger OUZEC_PathDoesNotExist;
@property (readonly, copy) NSString * OUZEM_PathDoesNotExist;

@property (readonly, assign) NSInteger OUZEC_CannotCreateFolder;
@property (readonly, copy) NSString * OUZEM_CannotCreateFolder;

@property (readonly, assign) NSInteger OUZEC_CannotCreateExtractionQueue;
@property (readonly, copy) NSString * OUZEM_CannotCreateExtractionQueue;

@property (readonly, assign) NSInteger OUZEC_CannotFindInfoForFileInArchive;
@property (readonly, copy) NSString * OUZEM_CannotFindInfoForFileInArchive;

@property (readonly, assign) NSInteger OUZEC_fileAlreadyExists;
@property (readonly, copy) NSString * OUZEM_fileAlreadyExists;

@property (readonly, assign) NSInteger OUZEC_fileCouldNotBeOpenedForWriting;
@property (readonly, copy) NSString * OUZEM_fileCouldNotBeOpenedForWriting;

@end
