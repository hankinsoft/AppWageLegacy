// Base class for CkoHttp event callbacks.
// Applications can create a class that derives from this class.
#import "CkoProgress.h"

@interface CkoHttpProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;

- (void)ProgressInfo: (NSString *)name
	value: (NSString *)value;

- (void)HttpRedirect: (NSString *)originalUrl
	redirectUrl: (NSString *)redirectUrl
	abort: (BOOL *)abort;

- (void)HttpChunked;

- (void)HttpBeginReceive;
- (void)HttpEndReceive: (BOOL)success;
- (void)HttpBeginSend;
- (void)HttpEndSend: (BOOL)success;

- (void)ReceiveRate: (NSNumber *)byteCount
	bytesPerSec: (NSNumber *)bytesPerSec;

@end
