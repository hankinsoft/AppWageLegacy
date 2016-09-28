// Base class for CkoFtp2 event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoFtp2Progress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;

- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;

- (void)DataPort: (NSNumber *)port;

- (void)BeginDownloadFile: (NSString *)path 
	skip:(BOOL *)skip;

- (void)EndDownloadFile: (NSString *)path 
	numBytes:(NSNumber *)numBytes;

- (void)VerifyDownloadDir: (NSString *)path 
	skip:(BOOL *)skip;

- (void)BeginUploadFile: (NSString *)path 
	skip:(BOOL *)skip;

- (void)EndUploadFile: (NSString *)path
	numBytes:(NSNumber *)numBytes;

- (void)VerifyUploadDir: (NSString *)path 
	skip:(BOOL *)skip;

- (void)VerifyDeleteDir: (NSString *)path 
	skip:(BOOL *)skip;

- (void)VerifyDeleteFile: (NSString *)path 
	skip:(BOOL *)skip;

- (void)UploadRate: (NSNumber *)byteCount 
	bytesPerSec: (NSNumber *)bytesPerSec;

- (void)DownloadRate: (NSNumber *)byteCount 
	bytesPerSec: (NSNumber *)bytesPerSec;

- (void)ProgressInfo: (NSString *)name 
	value:(NSString *)value;

@end
