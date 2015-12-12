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

// domain for all zip error codes
+(NSString*) OZCEM_ZipErrorDomain;

// common error codes
+(NSInteger) OZCEC_UserCancelled;
+(NSString*) OZCEM_UserCancelled;

+(NSInteger) OZCEC_Indeterminate;
+(NSString*) OZCEM_Indeterminate;

+(NSInteger) OZCEC_NotEnoughDiskSpace;
+(NSString*) OZCEM_NotEnoughDiskSpace;

+(NSInteger) OZCEC_CannotReadSystemFolderAttributes;
+(NSString*) OZCEM_CannotReadSystemFolderAttributes;


// zip error codes
+(NSInteger) OZEC_WriteStreamCreation;
+(NSString*) OZEM_WriteStreamCreation;

+(NSInteger) OZEC_ZeroLengthFileName;
+(NSString*) OZEM_ZeroLengthFileName;

+(NSInteger) OZEC_DuplicateFileNames;
+(NSString*) OZEM_DuplicateFileNames;

+(NSInteger) OZEC_ZipLocationIsFile;
+(NSString*) OZEM_ZipLocationIsFile;

+(NSInteger) OZEC_ZipLocationDoesNotExist;
+(NSString*) OZEM_ZipLocationDoesNotExist;

+(NSInteger) OZEC_ZipLocationReadOnly;
+(NSString*) OZEM_ZipLocationReadOnly;

+(NSInteger) OZEC_ReadDataFailure;
+(NSString*) OZEM_ReadDataFailure;

+(NSInteger) OZEC_FileCouldNotBeOpenedForReading;
+(NSString*) OZEM_FileCouldNotBeOpenedForReading;


// unzip error codes
+(NSInteger) OUZEC_PathDoesNotExist;
+(NSString*) OUZEM_PathDoesNotExist;

+(NSInteger) OUZEC_CannotCreateFolder;
+(NSString*) OUZEM_CannotCreateFolder;

+(NSInteger) OUZEC_CannotCreateExtractionQueue;
+(NSString*) OUZEM_CannotCreateExtractionQueue;

+(NSInteger) OUZEC_CannotFindInfoForFileInArchive;
+(NSString*) OUZEM_CannotFindInfoForFileInArchive;

+(NSInteger) OUZEC_FileAlreadyExists;
+(NSString*) OUZEM_FileAlreadyExists;

+(NSInteger) OUZEC_FileCouldNotBeOpenedForWriting;
+(NSString*) OUZEM_FileCouldNotBeOpenedForWriting;

@end
