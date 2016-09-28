// Base class for CkoSFtp event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoSFtpProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;
- (void)ProgressInfo: (NSString *)name
	value: (NSString *)value;


- (void)UploadRate: (NSNumber *)byteCount
	bytesPerSec: (NSNumber *)bytesPerSec;

- (void)DownloadRate: (NSNumber *)byteCount
	bytesPerSec: (NSNumber *)bytesPerSec;


@end
