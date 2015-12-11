//
//  ZipErrorCodes.m
//

#import "ZipErrorCodes.h"


#ifndef NEVER_TRANSLATE
   #define NEVER_TRANSLATE(x) x
#endif

@implementation ZipErrorCodes

-(id)init
{
   if (self == [super init])
   {
      // common error codes
      
      _OZCEM_ZipErrorDomain = NEVER_TRANSLATE(@"ZipErrorDomain");
      
      _OZCEC_UserCancelledError = -128;
      _OZCEM_UserCancelledError = NSLocalizedString(@"User cancelled",
                                                    @"ZipErrorCode: User cancelled");
      
      _OZCEC_IndeterminateError = 90;
      _OZCEM_IndeterminateError = NSLocalizedString(@"Unknown failure",
                                                    @"ZipErrorCode: Unknown failure");
      
      _OZCEC_NotEnoughDiskSpace = 98;
      _OZCEM_NotEnoughDiskSpace = NSLocalizedString(@"Not enough disk space at requested location",
                                                    @"ZipErrorCode: Not enough disk space at requested location");
      
      _OZCEC_CannotReadSystemFolderAttributes = 99;
      _OZCEM_CannotReadSystemFolderAttributes = NSLocalizedString(@"Cannot read folder attributes to verify disk space",
                                                                  @"ZipErrorCode: Cannot read folder attributes to verify disk space");
      
      // zip error codes
      
      _OZEC_WriteStreamCreationError = 100;
      _OZEM_WriteStreamCreationError = NSLocalizedString(@"Failed to create write stream for zip file",
                                                         @"ZipErrorCode: Failed to create write stream for zip file");

      _OZEC_ZeroLengthFileNames = 101;
      _OZEM_ZeroLengthFileNames = NSLocalizedString(@"Cannot create a zip file with file names of zero length",
                                                    @"ZipErrorCode: Cannot create a zip file with file names of zero length");

      _OZEC_DuplicateFileNames = 102;
      _OZEM_DuplicateFileNames = NSLocalizedString(@"Cannot create a zip file with duplicate file names",
                                                   @"ZipErrorCode: Cannot create a zip file with duplicate file names");

      _OZEC_ZipLocationIsFile = 103;
      _OZEM_ZipLocationIsFile = NSLocalizedString(@"Cannot create a zip file at requested location (is a file, not a folder)",
                                                  @"ZipErrorCode: Cannot create a zip file at requested location (is a file, not a folder)");

      _OZEC_ZipLocationDoesNotExist = 104;
      _OZEM_ZipLocationDoesNotExist = NSLocalizedString(@"Requested location for zip file does not exist",
                                                        @"ZipErrorCode: Requested location for zip file does not exist");

      _OZEC_ZipLocationReadOnly = 105;
      _OZEM_ZipLocationReadOnly = NSLocalizedString(@"Requested location for zip file is read only",
                                                    @"ZipErrorCode: Requested location for zip file is read only");

      _OZEC_ReadDataFailure = 106;
      _OZEM_ReadDataFailure = NSLocalizedString(@"Failed to read data to add to zip file",
                                                @"ZipErrorCode: Failed to read data to add to zip file");

      _OZEC_fileCouldNotBeOpenedForReading = 107;
      _OZEM_fileCouldNotBeOpenedForReading = NSLocalizedString(@"A file to be added to the zip file could not be opened for reading",
                                                               @"ZipErrorCode: A file to be added to the zip file could not be opened for reading");
      
      // unzip error codes
      
      _OUZEC_PathDoesNotExist = 120;
      _OUZEM_PathDoesNotExist = NSLocalizedString(@"Extraction path does not exist",
                                                  @"ZipErrorCode: Extraction path does not exist");
      
      _OUZEC_CannotCreateFolder = 121;
      _OUZEM_CannotCreateFolder = NSLocalizedString(@"Could not create folder to extract files into",
                                                    @"ZipErrorCode: Could not create folder to extract files into");
      
      _OUZEC_CannotCreateExtractionQueue = 122;
      _OUZEM_CannotCreateExtractionQueue = NSLocalizedString(@"Failed to get a system queue to extract data from zip file",
                                                             @"ZipErrorCode: Failed to get a system queue to extract data from zip file");
      
      _OUZEC_CannotFindInfoForFileInArchive = 123;
      _OUZEM_CannotFindInfoForFileInArchive = NSLocalizedString(@"File does not exist in archive",
                                                                @"ZipErrorCode: File does not exist in archive");
      
      _OUZEC_fileAlreadyExists = 124;
      _OUZEM_fileAlreadyExists = NSLocalizedString(@"During file extraction the file to be written already exists",
                                                   @"ZipErrorCode: During file extraction the file to be written already exists");
      
      _OUZEC_fileCouldNotBeOpenedForWriting = 125;
      _OUZEM_fileCouldNotBeOpenedForWriting = NSLocalizedString(@"During file extraction the file to be written could not be opened for writing",
                                                                @"ZipErrorCode: During file extraction the file to be written could not be opened for writing");
   }
   
   return self;
}

@end
