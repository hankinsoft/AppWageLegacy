// Base class for CkoImap event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoImapProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;
- (void)ProgressInfo: (NSString *)name
	value: (NSString *)value;



@end
