// Base class for CkoZip event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoZipProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;

- (void)ToBeAdded: (NSString *)fileName
	fileSize: (NSNumber *)fileSize
	excludeFlag: (BOOL *)excludeFlag;

- (void)DirToBeAdded: (NSString *)fileName
	excludeFlag: (BOOL *)excludeFlag;

- (void)FileAdded: (NSString *)fileName
	fileSize: (NSNumber *)fileSize
	abort: (BOOL *)abort;

- (void)ToBeZipped: (NSString *)fileName
	fileSize: (NSNumber *)fileSize
	abort: (BOOL *)abort;

- (void)FileZipped: (NSString *)fileName
	fileSize: (NSNumber *)fileSize
	compressedSize: (NSNumber *)compressedSize
	abort: (BOOL *)abort;

- (void)ToBeUnzipped: (NSString *)fileName
	compressedSize: (NSNumber *)compressedSize
	fileSize: (NSNumber *)fileSize
	abort: (BOOL *)abort;

- (void)FileUnzipped: (NSString *)fileName
	compressedSize: (NSNumber *)compressedSize
	fileSize: (NSNumber *)fileSize
	abort: (BOOL *)abort;

- (void)AddFilesBegin;
- (void)AddFilesEnd;
- (void)WriteZipBegin;
- (void)WriteZipEnd;
- (void)UnzipBegin;
- (void)UnzipEnd;

@end
