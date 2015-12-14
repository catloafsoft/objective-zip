//
//  ZipErrorCodes.m
//

#import "ZipErrorCodes.h"


#ifndef NEVER_TRANSLATE
   #define NEVER_TRANSLATE(x) x
#endif

@implementation ZipErrorCodes

// domain for all zip error codes
+(NSString*) OZCEM_ZipErrorDomain
{  return NEVER_TRANSLATE(@"ZipErrorDomain");
}

// common error codes
+(NSInteger) OZCEC_UserCancelled
{  return -128;
}

+(NSString*) OZCEM_UserCancelled
{  return NSLocalizedString(@"User cancelled", @"ZipErrorCode: User cancelled");
}

+(NSInteger) OZCEC_Indeterminate
{  return 90;
}

+(NSString*) OZCEM_Indeterminate
{  return NSLocalizedString(@"Unknown failure", @"ZipErrorCode: Unknown failure");
}

+(NSInteger) OZCEC_NotEnoughDiskSpace
{  return 91;
}

+(NSString*) OZCEM_NotEnoughDiskSpace
{  return NSLocalizedString(@"Not enough disk space at requested location",
                            @"ZipErrorCode: Not enough disk space at requested location");
}

+(NSInteger) OZCEC_CannotReadSystemFolderAttributes
{  return 92;
}

+(NSString*) OZCEM_CannotReadSystemFolderAttributes
{  return  NSLocalizedString(@"Cannot read folder attributes to verify disk space",
                             @"ZipErrorCode: Cannot read folder attributes to verify disk space");
}

+(NSInteger) OZCEC_CannotOpenFileInArchive
{  return 93;
}

+(NSString*) OZCEM_CannotOpenFileInArchive
{  return NSLocalizedString(@"Error in opening '%@' in the zipfile",
                            @"ZipErrorCode: Error in opening '[filename]' in the zipfile");
}

+(NSInteger) OZCEC_CannotCloseFileInArchive
{  return 94;
}

+(NSString*) OZCEM_CannotCloseFileInArchive
{  return NSLocalizedString(@"Error in closing '%@' in the zipfile",
                            @"ZipErrorCode: Error in closing '[filename]' in the zipfile");
}

+(NSInteger) OZCEC_CannotCreateZipFile
{  return 95;
}

+(NSString*) OZCEM_CannotCreateZipFile
{  return NSLocalizedString(@"Can't create '%@'",
                            @"ZipErrorCode: Error in closing '[filename]' in the zipfile");
}

+(NSInteger) OZCEC_CannotOpenZipFile
{  return 96;
}

+(NSString*) OZCEM_CannotOpenZipFile
{  return NSLocalizedString(@"Failed to open zipfile with name: %@",
                            @"ZipErrorCode: Failed to open zipfile with name: [filename]");
}

+(NSInteger) OZCEC_CannotCloseZipFile
{  return 97;
}

+(NSString*) OZCEM_CannotCloseZipFile
{  return NSLocalizedString(@"Failed to close zipfile: %@",
                            @"ZipErrorCode: Failed to close zipfile: [filename]");
}
+(NSInteger) OZCEC_UnknownZipFileMode
{  return 98;
}

+(NSString*) OZCEM_UnknownZipFileMode
{  return NSLocalizedString(@"Requested unknown zipfile mode: %d",
                            @"ZipErrorCode: Requested unknown zipfile mode: [mode]");
}


// zip error codes
+(NSInteger) OZEC_WriteStreamCreation
{  return 100;
}

+(NSString*) OZEM_WriteStreamCreation
{  return NSLocalizedString(@"Failed to create write stream for zip file",
                            @"ZipErrorCode: Failed to create write stream for zip file");
}

+(NSInteger) OZEC_ZeroLengthFileName
{  return 101;
}

+(NSString*) OZEM_ZeroLengthFileName
{  return NSLocalizedString(@"Cannot create a zip file with file names of zero length",
                            @"ZipErrorCode: Cannot create a zip file with file names of zero length");
}

+(NSInteger) OZEC_DuplicateFileNames
{  return 102;
}

+(NSString*) OZEM_DuplicateFileNames
{  return NSLocalizedString(@"Cannot create a zip file with duplicate file names",
                            @"ZipErrorCode: Cannot create a zip file with duplicate file names");
}

+(NSInteger) OZEC_ZipLocationIsFile
{  return 103;
}

+(NSString*) OZEM_ZipLocationIsFile
{  return NSLocalizedString(@"Cannot create a zip file at requested location (is a file, not a folder)",
                            @"ZipErrorCode: Cannot create a zip file at requested location (is a file, not a folder)");
}

+(NSInteger) OZEC_ZipLocationDoesNotExist
{  return 104;
}

+(NSString*) OZEM_ZipLocationDoesNotExist
{  return NSLocalizedString(@"Requested location for zip file does not exist",
                            @"ZipErrorCode: Requested location for zip file does not exist");
}

+(NSInteger) OZEC_ZipLocationReadOnly
{  return 105;
}

+(NSString*) OZEM_ZipLocationReadOnly
{  return NSLocalizedString(@"Requested location for zip file is read only",
                            @"ZipErrorCode: Requested location for zip file is read only");
}

+(NSInteger) OZEC_ReadDataFailure
{  return 106;
}

+(NSString*) OZEM_ReadDataFailure
{  return NSLocalizedString(@"Failed to read data to add to zip file",
                            @"ZipErrorCode: Failed to read data to add to zip file");
}

+(NSInteger) OZEC_FileCouldNotBeOpenedForReading
{  return 107;
}

+(NSString*) OZEM_FileCouldNotBeOpenedForReading
{  return NSLocalizedString(@"A file to be added to the zip file could not be opened for reading",
                            @"ZipErrorCode: A file to be added to the zip file could not be opened for reading");
}

+(NSInteger) OZEC_CannotWriteFileInArchive
{  return 108;
}

+(NSString*) OZEM_CannotWriteFileInArchive
{  return NSLocalizedString(@"Error in writing '%@' in the zipfile",
                            @"ZipErrorCode: Error in writing '[filename]' in the zipfile");
}

+(NSInteger) OZEC_OperationNotPermitted
{  return 109;
}

+(NSString*) OZEM_OperationNotPermitted
{  return NSLocalizedString(@"Operation not permitted without Unzip mode",
                            @"ZipErrorCode: Operation not permitted without Unzip mode");
}



// unzip error codes
+(NSInteger) OUZEC_PathDoesNotExist
{  return 120;
}

+(NSString*) OUZEM_PathDoesNotExist
{  return NSLocalizedString(@"Extraction path does not exist",
                            @"ZipErrorCode: Extraction path does not exist");
}

+(NSInteger) OUZEC_CannotCreateFolder
{  return 121;
}

+(NSString*) OUZEM_CannotCreateFolder
{  return NSLocalizedString(@"Could not create folder to extract files into",
                            @"ZipErrorCode: Could not create folder to extract files into");
}

+(NSInteger) OUZEC_CannotCreateExtractionQueue
{  return 122;
}

+(NSString*) OUZEM_CannotCreateExtractionQueue
{  return NSLocalizedString(@"Failed to get a system queue to extract data from zip file",
                            @"ZipErrorCode: Failed to get a system queue to extract data from zip file");
}

+(NSInteger) OUZEC_CannotFindInfoForFileInArchive
{  return 123;
}

+(NSString*) OUZEM_CannotFindInfoForFileInArchive
{  return NSLocalizedString(@"File does not exist in archive",
                            @"ZipErrorCode: File does not exist in archive");
}

+(NSInteger) OUZEC_FileAlreadyExists
{  return 124;
}

+(NSString*) OUZEM_FileAlreadyExists
{  return NSLocalizedString(@"During file extraction the file to be written already exists",
                            @"ZipErrorCode: During file extraction the file to be written already exists");
}

+(NSInteger) OUZEC_FileCouldNotBeOpenedForWriting
{  return 125;
}

+(NSString*) OUZEM_FileCouldNotBeOpenedForWriting
{  return NSLocalizedString(@"During file extraction the file to be written could not be opened for writing",
                            @"ZipErrorCode: During file extraction the file to be written could not be opened for writing");
}

+(NSInteger) OUZEC_CannotReadFileInArchive
{  return 126;
}

+(NSString*) OUZEM_CannotReadFileInArchive
{  return NSLocalizedString(@"Error in reading '%@' in the zipfile",
                            @"ZipErrorCode: Error in reading '[filename]' in the zipfile");
}

+(NSInteger) OUZEC_OperationNotPermitted
{  return 127;
}

+(NSString*) OUZEM_OperationNotPermitted
{  return NSLocalizedString(@"Operation not permitted with Unzip mode",
                            @"ZipErrorCode: Operation not permitted with Unzip mode");
}

+(NSInteger) OUZEC_CannotGetGlobalInfo
{  return 128;
}

+(NSString*) OUZEM_CannotGetGlobalInfo
{  return NSLocalizedString(@"Error in getting global info in '%@'",
                            @"ZipErrorCode: Error in getting global info in '[filename]'");
}

+(NSInteger) OUZEC_CannotGoToFirstFileInArchive
{  return 129;
}

+(NSString*) OUZEM_CannotGoToFirstFileInArchive
{  return NSLocalizedString(@"Error in going to first file in zip in '%@'",
                            @"ZipErrorCode: Error in going to first file in zip in '[filename]'");
}

+(NSInteger) OUZEC_CannotGoToNextFileInArchive
{  return 130;
}

+(NSString*) OUZEM_CannotGoToNextFileInArchive
{  return NSLocalizedString(@"Error in going to next file in zip in '%@'",
                            @"ZipErrorCode: Error in going to first file in zip in '[filename]'");
}

+(NSInteger) OUZEC_CannotGetCurrentFileInfoInArchive
{  return 131;
}

+(NSString*) OUZEM_CannotGetCurrentFileInfoInArchive
{  return NSLocalizedString(@"Error in getting current file info in '%@'",
                            @"ZipErrorCode: Error in getting current file info in '[filename]'");
}

+(NSInteger) OUZEC_CannotOpenCurrentFileInArchive
{  return 132;
}

+(NSString*) OUZEM_CannotOpenCurrentFileInArchive
{  return NSLocalizedString(@"Error in opening current file in '%@'",
                            @"ZipErrorCode: Error in opening current file in '[filename]'");
}

@end
