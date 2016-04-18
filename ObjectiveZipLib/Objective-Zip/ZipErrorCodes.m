//
//  ZipErrorCodes.m
//

#import "ZipErrorCodes.h"


#ifndef NEVER_TRANSLATE
   #define NEVER_TRANSLATE(x) x
#endif

// common error codes
static NSString* s_OZCEM_UserCancelled = nil;
static NSString* s_OZCEM_Indeterminate = nil;
static NSString* s_OZCEM_NotEnoughDiskSpace = nil;
static NSString* s_OZCEM_CannotReadSystemFolderAttributes = nil;
static NSString* s_OZCEM_CannotOpenFileInArchive = nil;
static NSString* s_OZCEM_CannotCloseFileInArchive = nil;
static NSString* s_OZCEM_CannotCreateZipFile = nil;
static NSString* s_OZCEM_CannotOpenZipFile = nil;
static NSString* s_OZCEM_CannotCloseZipFile = nil;
static NSString* s_OZCEM_UnknownZipFileMode = nil;

// zip error codes
static NSString* s_OZEM_WriteStreamCreation = nil;
static NSString* s_OZEM_ZeroLengthFileName = nil;
static NSString* s_OZEM_DuplicateFileNames = nil;
static NSString* s_OZEM_ZipLocationIsFile = nil;
static NSString* s_OZEM_ZipLocationDoesNotExist = nil;
static NSString* s_OZEM_ZipLocationReadOnly = nil;
static NSString* s_OZEM_ReadDataFailure = nil;
static NSString* s_OZEM_FileCouldNotBeOpenedForReading = nil;
static NSString* s_OZEM_CannotWriteFileInArchive = nil;
static NSString* s_OZEM_OperationNotPermitted = nil;

// unzip error codes
static NSString* s_OUZEM_PathDoesNotExist = nil;
static NSString* s_OUZEM_CannotCreateFolder = nil;
static NSString* s_OUZEM_CannotCreateExtractionQueue = nil;
static NSString* s_OUZEM_CannotFindInfoForFileInArchive = nil;
static NSString* s_OUZEM_FileAlreadyExists = nil;
static NSString* s_OUZEM_FileCouldNotBeOpenedForWriting = nil;
static NSString* s_OUZEM_CannotReadFileInArchive = nil;
static NSString* s_OUZEM_OperationNotPermitted = nil;
static NSString* s_OUZEM_CannotGetGlobalInfo = nil;
static NSString* s_OUZEM_CannotGoToFirstFileInArchive = nil;
static NSString* s_OUZEM_CannotGoToNextFileInArchive = nil;
static NSString* s_OUZEM_CannotGetCurrentFileInfoInArchive = nil;
static NSString* s_OUZEM_CannotOpenCurrentFileInArchive = nil;


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
{  if (s_OZCEM_UserCancelled) return s_OZCEM_UserCancelled;
   return NSLocalizedString(@"User cancelled", @"ZipErrorCode: User cancelled");
}

+(BOOL)setOZCEM_UserCancelled:(NSString*)errorString
{
   s_OZCEM_UserCancelled = errorString;
   return YES;
}

+(NSInteger) OZCEC_Indeterminate
{  return 90;
}

+(NSString*) OZCEM_Indeterminate
{
   if (s_OZCEM_Indeterminate) return s_OZCEM_Indeterminate;
   return NSLocalizedString(@"Unknown failure", @"ZipErrorCode: Unknown failure");
}

+(BOOL)setOZCEM_Indeterminate:(NSString*)errorString
{
   s_OZCEM_Indeterminate = errorString;
   return YES;
}

+(NSInteger) OZCEC_NotEnoughDiskSpace
{  return 91;
}

+(NSString*) OZCEM_NotEnoughDiskSpace
{  if (s_OZCEM_NotEnoughDiskSpace) return s_OZCEM_NotEnoughDiskSpace;
  return NSLocalizedString(@"Not enough disk space at requested location",
                            @"ZipErrorCode: Not enough disk space at requested location");
}

+(BOOL)setOZCEM_NotEnoughDiskSpace:(NSString*)errorString
{
   s_OZCEM_NotEnoughDiskSpace = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotReadSystemFolderAttributes
{  return 92;
}

+(NSString*) OZCEM_CannotReadSystemFolderAttributes
{  if (s_OZCEM_CannotReadSystemFolderAttributes) return s_OZCEM_CannotReadSystemFolderAttributes;
   return  NSLocalizedString(@"Cannot read folder attributes to verify disk space",
                             @"ZipErrorCode: Cannot read folder attributes to verify disk space");
}

+(BOOL)setOZCEM_CannotReadSystemFolderAttributes:(NSString*)errorString
{
   s_OZCEM_CannotReadSystemFolderAttributes = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotOpenFileInArchive
{  return 93;
}

+(NSString*) OZCEM_CannotOpenFileInArchive
{  if (s_OZCEM_CannotOpenFileInArchive) return s_OZCEM_CannotOpenFileInArchive;
   return NSLocalizedString(@"Error in opening '%@' in the zipfile",
                            @"ZipErrorCode: Error in opening '[filename]' in the zipfile");
}

+(BOOL)setOZCEM_CannotOpenFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZCEM_CannotOpenFileInArchive = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotCloseFileInArchive
{  return 94;
}

+(NSString*) OZCEM_CannotCloseFileInArchive
{  if (s_OZCEM_CannotCloseFileInArchive) return s_OZCEM_CannotCloseFileInArchive;
   return NSLocalizedString(@"Error in closing '%@' in the zipfile",
                            @"ZipErrorCode: Error in closing '[filename]' in the zipfile");
}

+(BOOL)setOZCEM_CannotCloseFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZCEM_CannotCloseFileInArchive = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotCreateZipFile
{  return 95;
}

+(NSString*) OZCEM_CannotCreateZipFile
{  if (s_OZCEM_CannotCreateZipFile) return s_OZCEM_CannotCreateZipFile;
   return NSLocalizedString(@"Can't create '%@'",
                            @"ZipErrorCode: Error in closing '[filename]' in the zipfile");
}

+(BOOL)setOZCEM_CannotCreateZipFile:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZCEM_CannotCreateZipFile = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotOpenZipFile
{
   return 96;
}

+(NSString*) OZCEM_CannotOpenZipFile
{  if (s_OZCEM_CannotOpenZipFile) return s_OZCEM_CannotOpenZipFile;
   return NSLocalizedString(@"Failed to open zipfile with name: %@",
                            @"ZipErrorCode: Failed to open zipfile with name: [filename]");
}

+(BOOL)setOZCEM_CannotOpenZipFile:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZCEM_CannotOpenZipFile = errorString;
   return YES;
}

+(NSInteger) OZCEC_CannotCloseZipFile
{  return 97;
}

+(NSString*) OZCEM_CannotCloseZipFile
{  if (s_OZCEM_CannotCloseZipFile) return s_OZCEM_CannotCloseZipFile;
   return NSLocalizedString(@"Failed to close zipfile: %@",
                            @"ZipErrorCode: Failed to close zipfile: [filename]");
}

+(BOOL)setOZCEM_CannotCloseZipFile:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZCEM_CannotCloseZipFile = errorString;
   return YES;
}

+(NSInteger) OZCEC_UnknownZipFileMode
{  return 98;
}

+(NSString*) OZCEM_UnknownZipFileMode
{  if (s_OZCEM_UnknownZipFileMode) return s_OZCEM_UnknownZipFileMode;
   return NSLocalizedString(@"Requested unknown zipfile mode: %d",
                            @"ZipErrorCode: Requested unknown zipfile mode: [mode]");
}

+(BOOL)setOZCEM_UnknownZipFileMode:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %d in string
   s_OZCEM_UnknownZipFileMode = errorString;
   return YES;
}


// zip error codes
+(NSInteger) OZEC_WriteStreamCreation
{  return 100;
}

+(NSString*) OZEM_WriteStreamCreation
{  if (s_OZEM_WriteStreamCreation) return s_OZEM_WriteStreamCreation;
   return NSLocalizedString(@"Failed to create write stream for zip file",
                            @"ZipErrorCode: Failed to create write stream for zip file");
}

+(BOOL)setOZEM_WriteStreamCreation:(NSString*)errorString
{
   s_OZEM_WriteStreamCreation = errorString;
   return YES;
}

+(NSInteger) OZEC_ZeroLengthFileName
{  return 101;
}

+(NSString*) OZEM_ZeroLengthFileName
{  if (s_OZEM_ZeroLengthFileName) return s_OZEM_ZeroLengthFileName;
   return NSLocalizedString(@"Cannot create a zip file with file names of zero length",
                            @"ZipErrorCode: Cannot create a zip file with file names of zero length");
}

+(BOOL)setOZEM_ZeroLengthFileName:(NSString*)errorString
{
   s_OZEM_ZeroLengthFileName = errorString;
   return YES;
}

+(NSInteger) OZEC_DuplicateFileNames
{  return 102;
}

+(NSString*) OZEM_DuplicateFileNames
{  if (s_OZEM_DuplicateFileNames) return s_OZEM_DuplicateFileNames;
   return NSLocalizedString(@"Cannot create a zip file with duplicate file names",
                            @"ZipErrorCode: Cannot create a zip file with duplicate file names");
}

+(BOOL)setOZEM_DuplicateFileNames:(NSString*)errorString
{
   s_OZEM_DuplicateFileNames = errorString;
   return YES;
}

+(NSInteger) OZEC_ZipLocationIsFile
{  return 103;
}

+(NSString*) OZEM_ZipLocationIsFile
{  if (s_OZEM_ZipLocationIsFile) return s_OZEM_ZipLocationIsFile;
   return NSLocalizedString(@"Cannot create a zip file at requested location (is a file, not a folder)",
                            @"ZipErrorCode: Cannot create a zip file at requested location (is a file, not a folder)");
}

+(BOOL)setOZEM_ZipLocationIsFile:(NSString*)errorString
{
   s_OZEM_ZipLocationIsFile = errorString;
   return YES;
}

+(NSInteger) OZEC_ZipLocationDoesNotExist
{  return 104;
}

+(NSString*) OZEM_ZipLocationDoesNotExist
{  if (s_OZEM_ZipLocationDoesNotExist) return s_OZEM_ZipLocationDoesNotExist;
   return NSLocalizedString(@"Requested location for zip file does not exist",
                            @"ZipErrorCode: Requested location for zip file does not exist");
}

+(BOOL)setOZEM_ZipLocationDoesNotExist:(NSString*)errorString
{
   s_OZEM_ZipLocationDoesNotExist = errorString;
   return YES;
}

+(NSInteger) OZEC_ZipLocationReadOnly
{  return 105;
}

+(NSString*) OZEM_ZipLocationReadOnly
{  if (s_OZEM_ZipLocationReadOnly) return s_OZEM_ZipLocationReadOnly;
   return NSLocalizedString(@"Requested location for zip file is read only",
                            @"ZipErrorCode: Requested location for zip file is read only");
}

+(BOOL)setOZEM_ZipLocationReadOnly:(NSString*)errorString
{
   s_OZEM_ZipLocationReadOnly = errorString;
   return YES;
}

+(NSInteger) OZEC_ReadDataFailure
{  return 106;
}

+(NSString*) OZEM_ReadDataFailure
{  if (s_OZEM_ReadDataFailure) return s_OZEM_ReadDataFailure;
   return NSLocalizedString(@"Failed to read data to add to zip file",
                            @"ZipErrorCode: Failed to read data to add to zip file");
}

+(BOOL)setOZEM_ReadDataFailure:(NSString*)errorString
{
   s_OZEM_ReadDataFailure = errorString;
   return YES;
}

+(NSInteger) OZEC_FileCouldNotBeOpenedForReading
{  return 107;
}

+(NSString*) OZEM_FileCouldNotBeOpenedForReading
{  if (s_OZEM_FileCouldNotBeOpenedForReading) return s_OZEM_FileCouldNotBeOpenedForReading;
   return NSLocalizedString(@"A file to be added to the zip file could not be opened for reading",
                            @"ZipErrorCode: A file to be added to the zip file could not be opened for reading");
}

+(BOOL)setOZEM_FileCouldNotBeOpenedForReading:(NSString*)errorString
{
   s_OZEM_FileCouldNotBeOpenedForReading = errorString;
   return YES;
}

+(NSInteger) OZEC_CannotWriteFileInArchive
{  return 108;
}

+(NSString*) OZEM_CannotWriteFileInArchive
{  if (s_OZEM_CannotWriteFileInArchive) return s_OZEM_CannotWriteFileInArchive;
   return NSLocalizedString(@"Error in writing '%@' in the zipfile",
                            @"ZipErrorCode: Error in writing '[filename]' in the zipfile");
}

+(BOOL)setOZEM_CannotWriteFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OZEM_CannotWriteFileInArchive = errorString;
   return YES;
}

+(NSInteger) OZEC_OperationNotPermitted
{  return 109;
}

+(NSString*) OZEM_OperationNotPermitted
{  if (s_OZEM_OperationNotPermitted) return s_OZEM_OperationNotPermitted;
   return NSLocalizedString(@"Operation not permitted without Unzip mode",
                            @"ZipErrorCode: Operation not permitted without Unzip mode");
}

+(BOOL)setOZEM_OperationNotPermitted:(NSString*)errorString
{
   s_OZEM_OperationNotPermitted = errorString;
   return YES;
}


// unzip error codes
+(NSInteger) OUZEC_PathDoesNotExist
{  return 120;
}

+(NSString*) OUZEM_PathDoesNotExist
{  if (s_OUZEM_PathDoesNotExist) return s_OUZEM_PathDoesNotExist;
   return NSLocalizedString(@"Extraction path does not exist",
                            @"ZipErrorCode: Extraction path does not exist");
}

+(BOOL)setOUZEM_PathDoesNotExist:(NSString*)errorString
{
   s_OUZEM_PathDoesNotExist = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotCreateFolder
{  return 121;
}

+(NSString*) OUZEM_CannotCreateFolder
{  if (s_OUZEM_CannotCreateFolder) return s_OUZEM_CannotCreateFolder;
   return NSLocalizedString(@"Could not create folder to extract files into",
                            @"ZipErrorCode: Could not create folder to extract files into");
}

+(BOOL)setOUZEM_CannotCreateFolder:(NSString*)errorString
{
   s_OUZEM_CannotCreateFolder = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotCreateExtractionQueue
{  return 122;
}

+(NSString*) OUZEM_CannotCreateExtractionQueue
{  if (s_OUZEM_CannotCreateExtractionQueue) return s_OUZEM_CannotCreateExtractionQueue;
   return NSLocalizedString(@"Failed to get a system queue to extract data from zip file",
                            @"ZipErrorCode: Failed to get a system queue to extract data from zip file");
}

+(BOOL)setOUZEM_CannotCreateExtractionQueue:(NSString*)errorString
{
   s_OUZEM_CannotCreateExtractionQueue = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotFindInfoForFileInArchive
{  return 123;
}

+(NSString*) OUZEM_CannotFindInfoForFileInArchive
{  if (s_OUZEM_CannotFindInfoForFileInArchive) return s_OUZEM_CannotFindInfoForFileInArchive;
   return NSLocalizedString(@"File does not exist in archive",
                            @"ZipErrorCode: File does not exist in archive");
}

+(BOOL)setOUZEM_CannotFindInfoForFileInArchive:(NSString*)errorString
{
   s_OUZEM_CannotFindInfoForFileInArchive = errorString;
   return YES;
}

+(NSInteger) OUZEC_FileAlreadyExists
{  return 124;
}

+(NSString*) OUZEM_FileAlreadyExists
{  if (s_OUZEM_FileAlreadyExists) return s_OUZEM_FileAlreadyExists;
   return NSLocalizedString(@"During file extraction the file to be written already exists",
                            @"ZipErrorCode: During file extraction the file to be written already exists");
}

+(BOOL)setOUZEM_FileAlreadyExists:(NSString*)errorString
{
   s_OUZEM_FileAlreadyExists = errorString;
   return YES;
}

+(NSInteger) OUZEC_FileCouldNotBeOpenedForWriting
{  return 125;
}

+(NSString*) OUZEM_FileCouldNotBeOpenedForWriting
{  if (s_OUZEM_FileCouldNotBeOpenedForWriting) return s_OUZEM_FileCouldNotBeOpenedForWriting;
   return NSLocalizedString(@"During file extraction the file to be written could not be opened for writing",
                            @"ZipErrorCode: During file extraction the file to be written could not be opened for writing");
}

+(BOOL)setOUZEM_FileCouldNotBeOpenedForWriting:(NSString*)errorString
{
   s_OUZEM_FileCouldNotBeOpenedForWriting = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotReadFileInArchive
{  return 126;
}

+(NSString*) OUZEM_CannotReadFileInArchive
{  if (s_OUZEM_CannotReadFileInArchive) return s_OUZEM_CannotReadFileInArchive;
   return NSLocalizedString(@"Error in reading '%@' in the zipfile",
                            @"ZipErrorCode: Error in reading '[filename]' in the zipfile");
}

+(BOOL)setOUZEM_CannotReadFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotReadFileInArchive = errorString;
   return YES;
}

+(NSInteger) OUZEC_OperationNotPermitted
{  return 127;
}

+(NSString*) OUZEM_OperationNotPermitted
{  if (s_OUZEM_OperationNotPermitted) return s_OUZEM_OperationNotPermitted;
   return NSLocalizedString(@"Operation not permitted with Unzip mode",
                            @"ZipErrorCode: Operation not permitted with Unzip mode");
}

+(BOOL)setOUZEM_OperationNotPermitted:(NSString*)errorString
{
   s_OUZEM_OperationNotPermitted = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotGetGlobalInfo
{  return 128;
}

+(NSString*) OUZEM_CannotGetGlobalInfo
{  if (s_OUZEM_CannotGetGlobalInfo) return s_OUZEM_CannotGetGlobalInfo;
   return NSLocalizedString(@"Error in getting global info in '%@'",
                            @"ZipErrorCode: Error in getting global info in '[filename]'");
}

+(BOOL)setOUZEM_CannotGetGlobalInfo:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotGetGlobalInfo = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotGoToFirstFileInArchive
{  return 129;
}

+(NSString*) OUZEM_CannotGoToFirstFileInArchive
{  if (s_OUZEM_CannotGoToFirstFileInArchive) return s_OUZEM_CannotGoToFirstFileInArchive;
   return NSLocalizedString(@"Error in going to first file in zip in '%@'",
                            @"ZipErrorCode: Error in going to first file in zip in '[filename]'");
}

+(BOOL)setOUZEM_CannotGoToFirstFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotGoToFirstFileInArchive = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotGoToNextFileInArchive
{  return 130;
}

+(NSString*) OUZEM_CannotGoToNextFileInArchive
{  if (s_OUZEM_CannotGoToNextFileInArchive) return s_OUZEM_CannotGoToNextFileInArchive;
   return NSLocalizedString(@"Error in going to next file in zip in '%@'",
                            @"ZipErrorCode: Error in going to first file in zip in '[filename]'");
}

+(BOOL)setOUZEM_CannotGoToNextFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotGoToNextFileInArchive = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotGetCurrentFileInfoInArchive
{  return 131;
}

+(NSString*) OUZEM_CannotGetCurrentFileInfoInArchive
{  if (s_OUZEM_CannotGetCurrentFileInfoInArchive) return s_OUZEM_CannotGetCurrentFileInfoInArchive;
   return NSLocalizedString(@"Error in getting current file info in '%@'",
                            @"ZipErrorCode: Error in getting current file info in '[filename]'");
}

+(BOOL)setOUZEM_CannotGetCurrentFileInfoInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotGetCurrentFileInfoInArchive = errorString;
   return YES;
}

+(NSInteger) OUZEC_CannotOpenCurrentFileInArchive
{  return 132;
}

+(NSString*) OUZEM_CannotOpenCurrentFileInArchive
{  if (s_OUZEM_CannotOpenCurrentFileInArchive) return s_OUZEM_CannotOpenCurrentFileInArchive;
   return NSLocalizedString(@"Error in opening current file in '%@'",
                            @"ZipErrorCode: Error in opening current file in '[filename]'");
}

+(BOOL)setOUZEM_CannotOpenCurrentFileInArchive:(NSString*)errorString
{
   // TODO:LEA:check for one and only one %@ in string
   s_OUZEM_CannotOpenCurrentFileInArchive = errorString;
   return YES;
}


+(BOOL) setErrorString:(NSString *)errorString forCode:(NSInteger)errorCode
{
   if (errorString.length == 0) return NO;
   
   // common error codes
   if (errorCode == [ZipErrorCodes OZCEC_UserCancelled])
      return [ZipErrorCodes setOZCEM_UserCancelled:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_Indeterminate])
      return [ZipErrorCodes setOZCEM_Indeterminate:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_NotEnoughDiskSpace])
      return [ZipErrorCodes setOZCEM_NotEnoughDiskSpace:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotReadSystemFolderAttributes])
      return [ZipErrorCodes setOZCEM_CannotReadSystemFolderAttributes:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotOpenFileInArchive])
      return [ZipErrorCodes setOZCEM_CannotOpenFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotCloseFileInArchive])
      return [ZipErrorCodes setOZCEM_CannotCloseFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotCreateZipFile])
      return [ZipErrorCodes setOZCEM_CannotCreateZipFile:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotOpenZipFile])
      return [ZipErrorCodes setOZCEM_CannotOpenZipFile:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_CannotCloseZipFile])
      return [ZipErrorCodes setOZCEM_CannotCloseZipFile:errorString];
   if (errorCode == [ZipErrorCodes OZCEC_UnknownZipFileMode])
      return [ZipErrorCodes setOZCEM_UnknownZipFileMode:errorString];
   
   // zip error codes
   if (errorCode == [ZipErrorCodes OZEC_WriteStreamCreation])
      return [ZipErrorCodes setOZEM_WriteStreamCreation:errorString];
   if (errorCode == [ZipErrorCodes OZEC_ZeroLengthFileName])
      return [ZipErrorCodes setOZEM_ZeroLengthFileName:errorString];
   if (errorCode == [ZipErrorCodes OZEC_DuplicateFileNames])
      return [ZipErrorCodes setOZEM_DuplicateFileNames:errorString];
   if (errorCode == [ZipErrorCodes OZEC_ZipLocationIsFile])
      return [ZipErrorCodes setOZEM_ZipLocationIsFile:errorString];
   if (errorCode == [ZipErrorCodes OZEC_ZipLocationDoesNotExist])
      return [ZipErrorCodes setOZEM_ZipLocationDoesNotExist:errorString];
   if (errorCode == [ZipErrorCodes OZEC_ZipLocationReadOnly])
      return [ZipErrorCodes setOZEM_ZipLocationReadOnly:errorString];
   if (errorCode == [ZipErrorCodes OZEC_ReadDataFailure])
      return [ZipErrorCodes setOZEM_ReadDataFailure:errorString];
   if (errorCode == [ZipErrorCodes OZEC_FileCouldNotBeOpenedForReading])
      return [ZipErrorCodes setOZEM_FileCouldNotBeOpenedForReading:errorString];
   if (errorCode == [ZipErrorCodes OZEC_CannotWriteFileInArchive])
      return [ZipErrorCodes setOZEM_CannotWriteFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OZEC_OperationNotPermitted])
      return [ZipErrorCodes setOZEM_OperationNotPermitted:errorString];
   
   // unzip error codes
   if (errorCode == [ZipErrorCodes OUZEC_PathDoesNotExist])
      return [ZipErrorCodes setOUZEM_PathDoesNotExist:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotCreateFolder])
      return [ZipErrorCodes setOUZEM_CannotCreateFolder:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotCreateExtractionQueue])
      return [ZipErrorCodes setOUZEM_CannotCreateExtractionQueue:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotFindInfoForFileInArchive])
      return [ZipErrorCodes setOUZEM_CannotFindInfoForFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_FileAlreadyExists])
      return [ZipErrorCodes setOUZEM_FileAlreadyExists:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_FileCouldNotBeOpenedForWriting])
      return [ZipErrorCodes setOUZEM_FileCouldNotBeOpenedForWriting:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotReadFileInArchive])
      return [ZipErrorCodes setOUZEM_CannotReadFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_OperationNotPermitted])
      return [ZipErrorCodes setOUZEM_OperationNotPermitted:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotGetGlobalInfo])
      return [ZipErrorCodes setOUZEM_CannotGetGlobalInfo:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotGoToFirstFileInArchive])
      return [ZipErrorCodes setOUZEM_CannotGoToFirstFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotGoToNextFileInArchive])
      return [ZipErrorCodes setOUZEM_CannotGoToNextFileInArchive:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotGetCurrentFileInfoInArchive])
      return [ZipErrorCodes setOUZEM_CannotGetCurrentFileInfoInArchive:errorString];
   if (errorCode == [ZipErrorCodes OUZEC_CannotOpenCurrentFileInArchive])
      return [ZipErrorCodes setOUZEM_CannotOpenCurrentFileInArchive:errorString];
   
   NSLog(@"WARNING: ZipErrorCodes setErrorString called for non-existant code:%ld", (long)errorCode);
   return NO;
}

@end
