// Base class for CkoMailMan event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoMailManProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;
- (void)ProgressInfo: (NSString *)name
	value: (NSString *)value;


- (void)EmailReceived: (NSString *)subject
			    fromAddr: (NSString *)fromAddr
				fromName: (NSString *)fromName
			    returnPath: (NSString *)returnPath
			    dateTime: (NSString *)dateTime
			    uidl: (NSString *)uidl 
			    sizeInBytes: (NSNumber *)sizeInBytes;

@end
